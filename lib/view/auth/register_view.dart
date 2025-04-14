import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _usernameController = TextEditingController();
  final _genderController = TextEditingController();
  final _birthDateController = TextEditingController();

 void _register() async {
    final url = Uri.parse(
      'http://localhost:3000/register',
    );
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'nomUtilisateur': _lastNameController.text.trim(),
        'prénomUtilisateur': _firstNameController.text.trim(),
        'dateNaissanceUtilisateur':
            _birthDateController.text.trim(),
        'sexeUtilisateur': _genderController.text.trim(),
        'pseudoUtilisateur': _usernameController.text.trim(),
        'emailUtilisateur': _emailController.text.trim(),
        'motDePasseUtilisateur': _passwordController.text.trim(),
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Inscription réussie !")));
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Erreur: ${jsonDecode(response.body)['error']}"),
        ),
      );
    }
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.indigo,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          obscureText: obscure,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF1F3F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(25),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Inscription"), centerTitle: true),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildTextField("Adresse mail*", _emailController),
            _buildTextField("Prénom*", _firstNameController),
            _buildTextField("Nom*", _lastNameController),
            _buildTextField("Pseudo*", _usernameController),
            _buildTextField("Date de naissance*", _birthDateController),
            _buildTextField("Sexe*", _genderController),
            _buildTextField(
              "Mot de passe*",
              _passwordController,
              obscure: true,
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _register,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo[900],
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: 50,
                  vertical: 15,
                ),
              ),
              child: const Text("S’inscrire", style: TextStyle(fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }
}
