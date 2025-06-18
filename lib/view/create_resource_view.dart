import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:typed_data';
import 'package:shared_preferences/shared_preferences.dart';
import './layout/header.dart';

class Category {
  final String nomCategorie;
  final String description;

  Category({required this.nomCategorie, required this.description});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      nomCategorie: json['nomCatégorie'],
      description: json['descriptionCatégorie'],
    );
  }
}

class CreateResourcePage extends StatefulWidget {
  const CreateResourcePage({super.key});

  @override
  _CreateResourcePageState createState() => _CreateResourcePageState();
}

class _CreateResourcePageState extends State<CreateResourcePage> {
  final _formKey = GlobalKey<FormState>();
  String _title = '';
  String _message = '';
  final DateTime _selectedDate = DateTime.now();
  Uint8List? _selectedImageBytes;
  String? _utilisateurId;
  String _status = 'masque'; // <-- Forcé à 'masque'
  String _category = 'Musique';
  bool isLoading = false;

  late Future<List<Category>> futureCategories;
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    futureCategories = fetchCategories();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('idUtilisateur');
    setState(() {
      _utilisateurId = userId;
    });
  }

  Future<List<Category>> fetchCategories() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/categories'),
    );
    if (response.statusCode == 200) {
      List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Category.fromJson(json)).toList();
    } else {
      throw Exception('Erreur de chargement: ${response.statusCode}');
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _selectedImageBytes = bytes;
      });
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;
    if (_utilisateurId == null || _utilisateurId!.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non identifié')),
      );
      return;
    }

    _formKey.currentState!.save();
    setState(() => isLoading = true);

    final String? imageBase64 =
        _selectedImageBytes != null ? base64Encode(_selectedImageBytes!) : null;

    final response = await http.post(
      Uri.parse('http://localhost:3000/resources'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': _title,
        'message': _message,
        'date': _selectedDate.toIso8601String(),
        'image': imageBase64,
        'userId': _utilisateurId,
        'status': _status,
        'category': _category,
      }),
    );

    setState(() => isLoading = false);

    if (response.statusCode == 201) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ressource ajoutée avec succès !')),
      );
      Navigator.pop(context, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Erreur : ${jsonDecode(response.body)['error'] ?? 'Inconnue'}',
          ),
        ),
      );
    }
  }

  bool _categoryExists(String category, List<Category> categories) {
    return categories.any((cat) => cat.nomCategorie == category);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Intitulé *',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Veuillez entrer un titre'
                            : null,
                onSaved: (value) => _title = value!,
              ),
              const SizedBox(height: 16),
              TextFormField(
                decoration: const InputDecoration(
                  labelText: 'Message *',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Veuillez entrer un message'
                            : null,
                onSaved: (value) => _message = value!,
              ),
              const SizedBox(height: 16),
              FutureBuilder<List<Category>>(
                future: futureCategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erreur: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Text('Aucune catégorie');
                  } else {
                    categories = snapshot.data!;
                    if (!_categoryExists(_category, categories)) {
                      _category = categories.first.nomCategorie;
                    }
                    return DropdownButtonFormField<String>(
                      value: _category,
                      decoration: const InputDecoration(
                        labelText: 'Catégorie *',
                        border: OutlineInputBorder(),
                      ),
                      items:
                          categories
                              .map(
                                (cat) => DropdownMenuItem<String>(
                                  value: cat.nomCategorie,
                                  child: Text(cat.nomCategorie),
                                ),
                              )
                              .toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _category = newValue!;
                        });
                      },
                    );
                  }
                },
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.image),
                    label: const Text('Ajouter une image'),
                  ),
                  const SizedBox(width: 12),
                  if (_selectedImageBytes != null)
                    const Icon(Icons.check_circle, color: Colors.green),
                ],
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isLoading ? null : _submitForm,
                  icon:
                      isLoading
                          ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                          : const Icon(Icons.send),
                  label: const Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
