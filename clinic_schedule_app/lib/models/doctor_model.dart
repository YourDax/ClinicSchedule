import 'user_model.dart';

class DoctorModel extends UserModel {
  final int experienceYears;
  final int departmentId;

  DoctorModel({
    required super.id,
    required super.login,
    required super.password,
    required super.fullname,
    required super.birthdate,
    required super.phoneNumber,
    required super.vacationDates,
    required super.role,
    required super.workedHours,
    required this.experienceYears,
    required this.departmentId,
  });

  factory DoctorModel.fromJson(Map<String, dynamic> json) {
    return DoctorModel(
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
      experienceYears: json['experienceYears'],
      departmentId: json['departmentId'],
    );
  }
}
