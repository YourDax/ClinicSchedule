import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
//import 'package:gallery_saver/gallery_saver.dart';
import '../../api/api_client.dart';
import '../../models/department_model.dart';
import '../models/Assignment.dart';
import '../models/ScheduleCell.dart';
import '../models/ShiftViewModel.dart';
import 'edit_shift_screen.dart';
import 'dart:ui' as ui;
import 'dart:typed_data';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:shared_preferences/shared_preferences.dart';


class GenerateScheduleScreen extends StatefulWidget {
  const GenerateScheduleScreen({Key? key}) : super(key: key);

  @override
  State<GenerateScheduleScreen> createState() => _GenerateScheduleScreenState();
}

class _GenerateScheduleScreenState extends State<GenerateScheduleScreen> {
  bool isCurrentWeek = true;
  DepartmentModel? selectedDepartment;
  List<DepartmentModel> departments = [];
  late List<DateTime> days;
  final GlobalKey _tableKey = GlobalKey();

  bool isLoadingDepartments = false;
  bool isLoadingSchedule = false;

  List<ScheduleCell> scheduleCells = [];
  Set<DateTime> weekendDays = {};


  @override
  void initState() {
    super.initState();
    _generateDays();
    _loadDepartments();
  }

  String _getStorageKey() {
    final deptId = selectedDepartment?.id ?? 0;
    final weekStart = days.first;
    final weekKey = '${weekStart.year}-${weekStart.month.toString().padLeft(2, '0')}-${weekStart.day.toString().padLeft(2, '0')}';
    return 'weekendDays_${deptId}_$weekKey';
  }

