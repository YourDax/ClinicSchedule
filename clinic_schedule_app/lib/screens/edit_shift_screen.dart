import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import '../models/Assignment.dart';
import '../models/ScheduleAssignmentBindingModel.dart';
import '../models/ScheduleBindingModel.dart';
import '../models/ScheduleCell.dart';
import '../models/ShiftBindingModel.dart';
import '../models/ShiftViewModel.dart';
import '../models/doctor_model.dart';
import '../models/nurse_model.dart';
import '../api/api_client.dart';

class EditShiftScreen extends StatefulWidget {
  final DateTime date;
  final int shiftId;
  final int departmentId;
  final List<Assignment> assignments;
  final int requiredDoctorsCount;
  final int requiredNursesCount;
  final DateTime? startTime; // добавлено
  final DateTime? endTime;   // добавлено
  final List<Shift> shiftViews;

  const EditShiftScreen({
    Key? key,
    required this.date,
    required this.shiftId,
    required this.departmentId,
    required this.assignments,
    required this.requiredDoctorsCount,
    required this.requiredNursesCount,
    this.startTime,
    this.endTime,
    required this.shiftViews,
  }) : super(key: key);


  @override
  _EditShiftScreenState createState() => _EditShiftScreenState();
}

class _EditShiftScreenState extends State<EditShiftScreen> {
  late int requiredDoctors;
  late int requiredNurses;
  int selectedShiftIndex = 0;

  List<DoctorModel> availableDoctors = [];
  List<NurseModel> availableNurses = [];

  List<DoctorModel?> selectedDoctors = [];
  List<NurseModel?> selectedNurses = [];

  @override
  void initState() {
    super.initState();
    requiredDoctors = widget.requiredDoctorsCount;
    requiredNurses = widget.requiredNursesCount;
    _loadAvailableStaff();
  }

  void _loadAssignments() {
    final assignedDoctors = <DoctorModel>[];
    final assignedNurses = <NurseModel>[];

    for (final assignment in widget.assignments) {
      if (assignment.role == 1) {
        final doctor = _findDoctorById(assignment.userId);
        if (doctor != null) assignedDoctors.add(doctor);
      } else if (assignment.role == 0) {
        final nurse = _findNurseById(assignment.userId);
        if (nurse != null) assignedNurses.add(nurse);
      }
    }

    setState(() {
      selectedDoctors = List<DoctorModel?>.from(assignedDoctors);
      if (selectedDoctors.length < requiredDoctors) {
        selectedDoctors.addAll(List<DoctorModel?>.filled(
            requiredDoctors - selectedDoctors.length, null));
      }

      selectedNurses = List<NurseModel?>.from(assignedNurses);
      if (selectedNurses.length < requiredNurses) {
        selectedNurses.addAll(List<NurseModel?>.filled(
            requiredNurses - selectedNurses.length, null));
      }
    });
  }


  Future<void> _loadAvailableStaff() async {
    try {
      // 1. Запросить всех врачей и медсестёр департамента
      final doctors = await ApiClient.getDoctorsByDepartment(widget.departmentId);
      final nurses = await ApiClient.getNursesByDepartment(widget.departmentId);

      // 2. Запросить расписание на день, чтобы получить назначения на все смены
      final scheduleCells = await ApiClient.getScheduleByDepartment(
        departmentId: widget.departmentId,
        startDate: widget.date,
        endDate: widget.date,
      );

      // 3. Собрать userId работников, которые назначены в соседних сменах
      final assignedInOtherShiftsDoctorIds = <int>{};
      final assignedInOtherShiftsNurseIds = <int>{};

      // У тебя должен быть widget.shiftId — текущая редактируемая смена
      final currentShiftId = widget.shiftId;

      for (final cell in scheduleCells) {
        for (final assignment in cell.assignments) {
          if (assignment.shiftId != currentShiftId) {
            if (assignment.role == 1) {
              assignedInOtherShiftsDoctorIds.add(assignment.staffId);
            } else if (assignment.role == 0) {
              assignedInOtherShiftsNurseIds.add(assignment.staffId);
            }
          }
        }
      }

      // 4. Отфильтровать врачей и медсестёр:
      final filteredDoctors = doctors.where((doc) {
        final isOnVacation = doc.vacationDates.any((vDate) => _isSameDate(vDate, widget.date));
        final isAssignedElsewhere = assignedInOtherShiftsDoctorIds.contains(doc.id);
        return !isOnVacation && !isAssignedElsewhere;
      }).toList();

      final filteredNurses = nurses.where((nurse) {
        final isOnVacation = nurse.vacationDates.any((vDate) => _isSameDate(vDate, widget.date));
        final isAssignedElsewhere = assignedInOtherShiftsNurseIds.contains(nurse.id);
        return !isOnVacation && !isAssignedElsewhere;
      }).toList();

      // 5. Добавить работников из текущих назначений, которых нет в списке (чтобы не потерять выбор)
      final currentAssignedDoctors = widget.assignments
          .where((a) => a.role == 1)
          .map((a) => a.userId)
          .toSet();
      final currentAssignedNurses = widget.assignments
          .where((a) => a.role == 0)
          .map((a) => a.userId)
          .toSet();

      final additionalDoctors = <DoctorModel>[];
      for (final id in currentAssignedDoctors) {
        if (!filteredDoctors.any((d) => d.id == id)) {
          final doc = await ApiClient.getDoctorById(id);
          if (doc != null) additionalDoctors.add(doc);
        }
      }

      final additionalNurses = <NurseModel>[];
      for (final id in currentAssignedNurses) {
        if (!filteredNurses.any((n) => n.id == id)) {
          final nurse = await ApiClient.getNurseById(id);
          if (nurse != null) additionalNurses.add(nurse);
        }
      }

      setState(() {
        availableDoctors = [...filteredDoctors, ...additionalDoctors];
        availableNurses = [...filteredNurses, ...additionalNurses];
      });

      _loadAssignments();  // заполнить выбранных

    } catch (e) {
      print('Ошибка загрузки персонала с учётом соседних смен: $e');
    }
  }

