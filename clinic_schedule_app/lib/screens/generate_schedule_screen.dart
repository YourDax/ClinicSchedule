import 'package:flutter/material.dart';
import '../../api/api_client.dart';
import '../../models/department_model.dart';
import '../models/Assignment.dart';
import '../models/ScheduleCell.dart';
import 'edit_shift_screen.dart';

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

  bool isLoadingDepartments = false;
  bool isLoadingSchedule = false;

  List<ScheduleCell> scheduleCells = [];

  @override
  void initState() {
    super.initState();
    _generateDays();
    _loadDepartments();
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
          _loadSchedule();
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
    final cell = scheduleCells.firstWhere(
          (c) => _isSameDate(c.date, date),
      orElse: () => ScheduleCell(
        id: 0,
        date: date,
        departmentId: selectedDepartment?.id ?? 0,
        assignments: [],
        requiredDoctors: 1,
        requiredNurses: 1, shiftViews: [],
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
      // Для других смен, если будут, можно задать дефолтное время или null
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
                  onPressed: (index) {
                    setState(() {
                      isCurrentWeek = index == 0;
                      _generateDays();
                      _loadSchedule();
                    });
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
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                  _loadSchedule();
                });
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
                        children: const [
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'День / Дата',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Смена 1 (8:00 - 16:00)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Padding(
                            padding: EdgeInsets.all(8),
                            child: Text(
                              'Смена 2 (16:00 - 24:00)',
                              style: TextStyle(fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ],
                      ),
                      for (var day in days)
                        TableRow(
                          children: [
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Text(
                                '${_weekdayName(day.weekday)}, ${day.day.toString().padLeft(2, '0')}.${day.month.toString().padLeft(2, '0')}',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontWeight: FontWeight.w600),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildShiftCell(day, 1),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildShiftCell(day, 2),
                            ),
                          ],
                        ),
                    ],
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
                    final dates = days.map((d) => d.toIso8601String()).toList();
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
          ],
        ),
      ),
    );
  }
}
