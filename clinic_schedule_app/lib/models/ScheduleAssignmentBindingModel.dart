class ScheduleAssignmentBindingModel {
  final int scheduleId;
  final int shiftId;
  final int staffId;
  final int role; // 0 - Nurse, 1 - Doctor

  ScheduleAssignmentBindingModel({
    required this.scheduleId,
    required this.shiftId,
    required this.staffId,
    required this.role,
  });

  Map<String, dynamic> toJson() => {
    'scheduleId': scheduleId,
    'shiftId': shiftId,
    'staffId': staffId,
    'role': role,
  };
}
