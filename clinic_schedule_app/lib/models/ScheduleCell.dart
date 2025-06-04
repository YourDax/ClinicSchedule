import 'StaffMember.dart';

class ScheduleCell {
  final DateTime date;
  final int shiftNumber; // 1 или 2
  final List<StaffMember> staff;

  ScheduleCell({
    required this.date,
    required this.shiftNumber,
    required this.staff,
  });

  factory ScheduleCell.fromJson(Map<String, dynamic> json) {
    return ScheduleCell(
      date: DateTime.parse(json['date']),
      shiftNumber: json['shiftNumber'],
      staff: (json['staff'] as List)
          .map((e) => StaffMember.fromJson(e))
          .toList(),
    );
  }
}