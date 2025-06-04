class ScheduleAssignmentViewModel {
  final int id;
  final int scheduleId;
  final int shiftId;
  final int staffId;
  final int role;
  final String fullName;

  ScheduleAssignmentViewModel({
    required this.id,
    required this.scheduleId,
    required this.shiftId,
    required this.staffId,
    required this.role,
    required this.fullName,
  });

  factory ScheduleAssignmentViewModel.fromJson(Map<String, dynamic> json) {
    return ScheduleAssignmentViewModel(
      id: json['id'],
      scheduleId: json['scheduleId'],
      shiftId: json['shiftId'],
      staffId: json['staffId'],
      role: json['role'],
      fullName: json['fullName'],
    );
  }
}
