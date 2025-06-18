import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  void _login() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Veuillez remplir tous les champs')),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.173.128.242:3000/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'emailUtilisateur': email,
          'motDePasseUtilisateur': password,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final utilisateur = data['utilisateur'];
        final idUtilisateur = utilisateur['id']; // ou _id selon ton API
        final pseudo = utilisateur['pseudo'];

        // Sauvegarder l'identifiant et le pseudo en session locale
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('idUtilisateur', idUtilisateur);
        await prefs.setString('pseudoUtilisateur', pseudo);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Bienvenue $pseudo !')));
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomePage()),
        );
      } else {
        final data = jsonDecode(response.body);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(data['error'] ?? 'Erreur de connexion')),
        );
      }
    } catch (e) {
      print('Erreur : $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur de connexion au serveur')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Connexion'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _passwordController,
              decoration: const InputDecoration(
                labelText: 'Mot de passe',
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: _login,
              child: const Text('Se connecter'),
            ),
          ],
        ),
      ),
    );
  }
}
