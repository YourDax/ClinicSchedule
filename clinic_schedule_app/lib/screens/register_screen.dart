import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_client.dart';
import '../models/NurseSpecialization.dart';
import '../models/user_model.dart';
import '../models/department_model.dart';
import '../providers/user_provider.dart';

// Добавьте enum NurseSpecialization в отдельный файл и импортируйте сюда

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _loginController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _fullnameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _experienceController = TextEditingController();

  DateTime? _birthdate;
  UserRole? _selectedRole;
  DepartmentModel? _selectedDepartment;
  NurseSpecialization? _selectedNurseSpecialization;

  List<DepartmentModel> _departments = [];

  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDepartments();
  }

  Future<void> _loadDepartments() async {
    try {
      final deps = await ApiClient.getDepartments();
      setState(() {
        _departments = deps;
      });
    } catch (e) {
      setState(() {
        _error = 'Не удалось загрузить департаменты';
      });
    }
  }

  Future<void> _pickBirthdate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(1990),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthdate = picked;
      });
    }
  }

  void _submit() async {
    if (!_formKey.currentState!.validate()) return;

    if (_birthdate == null) {
      setState(() => _error = 'Выберите дату рождения');
      return;
    }

    if (_selectedRole == null) {
      setState(() => _error = 'Выберите роль');
      return;
    }

    if ((_selectedRole == UserRole.nurse || _selectedRole == UserRole.doctor) &&
        _selectedDepartment == null) {
      setState(() => _error = 'Выберите департамент');
      return;
    }

    if (_selectedRole == UserRole.nurse && _selectedNurseSpecialization == null) {
      setState(() => _error = 'Выберите специализацию медсестры');
      return;
    }

    if (_selectedRole == UserRole.doctor) {
      final expText = _experienceController.text.trim();
      if (expText.isEmpty || int.tryParse(expText) == null) {
        setState(() => _error = 'Введите корректный опыт работы в годах');
        return;
      }
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final user = await ApiClient.register(
        _fullnameController.text.trim(),
        _loginController.text.trim(),
        _passwordController.text.trim(),
        _birthdate!,
        _phoneController.text.trim(),
        _selectedRole!,
        _selectedDepartment?.id,
        experienceYears: _selectedRole == UserRole.doctor
            ? int.parse(_experienceController.text.trim())
            : null,
        nurseSpecialization: _selectedRole == UserRole.nurse
            ? _selectedNurseSpecialization
            : null,
      );

      if (user != null) {
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() => _error = 'Ошибка регистрации');
      }
    } catch (e) {
      setState(() => _error = 'Ошибка: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Регистрация')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _loginController,
                decoration: const InputDecoration(labelText: 'Логин'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Введите логин' : null,
              ),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Пароль'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Введите пароль' : null,
              ),
              TextFormField(
                controller: _fullnameController,
                decoration: const InputDecoration(labelText: 'Полное имя'),
                validator: (value) =>
                value == null || value.isEmpty ? 'Введите имя' : null,
              ),
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Телефон'),
                keyboardType: TextInputType.phone,
                validator: (value) =>
                value == null || value.isEmpty ? 'Введите телефон' : null,
              ),
              const SizedBox(height: 12),
              ListTile(
                title: Text(_birthdate == null
                    ? 'Выберите дату рождения'
                    : 'Дата рождения: ${_birthdate!.toLocal()}'.split(' ')[0]),
                trailing: const Icon(Icons.calendar_today),
                onTap: _pickBirthdate,
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<UserRole>(
                value: _selectedRole,
                decoration: const InputDecoration(labelText: 'Роль'),
                items: const [
                  DropdownMenuItem(
                      value: UserRole.nurse, child: Text('Медсестра')),
                  DropdownMenuItem(value: UserRole.doctor, child: Text('Доктор')),
                ],
                onChanged: (role) {
                  setState(() {
                    _selectedRole = role;
                    _selectedDepartment = null;
                    _selectedNurseSpecialization = null;
                    _experienceController.clear();
                  });
                },
                validator: (value) => value == null ? 'Выберите роль' : null,
              ),
              if (_selectedRole == UserRole.nurse) ...[
                DropdownButtonFormField<NurseSpecialization>(
                  value: _selectedNurseSpecialization,
                  decoration: const InputDecoration(labelText: 'Специализация'),
                  items: NurseSpecialization.values.map((spec) {
                    return DropdownMenuItem(
                      value: spec,
                      child: Text(spec.displayName),
                    );
                  }).toList(),
                  onChanged: (spec) =>
                      setState(() => _selectedNurseSpecialization = spec),
                  validator: (value) =>
                  value == null ? 'Выберите специализацию' : null,
                ),
              ],
              if (_selectedRole == UserRole.nurse || _selectedRole == UserRole.doctor)
                DropdownButtonFormField<DepartmentModel>(
                  value: _selectedDepartment,
                  decoration: const InputDecoration(labelText: 'Департамент'),
                  items: _departments.map((dep) {
                    return DropdownMenuItem(
                      value: dep,
                      child: Text(dep.name),
                    );
                  }).toList(),
                  onChanged: (dep) => setState(() => _selectedDepartment = dep),
                  validator: (value) =>
                  value == null ? 'Выберите департамент' : null,
                ),
              if (_selectedRole == UserRole.doctor) ...[
                TextFormField(
                  controller: _experienceController,
                  decoration:
                  const InputDecoration(labelText: 'Опыт работы (лет)'),
                  keyboardType: TextInputType.number,
                  validator: (value) {
                    if (_selectedRole == UserRole.doctor) {
                      if (value == null || value.isEmpty) {
                        return 'Введите опыт работы';
                      }
                      if (int.tryParse(value) == null) {
                        return 'Введите число';
                      }
                    }
                    return null;
                  },
                ),
              ],
              if (_error != null) ...[
                const SizedBox(height: 12),
                Text(_error!, style: const TextStyle(color: Colors.red)),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _submit,
                child:
                _loading ? const CircularProgressIndicator() : const Text('Зарегистрироваться'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
