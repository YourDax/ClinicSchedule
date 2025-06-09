import 'user_model.dart';

class NurseModel extends UserModel {
  final int departmentId;
  final String? specialization; // новое поле

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
    this.specialization, // инициализация нового поля
  });
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is NurseModel &&
              runtimeType == other.runtimeType &&
              id == other.id;

  @override
  int get hashCode => id.hashCode;
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
      specialization: json['specialization'], // читаем specialization из JSON (может быть null)
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'login': login,
      'password': password,
      'fullname': fullname,
      'birthdate': birthdate.toIso8601String(),
      'phoneNumber': phoneNumber,
      'vacationDates': vacationDates.map((d) => d.toIso8601String()).toList(),
      'role': role.index,
      'workedHours': workedHours,
      'departmentId': departmentId,
      'specialization': specialization,
    };
  }
}
