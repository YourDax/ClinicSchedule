class StaffMember {
  final int id;
  final int scheduleId;
  final int shiftId;
  final int staffId;
  final int role;
  final String fullName; // Если на сервере нет — можно оставить пустым или задавать в UI

  StaffMember({
    required this.id,
    required this.scheduleId,
    required this.shiftId,
    required this.staffId,
    required this.role,
    required this.fullName,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      id: json['id'] ?? 0,
      scheduleId: json['scheduleId'] ?? 0,
      shiftId: json['shiftId'] ?? 0,
      staffId: json['staffId'] ?? 0,
      role: json['role'] ?? 0,
      fullName: json['fullName'] ?? 'Неизвестно', // если сервер не отдаёт, можно потом добавлять
    );
  }
}
