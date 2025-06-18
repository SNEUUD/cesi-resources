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
  final _birthDateController = TextEditingController();

  String? _gender;

  final _formKey = GlobalKey<FormState>();

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _birthDateController.text =
            "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _register() async {
    if (_formKey.currentState!.validate()) {
      final url = Uri.parse('http://10.173.128.242:3000/register');
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nomUtilisateur': _lastNameController.text.trim(),
          'prénomUtilisateur': _firstNameController.text.trim(),
          'dateNaissanceUtilisateur': _birthDateController.text.trim(),
          'sexeUtilisateur': _gender,
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
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller, {
    bool obscure = false,
    String? Function(String?)? validator,
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
        TextFormField(
          controller: controller,
          obscureText: obscure,
          validator: validator,
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
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField(
                "Adresse mail*",
                _emailController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer une adresse mail';
                  }
                  if (!RegExp(
                    r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
                  ).hasMatch(value)) {
                    return 'Veuillez entrer une adresse mail valide';
                  }
                  return null;
                },
              ),
              _buildTextField(
                "Prénom*",
                _firstNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre prénom';
                  }
                  if (value.length > 45) {
                    return 'Le prénom ne doit pas dépasser 45 caractères';
                  }
                  return null;
                },
              ),
              _buildTextField(
                "Nom*",
                _lastNameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer votre nom';
                  }
                  if (value.length > 255) {
                    return 'Le nom ne doit pas dépasser 255 caractères';
                  }
                  return null;
                },
              ),
              _buildTextField(
                "Pseudo*",
                _usernameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un pseudo';
                  }
                  if (value.length > 45) {
                    return 'Le pseudo ne doit pas dépasser 45 caractères';
                  }
                  return null;
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Date de naissance*",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.indigo,
                    ),
                  ),
                  const SizedBox(height: 5),
                  TextFormField(
                    controller: _birthDateController,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: const Color(0xFFF1F3F6),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(25),
                        borderSide: BorderSide.none,
                      ),
                    ),
                    onTap: () => _selectDate(context),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Veuillez entrer une date de naissance';
                      }
                      if (!RegExp(r'^\d{2}/\d{2}/\d{4}$').hasMatch(value)) {
                        return 'Veuillez entrer une date au format JJ/MM/AAAA';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 15),
                ],
              ),
              const Text(
                "Sexe*",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
              Row(
                children: [
                  Radio<String>(
                    value: 'M',
                    groupValue: _gender,
                    onChanged: (String? value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                  ),
                  const Text('M'),
                  Radio<String>(
                    value: 'F',
                    groupValue: _gender,
                    onChanged: (String? value) {
                      setState(() {
                        _gender = value;
                      });
                    },
                  ),
                  const Text('F'),
                ],
              ),
              _buildTextField(
                "Mot de passe*",
                _passwordController,
                obscure: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  }
                  if (value.length > 255) {
                    return 'Le mot de passe ne doit pas dépasser 255 caractères';
                  }
                  return null;
                },
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
      ),
    );
  }
}
