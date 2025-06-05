import 'package:flutter/material.dart';

import '../api/api_client.dart';
import '../models/doctor_model.dart';
import '../models/nurse_model.dart';

class EditStaffScreen extends StatefulWidget {
  final bool isDoctor;
  final int departmentId;
  final dynamic? staffData; // Предполагается DoctorModel или NurseModel

  const EditStaffScreen({
    super.key,
    required this.isDoctor,
    required this.departmentId,
    this.staffData,
  });

  @override
  State<EditStaffScreen> createState() => _EditStaffScreenState();
}

class _EditStaffScreenState extends State<EditStaffScreen> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _loginController;
  late TextEditingController _passwordController;
  late TextEditingController _fullNameController;
  late TextEditingController _phoneController;
  late TextEditingController _workedHoursController;
  late TextEditingController _experienceYearsController;
  late TextEditingController _specializationController;

  DateTime? _birthdate;

  @override
  void initState() {
    super.initState();

    final staff = widget.staffData;

    _loginController = TextEditingController(text: staff?.login ?? '');
    _passwordController = TextEditingController();
    _fullNameController = TextEditingController(text: staff?.fullname ?? '');
    _phoneController = TextEditingController(text: staff?.phoneNumber ?? '');
    _workedHoursController = TextEditingController(text: staff?.workedHours?.toString() ?? '0');
    _birthdate = staff?.birthdate;

    if (widget.isDoctor) {
      _experienceYearsController = TextEditingController(text: (staff is DoctorModel ? staff.experienceYears.toString() : '0'));
      _specializationController = TextEditingController(text: ''); // пустой, т.к. для доктора не нужен
    } else {
      _specializationController = TextEditingController(text: (staff is NurseModel ? (staff.specialization ?? '') : ''));
      _experienceYearsController = TextEditingController(text: '0'); // не нужен для медсестры
    }
  }

  @override
  void dispose() {
    _loginController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    _workedHoursController.dispose();
    _experienceYearsController.dispose();
    _specializationController.dispose();
    super.dispose();
  }
  Future<void> _selectBirthdate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = _birthdate ?? DateTime(now.year - 25);
    final picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (picked != null && picked != _birthdate) {
      setState(() {
        _birthdate = picked;
      });
    }
  }


  void _save() async {
    if (!_formKey.currentState!.validate()) return;

    if (_birthdate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, выберите дату рождения')),
      );
      return;
    }

    if (widget.staffData == null && _passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Пожалуйста, введите пароль')),
      );
      return;
    }

    final data = {
      'login': _loginController.text,
      'password': _passwordController.text, // всегда отправляем пароль (может быть пустым)
      'fullname': _fullNameController.text,
      'birthdate': _birthdate!.toIso8601String(),
      'phoneNumber': _phoneController.text,
      'workedHours': int.tryParse(_workedHoursController.text) ?? 0,
      'departmentId': widget.departmentId,
      'role': widget.isDoctor ? 1 : 0,
    };

    if (widget.isDoctor) {
      data['experienceYears'] = int.tryParse(_experienceYearsController.text) ?? 0;
    } else {
      data['specialization'] = _specializationController.text;
    }

    if (widget.staffData != null) {
      if (widget.staffData is DoctorModel) {
        data['id'] = (widget.staffData as DoctorModel).id;
      } else if (widget.staffData is NurseModel) {
        data['id'] = (widget.staffData as NurseModel).id;
      }
    }


    try {
      if (widget.staffData == null) {
        if (widget.isDoctor) {
          await ApiClient.createDoctor(data);
        } else {
          await ApiClient.createNurse(data);
        }
      } else {
        if (widget.isDoctor) {
          await ApiClient.updateDoctor(data);
        } else {
          await ApiClient.updateNurse(data);
        }
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
    final title = widget.staffData == null
        ? 'Создать ${widget.isDoctor ? "доктора" : "медсестру"}'
        : 'Редактировать ${widget.isDoctor ? "доктора" : "медсестру"}';

    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _loginController,
                decoration: const InputDecoration(labelText: 'Логин'),
                validator: (val) => val!.isEmpty ? 'Введите логин' : null,
              ),
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: 'Пароль',
                  helperText: widget.staffData == null ? null : 'Оставьте пустым, чтобы не менять',
                ),
                obscureText: true,
                validator: (val) {
                  if (widget.staffData == null && (val == null || val.isEmpty)) {
                    return 'Введите пароль';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _fullNameController,
                decoration: const InputDecoration(labelText: 'ФИО'),
                validator: (val) => val!.isEmpty ? 'Введите ФИО' : null,
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Дата рождения: '),
                  Text(_birthdate == null
                      ? 'не выбрана'
                      : '${_birthdate!.day.toString().padLeft(2, '0')}.${_birthdate!.month.toString().padLeft(2, '0')}.${_birthdate!.year}'),
                  const SizedBox(width: 16),
                  ElevatedButton(
                    onPressed: () => _selectBirthdate(context),
                    child: const Text('Выбрать'),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Телефон'),
                keyboardType: TextInputType.phone,
              ),
              const SizedBox(height: 16),
              if (widget.isDoctor)
                TextFormField(
                  controller: _experienceYearsController,
                  decoration: const InputDecoration(labelText: 'Опыт работы (лет)'),
                  keyboardType: TextInputType.number,
                )
              else
                TextFormField(
                  controller: _specializationController,
                  decoration: const InputDecoration(labelText: 'Специализация'),
                ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _workedHoursController,
                decoration: const InputDecoration(labelText: 'Отработанные часы'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _save,
                child: const Text('Сохранить'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
