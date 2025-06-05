class UniversalUserUpdateModel {
  final int id;
  final String login;
  final String? password;
  final String fullname;
  final DateTime? birthdate;
  final String? phoneNumber;
  final List<DateTime>? vacationDates;
  final double? workedHours;
  final int role;
  final int? departmentId;
  final int? experienceYears;

  UniversalUserUpdateModel({
    required this.id,
    required this.login,
    this.password,
    required this.fullname,
    this.birthdate,
    this.phoneNumber,
    this.vacationDates,
    this.workedHours,
    required this.role,
    this.departmentId,
    this.experienceYears,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'password': password,
      'fullname': fullname,
      'birthdate': birthdate?.toIso8601String(),
      'phoneNumber': phoneNumber,
      'vacationDates': vacationDates?.map((d) => d.toIso8601String()).toList(),
      'workedHours': workedHours,
      'role': role,
      'departmentId': departmentId,
      'experienceYears': experienceYears,
    };
  }
}
