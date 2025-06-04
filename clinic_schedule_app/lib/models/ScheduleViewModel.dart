import 'ScheduleAssignmentViewModel.dart';

class ScheduleViewModel {
  final int id;
  final DateTime date;
  final int departmentId;
  final List<ScheduleAssignmentViewModel> assignments;
  final int requiredDoctors;
  final int requiredNurses;

  ScheduleViewModel({
    required this.id,
    required this.date,
    required this.departmentId,
    required this.assignments,
    required this.requiredDoctors,
    required this.requiredNurses,
  });

  factory ScheduleViewModel.fromJson(Map<String, dynamic> json) {
    return ScheduleViewModel(
      id: json['id'],
      date: DateTime.parse(json['date']),
      departmentId: json['departmentId'],
      requiredDoctors: json['requiredDoctors'],
      requiredNurses: json['requiredNurses'],
      assignments: (json['assignments'] as List<dynamic>)
          .map((e) => ScheduleAssignmentViewModel.fromJson(e))
          .toList(),
    );
  }
}
