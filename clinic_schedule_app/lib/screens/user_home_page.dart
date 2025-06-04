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

  List<ScheduleCell> scheduleCells = [];

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() {
      isLoading = true;
      error = null;
    });

    try {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final user = userProvider.user;
      if (user == null) throw Exception('Пользователь не авторизован');

      final now = DateTime.now();
      final start = isCurrentWeek
          ? now.subtract(Duration(days: now.weekday - 1))
          : now.add(Duration(days: 7 - now.weekday + 1));
      final end = start.add(const Duration(days: 6));

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
    final now = DateTime.now();
    final startOfWeek = isCurrentWeek
        ? now.subtract(Duration(days: now.weekday - 1))
        : now.add(Duration(days: 7 - now.weekday + 1));
    final days = List.generate(7, (i) => startOfWeek.add(Duration(days: i)));

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: const Text('Расписание'),
      ),
      body: Column(
        children: [
          ToggleButtons(
            isSelected: [isCurrentWeek, !isCurrentWeek],
            onPressed: (index) {
              setState(() {
                isCurrentWeek = index == 0;
              });
              _loadSchedule();
            },
            children: const [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Текущая неделя'),
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Следующая неделя'),
              ),
            ],
          ),
          if (isLoading) const LinearProgressIndicator(),
          if (error != null)
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Ошибка загрузки: $error', style: const TextStyle(color: Colors.red)),
            ),
          Expanded(
            child: SingleChildScrollView(
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
                    // Заголовок
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
                    // Дни недели
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
          )
        ],
      ),
    );
  }

  Widget _buildShiftCell(DateTime date, int shiftNumber) {
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    final user = userProvider.user;

    final cell = scheduleCells.firstWhere(
          (c) => _isSameDate(c.date, date),
      orElse: () => ScheduleCell(id: 0, date: date, departmentId: 0, assignments: []),
    );

    final uniqueShiftIds = cell.assignments.map((a) => a.shiftId).toSet().toList()..sort();

    if (shiftNumber > uniqueShiftIds.length) {
      return const Center(child: Text('Выходной', style: TextStyle(color: Colors.grey)));
    }

    final shiftId = uniqueShiftIds[shiftNumber - 1];
    final assignmentsForShift = cell.assignments.where((a) => a.shiftId == shiftId).toList();

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




  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

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
