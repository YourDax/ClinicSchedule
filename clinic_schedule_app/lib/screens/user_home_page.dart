import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/ScheduleCell.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';
import '../api/api_client.dart'; // путь подкорректируй


class UserHomePage extends StatefulWidget {
  const UserHomePage({super.key});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {
  bool isCurrentWeek = true;
  bool isLoading = false;
  String? error;
  late List<DateTime> days;

  List<ScheduleCell> scheduleCells = [];

  @override
  void initState() {
    super.initState();
    _generateDays();
    _loadSchedule();
  }
  void _generateDays() {
    final now = DateTime.now();
    final mondayDate = now.subtract(Duration(days: now.weekday - 1));
    final baseDate = isCurrentWeek ? mondayDate : mondayDate.add(const Duration(days: 7));
    final baseDateAtMidnight = DateTime(baseDate.year, baseDate.month, baseDate.day);

    days = List.generate(7, (index) => baseDateAtMidnight.add(Duration(days: index)));
  }

  Future<void> _loadSchedule() async {
    setState(() {
      isLoading = true;
      error = null;
      scheduleCells = [];
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user == null) throw Exception('Пользователь не авторизован');

      final start = days.first;
      final end = days.last;

      final data = await ApiClient.getScheduleForUser(
        userId: user.id,
        role: user.role == UserRole.doctor ? 'Doctor' : 'Nurse',
        startDate: start,
        endDate: end,
      );

      setState(() {
        scheduleCells = data;
      });
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Расписание'),
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
                      _generateDays(); // обновляем days согласно выбранной неделе
                      _loadSchedule();
                    });
                  },
                  children: const [
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Текущая'),
                    ),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12),
                      child: Text('Следующая'),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Если нужно — здесь можно добавить выбор отделения,
            // например DropdownButtonFormField<DepartmentModel> selectedDepartment
            // для фильтрации расписания по отделению

            if (isLoading)
              const LinearProgressIndicator(),

            if (error != null)
              Padding(
                padding: const EdgeInsets.all(8),
                child: Text('Ошибка загрузки: $error', style: const TextStyle(color: Colors.red)),
              ),

            Expanded(
              child: isLoading
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
                              child: _buildShiftCell(day, DateTime(day.year, day.month, day.day, 8, 0)), // 8:00
                            ),
                            Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: _buildShiftCell(day, DateTime(day.year, day.month, day.day, 16, 0)), // 16:00
                            ),
                          ],
                        )

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  Widget _buildShiftCell(DateTime date, DateTime shiftTime) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    final cell = scheduleCells.firstWhere(
          (c) => _isSameDateTime(c.date, date),
      orElse: () => ScheduleCell(id: 0, date: date, departmentId: 0, assignments: [], shiftViews: []),
    );

    final assignmentsForShift = cell.assignments
        .where((a) => a.shiftStartTime != null && _isSameDateTime(a.shiftStartTime!, shiftTime))
        .toList();

    if (assignmentsForShift.isEmpty) {
      return const Center(child: Text('Выходной', style: TextStyle(color: Colors.grey)));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: assignmentsForShift.map((s) {
        final isCurrentUser = s.staffId == user?.id && s.role == user?.role.index;
        return Text.rich(
          TextSpan(
            text: s.fullName,
            style: TextStyle(
              fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
              color: isCurrentUser ? Colors.blue : Colors.black,
            ),
            children: [
              if (isCurrentUser) const TextSpan(text: ' (Вы)'),
              TextSpan(text: ' (${s.role == 1 ? "Доктор" : "Медсестра"})'),
            ],
          ),
        );
      }).toList(),
    );
  }




  bool _isSameDateTime(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day &&
        a.hour == b.hour;
  }


  String _weekdayName(int weekday) {
    switch (weekday) {
      case DateTime.monday:
        return 'Понедельник';
      case DateTime.tuesday:
        return 'Вторник';
      case DateTime.wednesday:
        return 'Среда';
      case DateTime.thursday:
        return 'Четверг';
      case DateTime.friday:
        return 'Пятница';
      case DateTime.saturday:
        return 'Суббота';
      case DateTime.sunday:
        return 'Воскресенье';
      default:
        return '';
    }
  }
}
