import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/user_provider.dart';
import '../../models/user_model.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = Provider.of<UserProvider>(context).user;

    return Scaffold(
      body: user == null
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
          ],
        ),
      ),
    );
  }
}
