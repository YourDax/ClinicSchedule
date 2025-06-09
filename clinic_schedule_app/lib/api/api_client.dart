import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/NurseSpecialization.dart';
import '../models/ScheduleAssignmentBindingModel.dart';
import '../models/ScheduleBindingModel.dart';
import '../models/ScheduleCell.dart';
import '../models/ScheduleViewModel.dart';
import '../models/ShiftBindingModel.dart';
import '../models/ShiftDetails.dart';
import '../models/ShiftViewModel.dart';
import '../models/UniversalUserUpdateModel.dart';
import '../models/department_model.dart';
import '../models/doctor_model.dart';
import '../models/nurse_model.dart';
import '../models/user_model.dart';

class ApiClient {
  static const String baseUrl = 'http://10.0.2.2:5167/api';

  static Future<List<DepartmentModel>> getDepartments() async {
    final url = Uri.parse('$baseUrl/Main/GetDepartmentList');
    print('\n==== API GET DEPARTMENTS ====');
    print('GET $url');

    final response = await http.get(url);

    print('Response Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    print('================================\n');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => DepartmentModel.fromJson(e)).toList();
    }

    throw Exception('Не удалось загрузить департаменты');
  }
  static Future<void> updateUser(UniversalUserUpdateModel model) async {
    final url = Uri.parse('$baseUrl/User/UpdateData');
    print('ApiClient: updateUser POST $url');
    print('Payload: ${jsonEncode(model.toJson())}');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(model.toJson()),
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode != 200) {
      throw Exception('Failed to update user: ${response.body}');
    }
  }
  static Future<UserModel> getUserById(int id, int role) async {
    final url = Uri.parse('$baseUrl/User/GetById?id=$id&role=$role');
    print('ApiClient.getUserById: GET $url');

    final response = await http.get(url);

    if (response.statusCode == 200) {
      print('ApiClient.getUserById: success');
      final data = jsonDecode(response.body);
      return UserModel.fromJson(data);
    } else {
      print('ApiClient.getUserById: failed with status ${response.statusCode}');
      throw Exception('Ошибка загрузки пользователя: ${response.statusCode}');
    }
  }

  static Future<void> deleteScheduleByDate({
    required int departmentId,
    required DateTime date,
  }) async {
    final response = await http.delete(
      Uri.parse('$baseUrl/Main/DeleteByDate?departmentId=$departmentId&date=${date.toIso8601String()}'),
      headers: {'Content-Type': 'application/json'},
    );

    if (response.statusCode != 200) {
      throw Exception('Не удалось удалить расписание');
    }
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
  static Future<void> generateSchedule(int departmentId, List<String> dates) async {
    final url = Uri.parse('$baseUrl/Main/GenerateSchedule');
    final body = jsonEncode({
      'departmentId': departmentId,
      'dates': dates,
    });

    print('\n==== API GENERATE SCHEDULE ====');
    print('POST $url');
    print('Body: $body');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
    print('==============================\n');

    if (response.statusCode != 200) {
      throw Exception('Ошибка генерации расписания');
    }
  }
  static Future<List<ScheduleCell>> getScheduleByDepartment({
    required int departmentId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final url = Uri.parse(
        '$baseUrl/Main/GetForDepartment?departmentId=$departmentId&startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}');

    print('\n==== API GET SCHEDULE BY DEPARTMENT ====');
    print('GET $url');

    final response = await http.get(url);

    print('Response status code: ${response.statusCode}');
    print('Response body: ${response.body}');
    print('========================================\n');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ScheduleCell.fromJson(e)).toList();
    } else {
      throw Exception('Не удалось загрузить расписание (код ${response.statusCode})');
    }
  }

  static Future<List<ScheduleCell>> getScheduleForUser({
    required int userId,
    required String role,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final url = Uri.parse(
      '$baseUrl/Main/GetForUser?userId=$userId&role=$role&startDate=${startDate.toIso8601String()}&endDate=${endDate.toIso8601String()}',
    );

    print('\n==== API GET SCHEDULE FOR USER ====');
    print('GET $url');

    final response = await http.get(url);

    print('Response status code: ${response.statusCode}');
    print('Response headers: ${response.headers}');
    print('Response body: ${response.body}');
    print('===================================\n');

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      return data.map((e) => ScheduleCell.fromJson(e)).toList();
    } else {
      throw Exception('Не удалось загрузить расписание (код ${response.statusCode})');
    }
  }

  static Future<int> createEmptyShift({
    required DateTime date,
    required int departmentId,
    DateTime? startTime,
    DateTime? endTime,
    int requiredDoctors = 1,
    int requiredNurses = 1,
  }) async {
    // Если время смены не передано, задаём дефолтные (например, 8:00-16:00 того же дня)
    final defaultStartTime = DateTime(date.year, date.month, date.day, 8, 0, 0);
    final defaultEndTime = DateTime(date.year, date.month, date.day, 16, 0, 0);

    final shiftStart = startTime ?? defaultStartTime;
    final shiftEnd = endTime ?? defaultEndTime;

    final url = Uri.parse('$baseUrl/Main/CreateShift');

    final body = jsonEncode({
      'startTime': shiftStart.toIso8601String(),
      'endTime': shiftEnd.toIso8601String(),
      'requiredDoctors': requiredDoctors,
      'requiredNurses': requiredNurses,
      'departmentId': departmentId,
    });

    print('\n==== API CREATE EMPTY SHIFT ====');
    print('POST $url');
    print('Request Body: $body');

    final res = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('Response Code: ${res.statusCode}');
    print('Response Headers: ${res.headers}');
    print('Response Body: ${res.body}');
    print('================================\n');

    if (res.statusCode == 200 || res.statusCode == 201) {
      final data = jsonDecode(res.body);
      return data['id'] ?? 0; // или 'shiftId' если сервер так возвращает
    } else {
      return 0;
    }
  }



  static Future<ShiftDetails> getShiftDetails(int shiftId) async {
    final url = Uri.parse('$baseUrl/GetShiftDetails?shiftId=$shiftId');

    print('\n==== API GET SHIFT DETAILS ====');
    print('GET $url');

    final res = await http.get(url);

    print('Response Code: ${res.statusCode}');
    print('Response Headers: ${res.headers}');
    print('Response Body: ${res.body}');
    print('================================\n');

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      return ShiftDetails.fromJson(data);
    } else {
      throw Exception('Failed to load shift details');
    }
  }
  static Future<List<DoctorModel>> getDoctorList() async {
    final url = Uri.parse('$baseUrl/Main/GetDoctorList');

    print('\n==== API GET DOCTOR LIST ====');
    print('GET $url');

    final res = await http.get(url);

    print('Response Code: ${res.statusCode}');
    print('Response Headers: ${res.headers}');
    print('Response Body: ${res.body}');
    print('=======================================\n');

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => DoctorModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  static Future<List<NurseModel>> getNurseList() async {
    final url = Uri.parse('$baseUrl/Main/GetNurseList');

    print('\n==== API GET NURSE LIST ====');
    print('GET $url');

    final res = await http.get(url);

    print('Response Code: ${res.statusCode}');
    print('Response Headers: ${res.headers}');
    print('Response Body: ${res.body}');
    print('=======================================\n');

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => NurseModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load nurses');
    }
  }


  static Future<List<DoctorModel>> getDoctorsByDepartment(int departmentId) async {
    final url = Uri.parse('$baseUrl/Main/GetDoctorsByDepartment?departmentId=$departmentId');

    print('\n==== API GET DOCTORS BY DEPARTMENT ====');
    print('GET $url');

    final res = await http.get(url);

    print('Response Code: ${res.statusCode}');
    print('Response Headers: ${res.headers}');
    print('Response Body: ${res.body}');
    print('=======================================\n');

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => DoctorModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load doctors');
    }
  }

  static Future<List<NurseModel>> getNursesByDepartment(int departmentId) async {
    final url = Uri.parse('$baseUrl/Main/GetNursesByDepartment?departmentId=$departmentId');

    print('\n==== API GET NURSES BY DEPARTMENT ====');
    print('GET $url');

    final res = await http.get(url);

    print('Response Code: ${res.statusCode}');
    print('Response Headers: ${res.headers}');
    print('Response Body: ${res.body}');
    print('=======================================\n');

    if (res.statusCode == 200) {
      final List data = jsonDecode(res.body);
      return data.map((e) => NurseModel.fromJson(e)).toList();
    } else {
      throw Exception('Failed to load nurses');
    }
  }
  static Future<List<ScheduleViewModel>> getScheduleByDateAndDepartment(
      int departmentId, DateTime date) async {
    final uri = Uri.parse(
        '$baseUrl/Main/GetByDateAndDepartment?departmentId=$departmentId&date=${date.toIso8601String()}');

    print('\n==== API GET SCHEDULE BY DATE AND DEPARTMENT ====');
    print('GET $uri');

    final response = await http.get(uri);

    print('Response Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    print('==================================================\n');

    if (response.statusCode == 200) {
      if (response.body.isEmpty) {
        // Вдруг тело пустое, возвращаем пустой список
        return [];
      }

      // Парсим один объект — возвращаем список с одним элементом
      final Map<String, dynamic> jsonMap = json.decode(response.body);
      return [ScheduleViewModel.fromJson(jsonMap)];
    } else if (response.statusCode == 204) {
      // Нет данных — возвращаем пустой список
      return [];
    } else {
      throw Exception('Ошибка получения расписания: ${response.reasonPhrase}');
    }
  }



  static Future<List<ShiftViewModel>> getShiftsByDateAndDepartment(
      int departmentId, DateTime date) async {
    final uri = Uri.parse('$baseUrl/Main/GetShiftsByDateAndDepartment?departmentId=$departmentId&date=${date.toIso8601String()}');
    print('Запрос: GET $uri');

    final response = await http.get(uri);
    print('Ответ ${response.statusCode}: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> jsonList = json.decode(response.body);
      return jsonList.map((json) => ShiftViewModel.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка получения смен: ${response.reasonPhrase}');
    }
  }


  static Future<void> saveShift(int shiftId, int requiredDoctors, int requiredNurses, List<int> assignedDoctors, List<int> assignedNurses) async {
    final url = Uri.parse('$baseUrl/Main/SaveShift');
    final body = jsonEncode({
      'shiftId': shiftId,
      'requiredDoctors': requiredDoctors,
      'requiredNurses': requiredNurses,
      'assignedDoctorIds': assignedDoctors,
      'assignedNurseIds': assignedNurses,
    });

    print('\n==== API SAVE SHIFT ====');
    print('POST $url');
    print('Request Headers: {Content-Type: application/json}');
    print('Request Body: $body');

    final res = await http.post(url, headers: {'Content-Type': 'application/json'}, body: body);

    print('Response Code: ${res.statusCode}');
    print('Response Headers: ${res.headers}');
    print('Response Body: ${res.body}');
    print('========================\n');

    if (res.statusCode != 200) {
      throw Exception('Failed to save shift');
    }
  }
  static Future<DoctorModel?> getDoctorById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/doctor/$id'));
    print('Response Code: ${response.statusCode}');
    print('Response Headers: ${response.headers}');
    print('Response Body: ${response.body}');
    print('========================\n');
    if (response.statusCode == 200) {
      return DoctorModel.fromJson(json.decode(response.body));
    }
    return null;
  }

  static Future<NurseModel?> getNurseById(int id) async {
    final response = await http.get(Uri.parse('$baseUrl/nurse/$id'));
    if (response.statusCode == 200) {
      return NurseModel.fromJson(json.decode(response.body));
    }
    return null;
  }

  static Future<bool> createShift({
    required ShiftBindingModel shift,
  }) async {
    final url = Uri.parse('$baseUrl/Main/CreateShift');
    final body = jsonEncode(shift.toJson());

    print('POST $url');
    print('Body: $body');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Ошибка создания смены: ${response.body}');
    }
  }


  static Future<bool> createSchedule({
    required ScheduleBindingModel schedule,
  }) async {
    final url = Uri.parse('$baseUrl/Main/CreateSchedule');
    final body = jsonEncode(schedule.toJson());

    print('POST $url');
    print('Body: $body');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: body,
    );

    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('Ошибка создания расписания: ${response.body}');
    }
  }

  static Future<bool> addAssignment(ScheduleAssignmentBindingModel model) async {
    final url = Uri.parse('$baseUrl/Main/AddAssignment');
    print('POST $url with body: ${jsonEncode(model.toJson())}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(model.toJson()),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final bool result = jsonDecode(response.body);
        return result;
      } else {
        print('Failed to add assignment: ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      print('Exception in addAssignment: $e\n$stackTrace');
      return false;
    }
  }
  static Future<bool> removeAssignment({
    required int shiftId,
    required int staffId,
    required int role,
    required int scheduleId,
  }) async {
    final url = Uri.parse('$baseUrl/Main/RemoveAssignment');
    print('POST $url with body: ${jsonEncode({
      'shiftId': shiftId,
      'staffId': staffId,
      'role': role,
      'scheduleId': scheduleId,
    })}');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'shiftId': shiftId,
          'staffId': staffId,
          'role': role,
          'scheduleId': scheduleId,
        }),
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final bool result = jsonDecode(response.body);
        return result;
      } else {
        print('Failed to remove assignment: ${response.statusCode}');
        return false;
      }
    } catch (e, stackTrace) {
      print('Exception in removeAssignment: $e\n$stackTrace');
      return false;
    }
  }

  static Future<bool> updateShift(ShiftBindingModel shift) async {
    final uri = Uri.parse('$baseUrl/Main/UpdateShift');
    final bodyJson = json.encode(shift.toJson());

    print('UpdateShift request URI: $uri');
    print('UpdateShift request body: $bodyJson');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: bodyJson,
    );

    print('UpdateShift response status: ${response.statusCode}');
    print('UpdateShift response body: ${response.body}');

    return response.statusCode == 200;
  }

  // Создание доктора
  static Future<void> createDoctor(Map<String, dynamic> model) async {
    final uri = Uri.parse('$baseUrl/Main/CreateDoctor');
    print('\n==== API CREATE DOCTOR ====');
    print('POST $uri');
    print('Request Body: ${json.encode(model)}');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(model),
    );

    print('Response Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('==========================\n');

    if (response.statusCode != 200) {
      throw Exception('Ошибка создания доктора: ${response.reasonPhrase}');
    }
  }

  // Обновление доктора
  static Future<void> updateDoctor(Map<String, dynamic> model) async {
    final uri = Uri.parse('$baseUrl/Main/UpdateDoctor');
    print('\n==== API UPDATE DOCTOR ====');
    print('POST $uri');
    print('Request Body: ${json.encode(model)}');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(model),
    );

    print('Response Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('==========================\n');

    if (response.statusCode != 200) {
      throw Exception('Ошибка обновления доктора: ${response.reasonPhrase}');
    }
  }
  static Future<void> createDepartment(Map<String, dynamic> model) async {
    final uri = Uri.parse('$baseUrl/Main/CreateDepartment');
    print('\n==== API CREATE DEPARTMENT ====');
    print('POST $uri');
    print('Request Body: ${json.encode(model)}');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(model),
    );

    print('Response Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('==============================\n');

    if (response.statusCode != 200) {
      throw Exception('Ошибка создания отделения: ${response.reasonPhrase}');
    }
  }

  // Обновление отделения
  static Future<void> updateDepartment(Map<String, dynamic> model) async {
    final uri = Uri.parse('$baseUrl/Main/UpdateDepartment');
    print('\n==== API UPDATE DEPARTMENT ====');
    print('POST $uri');
    print('Request Body: ${json.encode(model)}');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(model),
    );

    print('Response Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('==============================\n');

    if (response.statusCode != 200) {
      throw Exception('Ошибка обновления отделения: ${response.reasonPhrase}');
    }
  }
  // Создание медсестры
  static Future<void> createNurse(Map<String, dynamic> model) async {
    final uri = Uri.parse('$baseUrl/Main/CreateNurse');
    print('\n==== API CREATE NURSE ====');
    print('POST $uri');
    print('Request Body: ${json.encode(model)}');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(model),
    );

    print('Response Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('==========================\n');

    if (response.statusCode != 200) {
      throw Exception('Ошибка создания медсестры: ${response.reasonPhrase}');
    }
  }

  // Обновление медсестры
  static Future<void> updateNurse(Map<String, dynamic> model) async {
    final uri = Uri.parse('$baseUrl/Main/UpdateNurse');
    print('\n==== API UPDATE NURSE ====');
    print('POST $uri');
    print('Request Body: ${json.encode(model)}');

    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: json.encode(model),
    );

    print('Response Code: ${response.statusCode}');
    print('Response Body: ${response.body}');
    print('==========================\n');

    if (response.statusCode != 200) {
      throw Exception('Ошибка обновления медсестры: ${response.reasonPhrase}');
    }
  }









}
