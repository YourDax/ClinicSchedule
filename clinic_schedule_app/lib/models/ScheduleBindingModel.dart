import 'ScheduleAssignmentBindingModel.dart';
import 'ShiftBindingModel.dart'; // импорт модели смены

class ScheduleBindingModel {
  final DateTime date;
  final int departmentId;
  final List<ScheduleAssignmentBindingModel> assignments;
  final List<ShiftBindingModel> shifts;  // добавляем поле shifts

  ScheduleBindingModel({
    required this.date,
    required this.departmentId,
    required this.assignments,
    required this.shifts,  // обязательный параметр конструктора
  });

  Map<String, dynamic> toJson() => {
    'date': date.toIso8601String(),
    'departmentId': departmentId,
    'assignments': assignments.map((a) => a.toJson()).toList(),
    'shifts': shifts.map((s) => s.toJson()).toList(),  // сериализуем shifts
  };
}
