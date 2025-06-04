import 'package:flutter/material.dart';
import 'generate_schedule_screen.dart'; // твой экран для работы с расписанием

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  void _onButtonPressed(BuildContext context, String action) {
    switch (action) {
      case 'Сгенерировать/редактировать/создать расписание':
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const GenerateScheduleScreen()),
        );
        break;
      default:
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Выбрано действие: $action')),
        );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton.icon(
              onPressed: () => _onButtonPressed(context, 'Сгенерировать/редактировать/создать расписание'),
              icon: const Icon(Icons.schedule),
              label: const Text('Сгенерировать\\редактировать\\создать расписание'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _onButtonPressed(context, 'Редактировать/добавить медперсонал'),
              icon: const Icon(Icons.person_add),
              label: const Text('Редактировать/добавить медперсонал'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _onButtonPressed(context, 'Редактировать/создать отделение'),
              icon: const Icon(Icons.local_hospital),
              label: const Text('Редактировать/создать отделение'),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () => _onButtonPressed(context, 'Статистика по медперсоналу'),
              icon: const Icon(Icons.bar_chart),
              label: const Text('Статистика по медперсоналу'),
            ),
          ],
        ),
      ),
    );
  }
}
