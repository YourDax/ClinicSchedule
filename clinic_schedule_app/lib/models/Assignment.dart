class Assignment {
  final int shiftId;
  final int? scheduleId;
  final int userId;
  final int role; // 1 – Doctor, 0 – Nurse
  final String fullName;

  Assignment({
    required this.shiftId,
    this.scheduleId,
    required this.userId,
    required this.role,
    required this.fullName,
  });

  factory Assignment.fromJson(Map<String, dynamic> json) {
    return Assignment(
      shiftId: json['shiftId'],
      scheduleId: json['scheduleId'],
      userId: json['userId'],
      role: json['role'],
      fullName: json['fullName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shiftId': shiftId,
      'scheduleId': scheduleId,
      'staffId': userId, // поле на сервере называется staffId
      'role': role,
      // fullName мы не отправляем на API, оно используется только для отображения
    };
  }
}
