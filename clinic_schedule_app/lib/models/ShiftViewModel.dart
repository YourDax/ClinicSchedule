class ShiftViewModel {
  final int id;
  final DateTime startTime;
  final DateTime endTime;
  final int departmentId;
  final int requiredDoctors;
  final int requiredNurses;

  ShiftViewModel({
    required this.id,
    required this.startTime,
    required this.endTime,
    required this.departmentId,
    required this.requiredDoctors,
    required this.requiredNurses,
  });

  factory ShiftViewModel.fromJson(Map<String, dynamic> json) {
    return ShiftViewModel(
      id: json['id'],
      startTime: DateTime.parse(json['startTime']),
      endTime: DateTime.parse(json['endTime']),
      departmentId: json['departmentId'],
      requiredDoctors: json['requiredDoctors'],
      requiredNurses: json['requiredNurses'],
    );
  }
}
