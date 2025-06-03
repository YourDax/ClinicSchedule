import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../api/api_client.dart';
import '../models/user_model.dart';
import '../providers/user_provider.dart';

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

  DateTime? _birthdate;
  UserRole? _selectedRole;

  bool _loading = false;
  String? _error;

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
      setState(() {
        _error = 'Выберите дату рождения';
      });
      return;
    }
    if (_selectedRole == null) {
      setState(() {
        _error = 'Выберите роль';
      });
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    // В API пока предполагаем, что регистрируем только основные поля
    try {
      final user = await ApiClient.register(
        _fullnameController.text.trim(),
        _loginController.text.trim(),
        _passwordController.text.trim(),
        _birthdate!,
        _phoneController.text.trim(),
        _selectedRole!,
      );

      if (user != null) {
        // Успешная регистрация — сохранить пользователя в провайдер и перейти на главный экран
        Provider.of<UserProvider>(context, listen: false).setUser(user);
        Navigator.of(context).pushReplacementNamed('/home');
      } else {
        setState(() {
          _error = 'Ошибка регистрации';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Ошибка: $e';
      });
    } finally {
      setState(() {
        _loading = false;
      });
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
                  });
                },
                validator: (value) =>
                value == null ? 'Выберите роль' : null,
              ),
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
