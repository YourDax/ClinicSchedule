enum UserRole { nurse, doctor, admin }

UserRole roleFromInt(int value) {
  switch (value) {
    case 0: return UserRole.nurse;
    case 1: return UserRole.doctor;
    case 2: return UserRole.admin;
    default: throw Exception('Invalid role value: $value');
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
    );
  }
}
