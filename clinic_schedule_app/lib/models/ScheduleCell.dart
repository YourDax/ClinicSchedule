import 'StaffMember.dart';

class ScheduleCell {
  final int id;
  final DateTime date;
  final int departmentId;
  final List<StaffMember> assignments;

  ScheduleCell({
    required this.id,
    required this.date,
    required this.departmentId,
    required this.assignments,
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
    );
  }
}
