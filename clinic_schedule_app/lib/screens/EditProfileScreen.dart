import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/UniversalUserUpdateModel.dart';
import '../models/user_model.dart';
import '../api/api_client.dart';
import '../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel user;

  const EditProfileScreen({Key? key, required this.user}) : super(key: key);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _loginController;
  late TextEditingController _fullnameController;
  late TextEditingController _phoneController;
  late TextEditingController _birthdateController;
  late TextEditingController _passwordController;

  DateTime? _selectedBirthdate;

  @override
  void initState() {
    super.initState();
    _loginController = TextEditingController(text: widget.user.login);
    _fullnameController = TextEditingController(text: widget.user.fullname);
    _phoneController = TextEditingController(text: widget.user.phoneNumber ?? '');
    _passwordController = TextEditingController();
    _selectedBirthdate = widget.user.birthdate;
    _birthdateController = TextEditingController(text: _selectedBirthdate != null
        ? _selectedBirthdate!.toLocal().toString().split(' ')[0]
        : '');
  }

  @override
  void dispose() {
    _loginController.dispose();
    _fullnameController.dispose();
    _phoneController.dispose();
    _birthdateController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _pickBirthdate() async {
    final now = DateTime.now();
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedBirthdate ?? DateTime(now.year - 20),
      firstDate: DateTime(1900),
      lastDate: now,
    );
    if (date != null) {
      setState(() {
        _selectedBirthdate = date;
        _birthdateController.text = date.toLocal().toString().split(' ')[0];
      });
    }
  }

  Future<void> _save() async {
    final userProvider = Provider.of<UserProvider>(context, listen: false);

    final updatedModel = UniversalUserUpdateModel(
      id: widget.user.id,
      login: _loginController.text,
      password: _passwordController.text.isNotEmpty ? _passwordController.text : '',
      fullname: _fullnameController.text,
      birthdate: _selectedBirthdate,
      phoneNumber: _phoneController.text,
      vacationDates: widget.user.vacationDates,
      workedHours: widget.user.workedHours,
      role: widget.user.role.index,
      departmentId: widget.user.departmentId,
      experienceYears: widget.user.experienceYears,
    );


    try {
      await ApiClient.updateUser(updatedModel);
      print('Профиль успешно обновлен');
      // Обновить данные в провайдере (если нужно)
      userProvider.updateUserFromModel(updatedModel); // реализуй этот метод
      Navigator.pop(context);
    } catch (e) {
      print('Ошибка обновления профиля: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка обновления: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Редактировать профиль')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            TextField(
              controller: _loginController,
              decoration: const InputDecoration(labelText: 'Логин'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _fullnameController,
              decoration: const InputDecoration(labelText: 'ФИО'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _phoneController,
              decoration: const InputDecoration(labelText: 'Телефон'),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _birthdateController,
              decoration: const InputDecoration(labelText: 'Дата рождения'),
              readOnly: true,
              onTap: _pickBirthdate,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(labelText: 'Пароль (оставьте пустым, если не менять)'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _save,
              child: const Text('Сохранить'),
            ),
          ],
        ),
      ),
    );
  }
}
