import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/NurseSpecialization.dart';
import '../models/department_model.dart';
import '../models/user_model.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:5167/api';

  static Future<List<DepartmentModel>> getDepartments() async {
    final response = await http.get(Uri.parse('$baseUrl/Main/GetDepartmentList'));

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => DepartmentModel.fromJson(e)).toList();
    }

    throw Exception('Не удалось загрузить департаменты');
  }

  static Future<UserModel?> register(
      String fullname,
      String login,
      String password,
      DateTime birthdate,
      String phone,
      UserRole role,
      int? departmentId,
      {int? experienceYears, NurseSpecialization? nurseSpecialization}
      ) async {
    final url = Uri.parse('$baseUrl/User/Register');
    final Map<String, dynamic> body = {
      "fullname": fullname,
      "login": login,
      "password": password,
      "birthdate": birthdate.toIso8601String(),
      "phoneNumber": phone,
      "role": role.index,
    };

    if (role == UserRole.nurse) {
      body["departmentId"] = departmentId;
      if (nurseSpecialization != null) {
        body["specialization"] = nurseSpecialization.toString().split('.').last;
      }
    } else if (role == UserRole.doctor) {
      body["departmentId"] = departmentId;
      if (experienceYears != null) {
        body["experienceYears"] = experienceYears;
      }
    }

    print('\n==== API REGISTER ====');
    print('POST $url');
    print('Request Headers: {Content-Type: application/json}');
    print('Request Body: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('Response Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    print('======================\n');

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    }

    return null;
  }



  static Future<UserModel?> login(String login, String password) async {
    final url = Uri.parse('$baseUrl/User/Login');
    final body = {'login': login, 'password': password};

    print('\n==== API LOGIN ====');
    print('POST $url');
    print('Request Headers: {Content-Type: application/json}');
    print('Request Body: ${jsonEncode(body)}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(body),
    );

    print('Response Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    print('===================\n');

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    }

    return null;
  }
}
