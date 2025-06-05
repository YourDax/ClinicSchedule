import 'package:flutter/material.dart';
import '../../models/department_model.dart';
import '../api/api_client.dart';
import 'EditStaffScreen.dart';


class ManageStaffScreen extends StatefulWidget {
  const ManageStaffScreen({super.key});

  @override
  State<ManageStaffScreen> createState() => _ManageStaffScreenState();
}

class _ManageStaffScreenState extends State<ManageStaffScreen> {
  String _selectedRole = 'Доктор';
  int? _selectedDepartmentId;

  List<DepartmentModel> _departments = [];
  List<dynamic> _staffList = [];

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      final departments = await ApiClient.getDepartments();
      setState(() {
        _departments = departments;
        if (departments.isNotEmpty) {
          _selectedDepartmentId = departments.first.id;
        }
      });
      await _loadStaff();
    } catch (e) {
      print('Ошибка при загрузке департаментов: $e');
    }
  }

  Future<void> _loadStaff() async {
    if (_selectedDepartmentId == null) return;

    try {
      if (_selectedRole == 'Доктор') {
        final doctors = await ApiClient.getDoctorsByDepartment(
            _selectedDepartmentId!);
        setState(() {
          _staffList = doctors;
        });
      } else {
        final nurses = await ApiClient.getNursesByDepartment(
            _selectedDepartmentId!);
        setState(() {
          _staffList = nurses;
        });
      }
    } catch (e) {
      print('Ошибка при загрузке персонала: $e');
    }
  }

  void _onRoleChanged(String? value) {
    if (value == null) return;
    setState(() {
      _selectedRole = value;
    });
    _loadStaff();
  }

  void _onDepartmentChanged(int? value) {
    if (value == null) return;
    setState(() {
      _selectedDepartmentId = value;
    });
    _loadStaff();
  }

  void _onCreatePressed() {
    if (_selectedDepartmentId == null) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditStaffScreen(
              isDoctor: _selectedRole == 'Доктор',
              departmentId: _selectedDepartmentId!,
            ),
      ),
    ).then((_) => _loadStaff());
  }

  void _onEditPressed(dynamic staff) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            EditStaffScreen(
              isDoctor: _selectedRole == 'Доктор',
              staffData: staff,
              departmentId: _selectedDepartmentId!,
            ),
      ),
    ).then((_) => _loadStaff());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Медперсонал')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('Тип:'),
                const SizedBox(width: 8),
                DropdownButton<String>(
                  value: _selectedRole,
                  items: const [
                    DropdownMenuItem(value: 'Доктор', child: Text('Доктор')),
                    DropdownMenuItem(
                        value: 'Медсестра', child: Text('Медсестра')),
                  ],
                  onChanged: _onRoleChanged,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                const Text('Отделение:'),
                const SizedBox(width: 8),
                DropdownButton<int>(
                  value: _selectedDepartmentId,
                  items: _departments
                      .map((d) =>
                      DropdownMenuItem(
                        value: d.id,
                        child: Row(
                          children: [
                            const Icon(Icons.local_hospital, size: 20),
                            const SizedBox(width: 8),
                            Text(d.name),
                          ],
                        ),
                      ))
                      .toList(),
                  onChanged: _onDepartmentChanged,
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _onCreatePressed,
              icon: const Icon(Icons.add),
              label: const Text('Создать'),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: _staffList.length,
                itemBuilder: (context, index) {
                  final staff = _staffList[index];
                  return ListTile(
                    title: Text(staff.fullname),
                    subtitle: Text(staff.phoneNumber),
                    trailing: const Icon(Icons.edit),
                    onTap: () => _onEditPressed(staff),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
