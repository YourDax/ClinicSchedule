import 'StaffMember.dart';

class ScheduleCell {
  final int id;
  final DateTime date;
  final int departmentId;
  final List<StaffMember> assignments;

  // Новые поля для обязательного количества
  final int requiredDoctors;
  final int requiredNurses;

  ScheduleCell({
    required this.id,
    required this.date,
    required this.departmentId,
    required this.assignments,
    this.requiredDoctors = 1,  // Значения по умолчанию
    this.requiredNurses = 1,
  });

  factory ScheduleCell.fromJson(Map<String, dynamic> json) {
    return ScheduleCell(
      id: json['id'] ?? 0,
      date: DateTime.parse(json['date']),
      departmentId: json['departmentId'] ?? 0,
      assignments: (json['assignments'] as List<dynamic>?)
          ?.map((e) => StaffMember.fromJson(e))
          .toList() ??
          [],
      // Парсим новые поля, если они есть в json, иначе по умолчанию
      requiredDoctors: json['requiredDoctors'] ?? 1,
      requiredNurses: json['requiredNurses'] ?? 1,
    );
  }
}
