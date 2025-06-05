import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';
import 'EditProfileScreen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _refreshUser();
  }

  Future<void> _refreshUser() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final userProvider = Provider.of<UserProvider>(context, listen: false);
    try {
      await userProvider.loadUserFromApi();
    } catch (e) {
      _error = e.toString();
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(child: Text('Ошибка загрузки: $_error'))
          : user == null
          ? const Center(child: Text('Нет данных о пользователе'))
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('ФИО: ${user.fullname}'),
            Text('Роль: ${user.role.name}'),
            Text('Телефон: ${user.phoneNumber}'),
            Text('Дата рождения: ${user.birthdate.toLocal().toString().split(' ')[0]}'),
            Text('Отработано часов: ${user.workedHours}'),
            const SizedBox(height: 16),
            const Text('Отпуск:'),
            for (final date in user.vacationDates)
              Text(date.toLocal().toString().split(' ')[0]),
            const SizedBox(height: 24),
            Center(
              child: ElevatedButton(
                child: const Text('Редактировать профиль'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => EditProfileScreen(user: user),
                    ),
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

