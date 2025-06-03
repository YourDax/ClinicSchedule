import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/user_model.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:5167/api';

  // Обновляем регистрацию с новыми параметрами
  static Future<UserModel?> register(
      String fullname,
      String login,
      String password,
      DateTime birthdate,
      String phoneNumber,
      UserRole role,
      ) async {
    final response = await http.post(
      Uri.parse('$baseUrl/User/Register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'fullname': fullname,
        'login': login,
        'password': password,
        'birthdate': birthdate.toIso8601String(),
        'phoneNumber': phoneNumber,
        'role': role.index,  // отправляем как int
      }),
    );

    if (response.statusCode == 200) {
      return UserModel.fromJson(jsonDecode(response.body));
    } else {
      print('Register failed: ${response.statusCode} - ${response.body}');
    }
    return null;
  }
  static Future<UserModel?> login(String login, String password) async {
    final response = await http.get(
      Uri.parse('$baseUrl/User/Login?login=$login&password=$password'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    }

    return null;
  }

}
