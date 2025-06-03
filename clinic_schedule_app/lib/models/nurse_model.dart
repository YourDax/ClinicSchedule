import 'user_model.dart';

class NurseModel extends UserModel {
  final int departmentId;

  NurseModel({
    required super.id,
    required super.login,
    required super.password,
    required super.fullname,
    required super.birthdate,
    required super.phoneNumber,
    required super.vacationDates,
    required super.role,
    required super.workedHours,
    required this.departmentId,
  });

  factory NurseModel.fromJson(Map<String, dynamic> json) {
    return NurseModel(
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
    );
  }
}
