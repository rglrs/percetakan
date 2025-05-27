import 'package:flutter/material.dart';
import 'package:percetakan/pages/main_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Percetakan Vizada',
      debugShowCheckedModeBanner: false,
      home: const MainScreen(),
    );
  }
}
