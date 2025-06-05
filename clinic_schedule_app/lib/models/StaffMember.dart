class StaffMember {
  final int id;
  final int scheduleId;
  final int shiftId;
  final int staffId;
  final int role;
  final String fullName;
  final DateTime? shiftStartTime;

  final int? departmentId;
  final String? departmentName; // для удобства отображения
  final DateTime? birthdate;
  final List<DateTime> vacationDates;
  final double? workedHours;
  final int? experienceYears; // для докторов
  final String? specialization; // для медсестёр

  StaffMember({
    required this.id,
    required this.scheduleId,
    required this.shiftId,
    required this.staffId,
    required this.role,
    required this.fullName,
    this.shiftStartTime,
    this.departmentId,
    this.departmentName,
    this.birthdate,
    this.vacationDates = const [],
    this.workedHours,
    this.experienceYears,
    this.specialization,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    // Пример парсинга с учетом новых полей, можно адаптировать под ваш json
    return StaffMember(
      id: json['id'] ?? 0,
      scheduleId: json['scheduleId'] ?? 0,
      shiftId: json['shiftId'] ?? 0,
      staffId: json['staffId'] ?? 0,
      role: json['role'] ?? 0,
      fullName: json['fullName'] ?? 'Неизвестно',
      shiftStartTime: json['shiftStartTime'] != null ? DateTime.tryParse(json['shiftStartTime']) : null,
      departmentId: json['departmentId'],
      departmentName: json['departmentName'],
      birthdate: json['birthdate'] != null ? DateTime.tryParse(json['birthdate']) : null,
      vacationDates: (json['vacationDates'] as List<dynamic>?)
          ?.map((d) => DateTime.tryParse(d) ?? DateTime.now())
          .toList() ?? [],
      workedHours: (json['workedHours'] != null) ? (json['workedHours'] as num).toDouble() : null,
      experienceYears: json['experienceYears'],
      specialization: json['specialization'],
    );
  }
}
