import 'package:clinic_schedule_app/models/user_model.dart';

class ShiftDetails {
  final int shiftId;
  final int requiredDoctors;
  final int requiredNurses;
  final List<UserModel> assignedDoctors;
  final List<UserModel> assignedNurses;

  ShiftDetails({
    required this.shiftId,
    required this.requiredDoctors,
    required this.requiredNurses,
    required this.assignedDoctors,
    required this.assignedNurses,
  });

  factory ShiftDetails.fromJson(Map<String, dynamic> json) {
    return ShiftDetails(
      shiftId: json['shiftId'],
      requiredDoctors: json['requiredDoctors'],
      requiredNurses: json['requiredNurses'],
      assignedDoctors: (json['assignedDoctors'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e))
          .toList(),
      assignedNurses: (json['assignedNurses'] as List<dynamic>)
          .map((e) => UserModel.fromJson(e))
          .toList(),
    );
  }
}