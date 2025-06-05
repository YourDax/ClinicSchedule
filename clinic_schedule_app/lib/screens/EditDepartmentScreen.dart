import 'package:flutter/material.dart';
import '../api/api_client.dart';
import '../models/department_model.dart';

class EditDepartmentScreen extends StatefulWidget {
  final DepartmentModel? department; // null для создания

  const EditDepartmentScreen({Key? key, this.department}) : super(key: key);

  @override
  State<EditDepartmentScreen> createState() => _EditDepartmentScreenState();
}

class _EditDepartmentScreenState extends State<EditDepartmentScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.department?.name ?? '');
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    final data = {
      'name': _nameController.text.trim(),
    };

    if (widget.department != null) {
      data['id'] = widget.department!.id.toString();
    }


    try {
      if (widget.department == null) {
        await ApiClient.createDepartment(data);
      } else {
        await ApiClient.updateDepartment(data);
      }
      Navigator.pop(context, true);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при сохранении: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isNew = widget.department == null;
    return Scaffold(
      appBar: AppBar(
        title: Text(isNew ? 'Создать отделение' : 'Редактировать отделение'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Название отделения'),
                validator: (val) => val == null || val.trim().isEmpty ? 'Введите название' : null,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                child: Text(isNew ? 'Создать' : 'Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
