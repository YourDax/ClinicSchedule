import 'package:flutter/material.dart';

class AdminHomePage extends StatelessWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        'Главная страница администратора',
        style: Theme.of(context).textTheme.titleLarge,
      ),
    );
  }
}
