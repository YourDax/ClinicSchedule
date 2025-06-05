enum UserRole { nurse, doctor, admin }

UserRole roleFromInt(int value) {
  switch (value) {
    case 0:
      return UserRole.nurse;
    case 1:
      return UserRole.doctor;
    case 2:
      return UserRole.admin;
    default:
      throw Exception('Invalid role value: $value');
  }
}

class UserModel {
  final int id;
  final String login;
  final String password;
  final String fullname;
  final DateTime birthdate;
  final String phoneNumber;
  final List<DateTime> vacationDates;
  final UserRole role;
  final double workedHours;
  final int? departmentId;
  final int? experienceYears;

  UserModel({
    required this.id,
    required this.login,
    required this.password,
    required this.fullname,
    required this.birthdate,
    required this.phoneNumber,
    required this.vacationDates,
    required this.role,
    required this.workedHours,
    this.departmentId,
    this.experienceYears,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'],
      login: json['login'],
      password: json['password'],
      fullname: json['fullname'],
      birthdate: DateTime.parse(json['birthdate']),
      phoneNumber: json['phoneNumber'],
      vacationDates: List<String>.from(json['vacationDates'])
          .map((date) => DateTime.parse(date))
          .toList(),
      role: roleFromInt(json['role']),
      workedHours: (json['workedHours'] as num).toDouble(),
      departmentId: json['departmentId'],
      experienceYears: json['experienceYears'],
    );
  }

  UserModel copyWith({
    String? fullname,
    String? phoneNumber,
    DateTime? birthdate,
    String? password,
    String? login,
    int? departmentId,
    int? experienceYears,
  }) {
    return UserModel(
      id: this.id,
      login: login ?? this.login,
      password: password ?? this.password,
      fullname: fullname ?? this.fullname,
      birthdate: birthdate ?? this.birthdate,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      vacationDates: this.vacationDates,
      workedHours: this.workedHours,
      role: this.role,
      departmentId: departmentId ?? this.departmentId,
      experienceYears: experienceYears ?? this.experienceYears,
    );
  }
}