  Future<List<ScheduleCell>> fetchScheduleForDepartment(int departmentId, DateTime date) async {
    // Например, для одного дня, дата startDate = endDate = date
    return await ApiClient.getScheduleByDepartment(
      departmentId: departmentId,
      startDate: date,
      endDate: date,
    );
  }

  List<DoctorModel> _getFilteredDoctors(int currentIndex) {
    final selectedIds = selectedDoctors
        .asMap()
        .entries
        .where((entry) => entry.key != currentIndex && entry.value != null)
        .map((entry) => entry.value!.id)
        .toSet();

    final shiftIdsOnSameDay = widget.shiftViews
        .where((s) => _isSameDate(s.startTime, widget.date))
        .map((s) => s.id)
        .where((id) => id != widget.shiftId)
        .toSet();

    final assignedOtherShiftIds = widget.assignments
        .where((a) => a.role == 1 && shiftIdsOnSameDay.contains(a.shiftId))
        .map((a) => a.userId)
        .toSet();

    return availableDoctors.where((doc) {
      final isOnVacation = doc.vacationDates.any((date) => _isSameDate(date, widget.date));
      return !isOnVacation &&
          !selectedIds.contains(doc.id) &&
          !assignedOtherShiftIds.contains(doc.id);
    }).toList();
  }

  List<NurseModel> _getFilteredNurses(int currentIndex) {
    final selectedIds = selectedNurses
        .asMap()
        .entries
        .where((entry) => entry.key != currentIndex && entry.value != null)
        .map((entry) => entry.value!.id)
        .toSet();

    final shiftIdsOnSameDay = widget.shiftViews
        .where((s) => _isSameDate(s.startTime, widget.date))
        .map((s) => s.id)
        .where((id) => id != widget.shiftId)
        .toSet();

    final assignedOtherShiftIds = widget.assignments
        .where((a) => a.role == 0 && shiftIdsOnSameDay.contains(a.shiftId))
        .map((a) => a.userId)
        .toSet();

    return availableNurses.where((nurse) {
      final isOnVacation = nurse.vacationDates.any((date) => _isSameDate(date, widget.date));
      return !isOnVacation &&
          !selectedIds.contains(nurse.id) &&
          !assignedOtherShiftIds.contains(nurse.id);
    }).toList();
  }




