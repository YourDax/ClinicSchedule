import 'package:flutter/material.dart';
import '../models/Assignment.dart';
import '../models/ScheduleAssignmentBindingModel.dart';
import '../models/ScheduleBindingModel.dart';
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
        selectedDoctors.addAll(List<DoctorModel?>.filled(requiredDoctors - selectedDoctors.length, null));
      }

      selectedNurses = List<NurseModel?>.from(assignedNurses);
      if (selectedNurses.length < requiredNurses) {
        selectedNurses.addAll(List<NurseModel?>.filled(requiredNurses - selectedNurses.length, null));
      }
    });
  }


  Future<void> _loadAvailableStaff() async {
    try {
      final doctors = await ApiClient.getDoctorsByDepartment(widget.departmentId);
      final nurses = await ApiClient.getNursesByDepartment(widget.departmentId);

      final doctorIds = doctors.map((e) => e.id).toSet();
      final nurseIds = nurses.map((e) => e.id).toSet();

      final additionalDoctors = <DoctorModel>[];
      final additionalNurses = <NurseModel>[];

      for (final a in widget.assignments) {
        if (a.role == 1 && !doctorIds.contains(a.userId)) {
          final doctor = await ApiClient.getDoctorById(a.userId);
          if (doctor != null) additionalDoctors.add(doctor);
        } else if (a.role == 0 && !nurseIds.contains(a.userId)) {
          final nurse = await ApiClient.getNurseById(a.userId);
          if (nurse != null) additionalNurses.add(nurse);
        }
      }

      setState(() {
        availableDoctors = [...doctors, ...additionalDoctors];
        availableNurses = [...nurses, ...additionalNurses];

        selectedDoctors = widget.assignments
            .where((a) => a.role == 1)
            .map((a) => availableDoctors.firstWhere((d) => d.id == a.userId))
            .toList();

        selectedNurses = widget.assignments
            .where((a) => a.role == 0)
            .map((a) => availableNurses.firstWhere((n) => n.id == a.userId))
            .toList();
      });

      _loadAssignments();
    } catch (e) {
      print('Ошибка загрузки персонала: $e');
    }
  }

  DateTime getDateTimeWithDayFix(DateTime date, int hour, int minute) {
    if (hour == 0 && minute == 0) {
      // Если время 00:00, значит это полночь следующего дня
      return DateTime(date.year, date.month, date.day).add(const Duration(days: 1));
    }
    return DateTime(date.year, date.month, date.day, hour, minute);
  }


  void _saveShift() async {
    try {
      final assignedDoctorIds = selectedDoctors.whereType<DoctorModel>().map((e) => e.id).toList();
      final assignedNurseIds = selectedNurses.whereType<NurseModel>().map((e) => e.id).toList();

      int shiftId = widget.shiftId;

      // Если shiftId == -1, значит надо проверить существует ли смена с таким временем и департаментом
      if (shiftId == -1) {
        // Получаем смены по дате и департаменту
        final shifts = await ApiClient.getShiftsByDateAndDepartment(widget.departmentId, widget.date);

        final startHour = widget.startTime?.hour ?? 8;
        final startMinute = widget.startTime?.minute ?? 0;
        final endHour = widget.endTime?.hour ?? 16;
        final endMinute = widget.endTime?.minute ?? 0;

        final startTime = getDateTimeWithDayFix(widget.date, startHour, startMinute);
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
              (s) => s.startTime.hour == startHour && s.endTime.hour == endHour && s.departmentId == widget.departmentId,
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

          final newShifts = await ApiClient.getShiftsByDateAndDepartment(widget.departmentId, widget.date);
          final newShift = newShifts.firstWhere(
                (s) => s.startTime.hour == startHour && s.endTime.hour == endHour && s.departmentId == widget.departmentId,
            orElse: () => throw Exception('Не удалось получить id смены'),
          );
          shiftId = newShift.id;
        }
      }

      // Получаем существующее расписание
      final existingSchedule = await ApiClient.getScheduleByDateAndDepartment(widget.departmentId, widget.date);

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
            shifts: [],  // Передаем пустой список смен
          ),
        );


        if (!scheduleCreated) {
          throw Exception('Не удалось создать расписание');
        }

        final newSchedule = await ApiClient.getScheduleByDateAndDepartment(widget.departmentId, widget.date);
        if (newSchedule.isEmpty) {
          throw Exception('Не удалось получить id расписания после создания');
        }

        scheduleId = newSchedule.first.id;
      }

      // Формируем назначения (assignments)
      final assignments = <ScheduleAssignmentBindingModel>[
        ...assignedDoctorIds.map((id) => ScheduleAssignmentBindingModel(
          shiftId: shiftId,
          staffId: id,
          role: 1,
          scheduleId: scheduleId,
        )),
        ...assignedNurseIds.map((id) => ScheduleAssignmentBindingModel(
          shiftId: shiftId,
          staffId: id,
          role: 0,
          scheduleId: scheduleId,
        )),
      ];

      // Существующие назначения
      final existingAssignments = widget.assignments;

      // Ключи новых назначений
      final newAssignmentsSet = assignments.map((a) => '${a.role}_${a.staffId}').toSet();

      for (final old in existingAssignments) {
        print('Удаляем назначение: user=${old.userId}, scheduleId=${old.scheduleId}');
        if (old.scheduleId == null) {
          throw Exception('У назначения отсутствует scheduleId (user: ${old.userId})');
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
            throw Exception('Не удалось удалить устаревшее назначение: user ${old.userId}');
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
          throw Exception('Не удалось добавить назначение для пользователя ${assignment.staffId}');
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
        title: Text('Редактирование смены ${widget.shiftId} - ${widget.date.day}.${widget.date.month}.${widget.date.year}'),
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
                    decoration: const InputDecoration(labelText: 'Врачей требуется'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final count = int.tryParse(val) ?? 1;
                      setState(() {
                        if (count > selectedDoctors.length) {
                          selectedDoctors.addAll(List<DoctorModel?>.filled(count - selectedDoctors.length, null));
                        } else if (count < selectedDoctors.length) {
                          selectedDoctors = selectedDoctors.sublist(0, count);
                        }
                        requiredDoctors = count;
                      });
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: TextFormField(
                    initialValue: requiredNurses.toString(),
                    decoration: const InputDecoration(labelText: 'Медсестёр требуется'),
                    keyboardType: TextInputType.number,
                    onChanged: (val) {
                      final count = int.tryParse(val) ?? 1;
                      setState(() {
                        if (count > selectedNurses.length) {
                          selectedNurses.addAll(List<NurseModel?>.filled(count - selectedNurses.length, null));
                        } else if (count < selectedNurses.length) {
                          selectedNurses = selectedNurses.sublist(0, count);
                        }
                        requiredNurses = count;
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
                  const Text('Выбор врачей:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...List.generate(requiredDoctors, (index) {
                    if (index >= selectedDoctors.length) return Container();
                    final selected = selectedDoctors[index];
                    final value = (selected != null && availableDoctors.contains(selected)) ? selected : null;

                    return DropdownButtonFormField<DoctorModel>(
                      value: value,
                      items: availableDoctors.map((doc) {
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
                  const Text('Выбор медсестёр:', style: TextStyle(fontWeight: FontWeight.bold)),
                  ...List.generate(requiredNurses, (index) {
                    if (index >= selectedNurses.length) return Container();
                    final selected = selectedNurses[index];
                    final value = (selected != null && availableNurses.contains(selected)) ? selected : null;

                    return DropdownButtonFormField<NurseModel>(
                      value: value,
                      items: availableNurses.map((nurse) {
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
