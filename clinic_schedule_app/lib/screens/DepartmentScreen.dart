import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/department_model.dart';
import 'EditDepartmentScreen.dart';

class DepartmentsScreen extends StatefulWidget {
  const DepartmentsScreen({Key? key}) : super(key: key);

  @override
  State<DepartmentsScreen> createState() => _DepartmentsScreenState();
}

class _DepartmentsScreenState extends State<DepartmentsScreen> {
  List<DepartmentModel> _departments = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final departments = await ApiClient.getDepartments();
      setState(() {
        _departments = departments;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка загрузки отделений: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _openEditDepartment(DepartmentModel? department) async {
    // department == null — создание нового отделения
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditDepartmentScreen(department: department),
      ),
    );

    if (result == true) {
      _loadDepartments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Отделения')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Создать отделение'),
              onPressed: () => _openEditDepartment(null),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _departments.length,
              itemBuilder: (context, index) {
                final department = _departments[index];
                return ListTile(
                  title: Text(department.name),
                  subtitle: Text('ID: ${department.id}'),
                  onTap: () => _openEditDepartment(department),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
