import 'package:clinic_schedule_app/screens/welcomeScreen.dart';
import 'package:flutter/material.dart';
import 'providers/user_provider.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const ClinicApp());
}

class ClinicApp extends StatelessWidget {
  const ClinicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: MaterialApp(
        title: 'Клиника',
        theme: ThemeData(primarySwatch: Colors.blue),
        home: const WelcomeScreen(),
      ),
    );
  }
}


