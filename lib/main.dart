import 'package:flutter/material.dart';
import 'package:percetakan/pages/login_page.dart';
import 'package:percetakan/pages/main_screen.dart';
import 'package:intl/intl.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding Flutter sudah siap
  await initializeDateFormatting('id_ID', null);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Percetakan Vizada',
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