  Future<void> _saveWeekendDays() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey();
    final dateStrings = weekendDays.map((d) => d.toIso8601String()).toList();
    await prefs.setStringList(key, dateStrings);
  }

  Future<void> _loadWeekendDays() async {
    final prefs = await SharedPreferences.getInstance();
    final key = _getStorageKey();
    final dateStrings = prefs.getStringList(key) ?? [];

    final parsedDates = dateStrings
        .map((s) => DateTime.tryParse(s))
        .whereType<DateTime>()
        .toSet();

    setState(() {
      weekendDays = parsedDates;
    });
  }


  void _generateDays() {
    final now = DateTime.now();
    final mondayDate = now.subtract(Duration(days: now.weekday - 1));
    final baseDate = isCurrentWeek ? mondayDate : mondayDate.add(const Duration(days: 7));
    final baseDateAtMidnight = DateTime(baseDate.year, baseDate.month, baseDate.day);

    days = List.generate(7, (index) => baseDateAtMidnight.add(Duration(days: index)));
  }

  Future<void> _loadDepartments() async {
    setState(() {
      isLoadingDepartments = true;
    });
    try {
      final result = await ApiClient.getDepartments();
      setState(() {
        departments = result;
        if (departments.isNotEmpty && selectedDepartment == null) {
          selectedDepartment = departments.first;
          _generateDays(); // обязательно перед загрузкой выходных
          _loadSchedule();
          _loadWeekendDays(); // загружаем после установки selectedDepartment и days
        }
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить отделения')),
      );
    } finally {
      setState(() {
        isLoadingDepartments = false;
      });
    }
  }

  Future<void> _loadSchedule() async {
    if (selectedDepartment == null) return;

    setState(() {
      isLoadingSchedule = true;
      scheduleCells = [];
    });

    try {
      final startDate = days.first;
      final endDate = days.last;

      final result = await ApiClient.getScheduleByDepartment(
        departmentId: selectedDepartment!.id,
        startDate: startDate,
        endDate: endDate,
      );

      setState(() {
        scheduleCells = result;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Не удалось загрузить расписание')),
      );
    } finally {
      setState(() {
        isLoadingSchedule = false;
      });
    }
  }

  String _weekdayName(int weekday) {
    const names = ['Пн', 'Вт', 'Ср', 'Чт', 'Пт', 'Сб', 'Вс'];
    return names[weekday - 1];
  }

  Widget _buildShiftCell(DateTime date, int shiftNumber) {
    if (weekendDays.contains(date)) {
      return const Center(child: Text('Выходной', style: TextStyle(color: Colors.grey)));
    }

    final cell = scheduleCells.firstWhere(
          (c) => _isSameDate(c.date, date),
      orElse: () => ScheduleCell(
        id: 0,
        date: date,
        departmentId: selectedDepartment?.id ?? 0,
        assignments: [],
        requiredDoctors: 1,
        requiredNurses: 1,
        shiftViews: [],
      ),
    );

    final uniqueShiftIds = cell.assignments
        .map((a) => a.shiftId)
        .toSet()
        .toList()
      ..sort();

    final departmentId = selectedDepartment?.id ?? 0;

    // Определяем startTime и endTime для передачи
    DateTime startTime;
    DateTime endTime;

    if (shiftNumber == 1) {
      startTime = DateTime(date.year, date.month, date.day, 8);
      endTime = DateTime(date.year, date.month, date.day, 16);
    } else if (shiftNumber == 2) {
      startTime = DateTime(date.year, date.month, date.day, 16);
      // Для 24:00 лучше ставить 00:00 следующего дня
      endTime = DateTime(date.year, date.month, date.day).add(const Duration(days: 1));
    } else {
      startTime = DateTime(date.year, date.month, date.day, 0);
      endTime = DateTime(date.year, date.month, date.day, 0);
    }

    if (shiftNumber > uniqueShiftIds.length) {
      return InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => EditShiftScreen(
                date: date,
                shiftId: -1,
                departmentId: departmentId,
                assignments: [],
                requiredDoctorsCount: cell.requiredDoctors,
                requiredNursesCount: cell.requiredNurses,
                startTime: startTime,
                endTime: endTime,
                shiftViews: cell.shiftViews, //TODO надо передавать все смены которые пришли из запроса

              ),
            ),
          ).then((_) => _loadSchedule());
        },
        child: const Center(
          child: Text('Выходной', style: TextStyle(color: Colors.grey)),
        ),
      );
    }

    final shiftId = uniqueShiftIds[shiftNumber - 1];
    final assignmentsForShift = cell.assignments.where((a) => a.shiftId == shiftId).toList();

    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => EditShiftScreen(
              date: date,
              shiftId: shiftId,
              departmentId: departmentId,
              assignments: assignmentsForShift.map((s) => Assignment(
                shiftId: s.shiftId,
                userId: s.staffId,
                role: s.role,
                fullName: s.fullName,
                scheduleId: s.scheduleId,
              )).toList(),
              requiredDoctorsCount: cell.requiredDoctors,
              requiredNursesCount: cell.requiredNurses,
              startTime: startTime,
              endTime: endTime,
              shiftViews: cell.shiftViews,
            ),
          ),
        ).then((_) => _loadSchedule());
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: assignmentsForShift.map((s) {
          return Text('${s.fullName} (${s.role == 1 ? "Доктор" : "Медсестра"})');
        }).toList(),
      ),
    );
  }


  /*Future<void> _saveAsPng(GlobalKey key, BuildContext context) async {
    try {
      // Получаем RenderRepaintBoundary
      final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
      if (boundary == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось получить изображение')),
        );
        return;
      }

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Ошибка при конвертации изображения')),
        );
        return;
      }
      final pngBytes = byteData.buffer.asUint8List();

      // Сохраняем временный файл (gallery_saver принимает путь к файлу, а не Uint8List)
      // Нужно сохранить pngBytes во временный файл:
      final tempDir = await getTemporaryDirectory();
      final filePath = '${tempDir.path}/schedule_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(filePath);
      await file.writeAsBytes(pngBytes);

      // Сохраняем файл в галерею
      final success = await GallerySaver.saveImage(file.path);

      if (success == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Изображение сохранено в галерею')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Не удалось сохранить изображение')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: $e')),
      );
    }
  }*/


  bool _isSameDate(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Генерация расписания'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Неделя:'),
                ToggleButtons(
                  isSelected: [isCurrentWeek, !isCurrentWeek],
                  onPressed: (index) async {
                    setState(() {
                      isCurrentWeek = index == 0;
                      _generateDays();
                    });
                    await _loadSchedule();
                    await _loadWeekendDays();
                  },
                  children: const [Text('Текущая'), Text('Следующая')],
                ),
              ],
            ),
            const SizedBox(height: 16),
            isLoadingDepartments
                ? const CircularProgressIndicator()
                : DropdownButtonFormField<DepartmentModel>(
              value: selectedDepartment,
              decoration: const InputDecoration(labelText: 'Выберите отделение'),
              items: departments
                  .map((dept) => DropdownMenuItem(
                value: dept,
                child: Text(dept.name),
              ))
                  .toList(),
              onChanged: (value) async  {
                setState(() {
                  selectedDepartment = value;
                  _generateDays();
                });
                await _loadSchedule();
                await _loadWeekendDays();
              },
            ),
            const SizedBox(height: 16),
            Expanded(
              child: isLoadingSchedule
                  ? const Center(child: CircularProgressIndicator())
                  : SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: RepaintBoundary(
                    key: _tableKey,
                    child: Table(
                      border: TableBorder.all(color: Colors.black26),
                      columnWidths: const {
                        0: FixedColumnWidth(130),
                        1: FixedColumnWidth(200),
                        2: FixedColumnWidth(200),
                      },
                      defaultVerticalAlignment: TableCellVerticalAlignment.middle,
                      children: [
                        TableRow(
                          decoration: BoxDecoration(color: Colors.blue.shade100),
                          children: [
                            Container(
                              color: Colors.white,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'День / Дата',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Смена 1 (8:00 - 16:00)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            Container(
                              color: Colors.white,
                              child: const Padding(
                                padding: EdgeInsets.all(8),
                                child: Text(
                                  'Смена 2 (16:00 - 24:00)',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                          ],
                        ),
                        for (var day in days)
                          TableRow(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    '${_weekdayName(day.weekday)}, ${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}',
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(fontWeight: FontWeight.w600),
                                  ),
                                  Checkbox(
                                    value: weekendDays.contains(day),
                                      onChanged: (value) async {
                                        setState(() {
                                          if (value == true) {
                                            weekendDays.add(day);
                                          } else {
                                            weekendDays.remove(day);
                                          }
                                        });

                                        await _saveWeekendDays(); // <-- сохраняем изменения

                                        if (value == true) {
                                          try {
                                            await ApiClient.deleteScheduleByDate(
                                              departmentId: selectedDepartment!.id,
                                              date: day,
                                            );
                                            await _loadSchedule();
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('День помечен как выходной')),
                                            );
                                          } catch (e) {
                                            ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(content: Text('Ошибка при удалении расписания')),
                                            );
                                          }
                                        }
                                      }
                                  ),
                                ],
                              ),
                              Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _buildShiftCell(day, 1),
                                ),
                              ),
                              Container(
                                color: Colors.white,
                                child: Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: _buildShiftCell(day, 2),
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: isLoadingSchedule || selectedDepartment == null
                    ? null
                    : () async {
                  setState(() {
                    isLoadingSchedule = true;
                  });

                  try {
                    final dates = days
                        .where((d) => !weekendDays.contains(d))
                        .map((d) => d.toIso8601String())
                        .toList();

                    await ApiClient.generateSchedule(selectedDepartment!.id, dates);

                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Расписание успешно сгенерировано')),
                    );

                    await _loadSchedule();
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Ошибка при генерации расписания')),
                    );
                  } finally {
                    setState(() {
                      isLoadingSchedule = false;
                    });
                  }
                },
                child: isLoadingSchedule
                    ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
                    : const Text('Сгенерировать расписание'),
              ),
            ),
            /*const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                icon: const Icon(Icons.save_alt),
                label: const Text('Сохранить как PNG'),
                onPressed: () => _saveAsPng(_tableKey, context),
              ),
            ),*/


          ],
        ),
      ),
    );
  }
}
