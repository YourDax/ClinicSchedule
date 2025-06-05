import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../models/StaffMember.dart';
import '../models/department_model.dart';
import '../models/doctor_model.dart';
import '../models/nurse_model.dart';

enum StaffRole { nurse, doctor, all }


class StaffStatisticsScreen extends StatefulWidget {
  const StaffStatisticsScreen({Key? key}) : super(key: key);

  @override
  _StaffStatisticsScreenState createState() => _StaffStatisticsScreenState();
}

class _StaffStatisticsScreenState extends State<StaffStatisticsScreen> {
  DepartmentModel? selectedDepartment;
  List<DepartmentModel> departments = [];

  StaffRole selectedRole = StaffRole.all;

  List<StaffMember> staffList = [];

  @override
  void initState() {
    super.initState();
    _loadStaff(); // загрузить изначально всех сотрудников
    _loadDepartments();
  }

  // Переводим полученных из API докторов и медсестёр в StaffMember
  StaffMember _doctorToStaffMember(DoctorModel doctor, String departmentName) {
    return StaffMember(
      id: doctor.id,
      scheduleId: 0,
      shiftId: 0,
      staffId: doctor.id,
      role: 1, // например, 1 = доктор
      fullName: doctor.fullname,
      departmentId: doctor.departmentId,
      departmentName: departmentName,
      birthdate: doctor.birthdate,
      vacationDates: doctor.vacationDates,
      workedHours: doctor.workedHours,
      experienceYears: doctor.experienceYears,
      specialization: null,
    );
  }

  StaffMember _nurseToStaffMember(NurseModel nurse, String departmentName) {
    return StaffMember(
      id: nurse.id,
      scheduleId: 0,
      shiftId: 0,
      staffId: nurse.id,
      role: 0, // например, 0 = медсестра
      fullName: nurse.fullname,
      departmentId: nurse.departmentId,
      departmentName: departmentName,
      birthdate: nurse.birthdate,
      vacationDates: nurse.vacationDates,
      workedHours: nurse.workedHours,
      experienceYears: null,
      specialization: nurse.specialization,
    );
  }
  String getDepartmentNameById(int? id) {
    if (id == null) return '-';
    final dept = departments.firstWhere((d) => d.id == id, orElse: () => DepartmentModel(id: 0, name: '-'));
    return dept.name;
  }

  Future<void> _loadDepartments() async {
    try {
      final loadedDepartments = await ApiClient.getDepartments();
      setState(() {
        departments = loadedDepartments;
      });
    } catch (e) {
      print('Ошибка загрузки отделений: $e');
    }
  }

  Future<void> _loadStaff() async {
    try {
      List<StaffMember> loadedStaff = [];

      final deptId = selectedDepartment?.id;

      if (selectedRole == StaffRole.all || selectedRole == StaffRole.doctor) {
        final doctors = deptId != null
            ? await ApiClient.getDoctorsByDepartment(deptId)
            : await ApiClient.getDoctorList();

        loadedStaff.addAll(
          doctors.map((d) => _doctorToStaffMember(d, getDepartmentNameById(d.departmentId))),
        );
      }

      if (selectedRole == StaffRole.all || selectedRole == StaffRole.nurse) {
        final nurses = deptId != null
            ? await ApiClient.getNursesByDepartment(deptId)
            : await ApiClient.getNurseList();

        loadedStaff.addAll(
          nurses.map((n) => _nurseToStaffMember(n, getDepartmentNameById(n.departmentId))),
        );
        print('Загружено медсестёр: ${nurses.length}');
      }

      setState(() {
        staffList = loadedStaff;
      });
    } catch (e) {
      print('Ошибка загрузки данных: $e');
    }
  }


  // Подсчёт количества по текущему списку staffList
  int get countDoctors =>
      staffList.where((staff) => staff.role == StaffRole.doctor.index).length;

  int get countNurses =>
      staffList.where((staff) => staff.role == StaffRole.nurse.index).length;

  String formatVacations(List<DateTime> dates) {
    if (dates.isEmpty) return '-';
    return dates.map((d) => '${d.day}.${d.month}.${d.year}').join(', ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Статистика по медперсоналу'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Выбор департамента
            DropdownButton<DepartmentModel?>(
              value: selectedDepartment,
              hint: const Text('Выберите отделение'),
              isExpanded: true,
              items: [
                const DropdownMenuItem<DepartmentModel?>(
                  value: null,
                  child: Text('Все отделения'),
                ),
                ...departments.map(
                      (d) => DropdownMenuItem<DepartmentModel>(
                    value: d,
                    child: Text(d.name),
                  ),
                ),
              ],
              onChanged: (value) {
                setState(() {
                  selectedDepartment = value;
                });
                _loadStaff();
              },
            ),

            // Выбор роли
            DropdownButton<StaffRole>(
              value: selectedRole,
              isExpanded: true,
              items: const [
                DropdownMenuItem(
                  value: StaffRole.all,
                  child: Text('Все роли'),
                ),
                DropdownMenuItem(
                  value: StaffRole.doctor,
                  child: Text('Доктор'),
                ),
                DropdownMenuItem(
                  value: StaffRole.nurse,
                  child: Text('Медсестра'),
                ),
              ],
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedRole = value;
                  });
                  _loadStaff();
                }
              },
            ),

            const SizedBox(height: 16),

            // Статистика по выбранному департаменту и роли
            if (selectedDepartment != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('В отделении "${selectedDepartment!.name}":'),
                  Text('Докторов: $countDoctors'),
                  Text('Медсестёр: $countNurses'),
                  const SizedBox(height: 12),
                ],
              )
            else if (selectedRole != StaffRole.all)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Всего в системе:'),
                  if (selectedRole == StaffRole.doctor) Text('Докторов: $countDoctors'),
                  if (selectedRole == StaffRole.nurse) Text('Медсестёр: $countNurses'),
                  const SizedBox(height: 12),
                ],
              )
            else
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Всего в системе:'),
                  Text('Докторов: $countDoctors'),
                  Text('Медсестёр: $countNurses'),
                  const SizedBox(height: 12),
                ],
              ),


            // Таблица
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical, // вертикальная прокрутка
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal, // горизонтальная прокрутка
                  child: DataTable(
                    columns: const [
                      DataColumn(label: Text('Роль')),
                      DataColumn(label: Text('Имя')),
                      DataColumn(label: Text('Отделение')),
                      DataColumn(label: Text('Дата рождения')),
                      DataColumn(label: Text('Отработанные часы')),
                      DataColumn(label: Text('Даты отпусков')),
                      DataColumn(label: Text('Стаж / Специализация')),
                    ],
                    rows: staffList.map((staff) {
                      return DataRow(cells: [
                        DataCell(Text(staff.role == 1 ? 'Доктор' : 'Медсестра')),
                        DataCell(Text(staff.fullName)),
                        DataCell(Text(staff.departmentName!)),
                        DataCell(Text('${staff.birthdate?.day}.${staff.birthdate?.month}.${staff.birthdate?.year}')),
                        DataCell(Text(staff.workedHours.toString())),
                        DataCell(Text(formatVacations(staff.vacationDates))),
                        DataCell(Text(
                          staff.role == StaffRole.doctor.index
                              ? '${staff.experienceYears ?? "-"} лет'
                              : staff.specialization ?? '-',
                        )),
                      ]);
                    }).toList(),
                  ),
                ),
              ),
            ),

          ],
        ),
      ),
    );
  }
}
