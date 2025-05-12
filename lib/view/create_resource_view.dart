import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
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

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: CreateResourcePage(),
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
  DateTime? _selectedDate;
  File? _selectedImage;
  String _utilisateur = '';
  String _status = 'affiche';
  String _category = 'Musique';
  late Future<List<Category>> futureCategories;
  List<Category> categories = [];

  @override
  void initState() {
    super.initState();
    futureCategories = fetchCategories();
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

    setState(() {
      if (pickedFile != null) {
        _selectedImage = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: Header(),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                decoration: InputDecoration(
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
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
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
              SizedBox(height: 16),
              TextButton.icon(
                onPressed: _pickImage,
                icon: Icon(Icons.image),
                label: Text('Choisir une image'),
              ),
              _selectedImage != null
                  ? Image.file(_selectedImage!, height: 100)
                  : Text('Aucune image sélectionnée'),
              SizedBox(height: 16),
              TextFormField(
                decoration: InputDecoration(
                  labelText: 'Identifiant utilisateur *',
                  border: OutlineInputBorder(),
                ),
                validator:
                    (value) =>
                        value == null || value.isEmpty
                            ? 'Veuillez entrer un identifiant'
                            : null,
                onSaved: (value) => _utilisateur = value!,
              ),
              SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: _status,
                items:
                    ['affiche', 'masque', 'exploite', 'suspendu']
                        .map(
                          (status) => DropdownMenuItem(
                            value: status,
                            child: Text(status),
                          ),
                        )
                        .toList(),
                onChanged: (val) => setState(() => _status = val!),
                decoration: InputDecoration(
                  labelText: 'Statut',
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 16),
              FutureBuilder<List<Category>>(
                future: futureCategories,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return Text('Erreur: ${snapshot.error}');
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Text('Aucune catégorie');
                  } else {
                    categories = snapshot.data!;
                    if (!_categoryExists(_category, categories)) {
                      _category = categories.first.nomCategorie;
                    }
                    return DropdownButtonFormField<String>(
                      value: _category,
                      decoration: InputDecoration(
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
              SizedBox(height: 16),
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      print('Titre: $_title');
                      print('Message: $_message');
                      print('Date: $_selectedDate');
                      print('Image: ${_selectedImage?.path}');
                      print('Utilisateur: $_utilisateur');
                      print('Statut: $_status');
                      print('Catégorie: $_category');
                    }
                  },
                  child: Text('Enregistrer'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  bool _categoryExists(String category, List<Category> categories) {
    return categories.any((cat) => cat.nomCategorie == category);
  }
}
