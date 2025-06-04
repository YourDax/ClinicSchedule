class ShiftBindingModel {
  final int? id;
  final DateTime startTime;
  final DateTime endTime;
  final int requiredDoctors;
  final int requiredNurses;
  final int departmentId;

  ShiftBindingModel({
    this.id,
    required this.startTime,
    required this.endTime,
    required this.requiredDoctors,
    required this.requiredNurses,
    required this.departmentId,
  });

  Map<String, dynamic> toJson() => {
    if (id != null) 'id': id,
    'startTime': startTime.toIso8601String(),
    'endTime': endTime.toIso8601String(),
    'requiredDoctors': requiredDoctors,
    'requiredNurses': requiredNurses,
    'departmentId': departmentId,
  };
}