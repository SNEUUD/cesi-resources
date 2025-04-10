import 'package:flutter/material.dart';
import 'view/layout/header.dart'; // Import du header personnalisé

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(home: const HomePage());
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(), // Utilisation du header personnalisé
      body: const Center(child: Text('Bienvenue sur la page d\'accueil !')),
    );
  }
}
