import 'StaffMember.dart';

class ScheduleCell {
  final int id;
  final DateTime date;
  final int departmentId;
  final List<StaffMember> assignments;

  final List<Shift> shiftViews; // non-nullable

  final int requiredDoctors;
  final int requiredNurses;

  ScheduleCell({
    required this.id,
    required this.date,
    required this.departmentId,
    required this.assignments,
    required this.shiftViews,
    this.requiredDoctors = 1,
    this.requiredNurses = 1,
  });

  factory ScheduleCell.fromJson(Map<String, dynamic> json) {
    return ScheduleCell(
      id: json['id'] ?? 0,
      date: DateTime.parse(json['date']),
      departmentId: json['departmentId'] ?? 0,
      assignments: (json['assignments'] as List<dynamic>?)
          ?.map((e) => StaffMember.fromJson(e))
          .toList() ?? [],
      shiftViews: (json['shiftViews'] as List<dynamic>?)
          ?.map((e) => Shift.fromJson(e))
          .toList() ?? [],  // вот тут гарантируем non-null список
      requiredDoctors: json['requiredDoctors'] ?? 1,
      requiredNurses: json['requiredNurses'] ?? 1,
    );
  }
}


class Shift {
  final int id;
  final DateTime startTime;

  Shift({
    required this.id,
    required this.startTime,
  });

  factory Shift.fromJson(Map<String, dynamic> json) {
    return Shift(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']), // формат даты-времени в json
    );
  }
}
