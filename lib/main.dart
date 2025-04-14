import 'package:flutter/material.dart';
import 'page_accueil.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: '(re)sources relationnelles',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primaryColor: const Color(0xFF000080),
        fontFamily: 'Montserrat',
      ),
      home: const HomePage(),
    );
  }
}