  bool _isSameDate(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  DateTime getDateTimeWithDayFix(DateTime date, int hour, int minute) {
    if (hour == 0 && minute == 0) {
      // Если время 00:00, значит это полночь следующего дня
      return DateTime(date.year, date.month, date.day).add(
          const Duration(days: 1));
    }
    return DateTime(date.year, date.month, date.day, hour, minute);
  }


  void _saveShift() async {
    try {
      final assignedDoctorIds = selectedDoctors.whereType<DoctorModel>().map((
          e) => e.id).toList();
      final assignedNurseIds = selectedNurses.whereType<NurseModel>().map((
          e) => e.id).toList();

      int shiftId = widget.shiftId;

      // Если shiftId == -1, значит надо проверить существует ли смена с таким временем и департаментом
      if (shiftId == -1) {
        // Получаем смены по дате и департаменту
        final shifts = await ApiClient.getShiftsByDateAndDepartment(
            widget.departmentId, widget.date);

        final startHour = widget.startTime?.hour ?? 8;
        final startMinute = widget.startTime?.minute ?? 0;
        final endHour = widget.endTime?.hour ?? 16;
        final endMinute = widget.endTime?.minute ?? 0;

        final startTime = getDateTimeWithDayFix(
            widget.date, startHour, startMinute);
        final endTime = getDateTimeWithDayFix(widget.date, endHour, endMinute);

        final defaultShift = ShiftViewModel(
          id: -1,
          startTime: startTime,
          endTime: endTime,
          requiredDoctors: 0,
          requiredNurses: 0,
          departmentId: widget.departmentId,
        );

        final existingShift = shifts.firstWhere(
              (s) =>
          s.startTime.hour == startHour && s.endTime.hour == endHour &&
              s.departmentId == widget.departmentId,
          orElse: () => defaultShift,
        );

        if (existingShift.id != -1) {
          // Смена уже есть — обновляем её через API
          final updatedShift = ShiftBindingModel(
            id: existingShift.id,
            startTime: startTime,
            endTime: endTime,
            requiredDoctors: requiredDoctors,
            requiredNurses: requiredNurses,
            departmentId: widget.departmentId,
          );

          final updateSuccess = await ApiClient.updateShift(updatedShift);


          if (!updateSuccess) {
            throw Exception('Не удалось обновить смену');
          }

          shiftId = existingShift.id;
        } else {
          // Смены нет — создаём новую
          final created = await ApiClient.createShift(
            shift: ShiftBindingModel(
              startTime: startTime,
              endTime: endTime,
              requiredDoctors: requiredDoctors,
              requiredNurses: requiredNurses,
              departmentId: widget.departmentId,
            ),
          );

          if (!created) {
            throw Exception('Не удалось создать смену');
          }

          final newShifts = await ApiClient.getShiftsByDateAndDepartment(
              widget.departmentId, widget.date);
          final newShift = newShifts.firstWhere(
                (s) =>
            s.startTime.hour == startHour && s.endTime.hour == endHour &&
                s.departmentId == widget.departmentId,
            orElse: () => throw Exception('Не удалось получить id смены'),
          );
          shiftId = newShift.id;
        }
      }

      // Получаем существующее расписание
      final existingSchedule = await ApiClient.getScheduleByDateAndDepartment(
          widget.departmentId, widget.date);

      int scheduleId;

      if (existingSchedule.isNotEmpty) {
        scheduleId = existingSchedule.first.id;
      } else {
        // Создаём новое расписание
        final scheduleCreated = await ApiClient.createSchedule(
          schedule: ScheduleBindingModel(
            date: widget.date,
            departmentId: widget.departmentId,
            assignments: [],
            shifts: [], // Передаем пустой список смен
          ),
        );


        if (!scheduleCreated) {
          throw Exception('Не удалось создать расписание');
        }

        final newSchedule = await ApiClient.getScheduleByDateAndDepartment(
            widget.departmentId, widget.date);
        if (newSchedule.isEmpty) {
          throw Exception('Не удалось получить id расписания после создания');
        }

        scheduleId = newSchedule.first.id;
      }

      // Формируем назначения (assignments)
      final assignments = <ScheduleAssignmentBindingModel>[
        ...assignedDoctorIds.map((id) =>
            ScheduleAssignmentBindingModel(
              shiftId: shiftId,
              staffId: id,
              role: 1,
              scheduleId: scheduleId,
            )),
        ...assignedNurseIds.map((id) =>
            ScheduleAssignmentBindingModel(
              shiftId: shiftId,
              staffId: id,
              role: 0,
              scheduleId: scheduleId,
            )),
      ];

      // Существующие назначения
      final existingAssignments = widget.assignments;

      // Ключи новых назначений
      final newAssignmentsSet = assignments.map((a) => '${a.role}_${a.staffId}')
          .toSet();

      for (final old in existingAssignments) {
        print('Удаляем назначение: user=${old.userId}, scheduleId=${old
            .scheduleId}');
        if (old.scheduleId == null) {
          throw Exception(
              'У назначения отсутствует scheduleId (user: ${old.userId})');
        }

        final key = '${old.role}_${old.userId}';
        if (!newAssignmentsSet.contains(key)) {
          final success = await ApiClient.removeAssignment(
            shiftId: old.shiftId,
            staffId: old.userId,
            role: old.role,
            scheduleId: old.scheduleId!,
          );
          if (!success) {
            throw Exception(
                'Не удалось удалить устаревшее назначение: user ${old.userId}');
          }
        }
      }


      // Добавляем новые назначения
      // Ключи уже существующих назначений
      final existingAssignmentsSet = existingAssignments
          .map((a) => '${a.role}_${a.userId}')
          .toSet();

      for (final assignment in assignments) {
        final key = '${assignment.role}_${assignment.staffId}';
        if (existingAssignmentsSet.contains(key)) {
          // Назначение уже существует — пропускаем
          continue;
        }

        final success = await ApiClient.addAssignment(assignment);
        if (!success) {
          throw Exception(
              'Не удалось добавить назначение для пользователя ${assignment
                  .staffId}');
        }
      }


      Navigator.of(context).pop();
    } catch (e) {
      print('Ошибка сохранения: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка: $e')),
      );
    }
  }


  DoctorModel? _findDoctorById(int userId) {
    for (final doc in availableDoctors) {
      if (doc.id == userId) return doc;
    }
    return null;
  }

  NurseModel? _findNurseById(int userId) {
    for (final nurse in availableNurses) {
      if (nurse.id == userId) return nurse;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Редактирование смены ${widget.shiftId} - '
              '${widget.date.day.toString().padLeft(2, '0')}.'
              '${widget.date.month.toString().padLeft(2, '0')}.'
              '${widget.date.year}',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    initialValue: requiredDoctors.toString(),
                    decoration: const InputDecoration(
                        labelText: 'Врачей требуется'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final count = int.tryParse(val) ?? 1;
                      setState(() {
                        requiredDoctors = count;
                        if (count > selectedDoctors.length) {
                          selectedDoctors.addAll(
                            List<DoctorModel?>.filled(
                                count - selectedDoctors.length, null),
                          );
                        } else if (count < selectedDoctors.length) {
                          selectedDoctors = selectedDoctors.sublist(0, count);
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: requiredNurses.toString(),
                    decoration: const InputDecoration(
                        labelText: 'Медсестёр требуется'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final count = int.tryParse(val) ?? 1;
                      setState(() {
                        requiredNurses = count;
                        if (count > selectedNurses.length) {
                          selectedNurses.addAll(
                            List<NurseModel?>.filled(
                                count - selectedNurses.length, null),
                          );
                        } else if (count < selectedNurses.length) {
                          selectedNurses = selectedNurses.sublist(0, count);
                        }
                      });
                    },
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: availableDoctors.isEmpty || availableNurses.isEmpty
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                children: [
                  const Text(
                    'Выбор врачей:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(requiredDoctors, (index) {
                    if (index >= selectedDoctors.length) return Container();
                    final selected = selectedDoctors[index];

                    final filteredDoctors = _getFilteredDoctors(index);

                    final value = (selected != null && !selected.vacationDates.any((date) => _isSameDate(date, widget.date)))
                        ? filteredDoctors.firstWhereOrNull((d) => d.id == selected.id)
                        : null;


                    return DropdownButtonFormField<DoctorModel>(
                      value: value,
                      items: _getFilteredDoctors(index).map((doc) {
                        return DropdownMenuItem<DoctorModel>(
                          value: doc,
                          child: Text(doc.fullname),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedDoctors[index] = val;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Врач №${index + 1}'),
                    );
                  }),

                  const SizedBox(height: 16),
                  const Text(
                    'Выбор медсестёр:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(requiredNurses, (index) {
                    if (index >= selectedNurses.length) return Container();
                    final selected = selectedNurses[index];

                    final filteredNurses = _getFilteredNurses(index);

                    final value = (selected != null && !selected.vacationDates.any((date) => _isSameDate(date, widget.date)))
                        ? filteredNurses.firstWhereOrNull((n) => n.id == selected.id)
                        : null;


                    return DropdownButtonFormField<NurseModel>(
                      value: value,
                      items: _getFilteredNurses(index).map((nurse) {
                        return DropdownMenuItem<NurseModel>(
                          value: nurse,
                          child: Text(nurse.fullname),
                        );
                      }).toList(),
                      onChanged: (val) {
                        setState(() {
                          selectedNurses[index] = val;
                        });
                      },
                      decoration: InputDecoration(labelText: 'Медсестра №${index + 1}'),
                    );
                  }),

                ],
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _saveShift,
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
