import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'layout/header.dart';

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

class CategoriesPage extends StatefulWidget {
  const CategoriesPage({Key? key}) : super(key: key);

  @override
  State<CategoriesPage> createState() => _CategoriesPageState();
}

class _CategoriesPageState extends State<CategoriesPage> {
  late Future<List<Category>> futureCategories;
  final TextEditingController _searchController = TextEditingController();
  List<Category> allCategories = [];
  List<Category> filteredCategories = [];

  @override
  void initState() {
    super.initState();
    futureCategories = fetchCategories();
    futureCategories.then((categories) {
      setState(() {
        allCategories = categories;
        filteredCategories = categories;
      });
    });

    _searchController.addListener(() {
      filterCategories(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterCategories(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredCategories = allCategories;
      });
    } else {
      setState(() {
        filteredCategories =
            allCategories
                .where(
                  (category) => category.nomCategorie.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      });
    }
  }

  Future<List<Category>> fetchCategories() async {
    try {
      // Remplacez l'URL par celle de votre API
      final response = await http.get(
        Uri.parse('http://localhost:3000/categories'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Category.fromJson(json)).toList();
      } else {
        throw Exception(
          'Échec de chargement des catégories: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
  }

  // Couleurs pour différentes catégories
  Color getCategoryColor(int index) {
    final colors = [
      Colors.blue,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.amber,
      Colors.blue,
    ];
    return colors[index % colors.length];
  }

  // Couleurs d'arrière-plan pour différentes catégories
  Color getCategoryBgColor(int index) {
    final colors = [
      Colors.blue.shade50,
      Colors.red.shade50,
      Colors.blue.shade50,
      Colors.green.shade50,
      Colors.amber.shade50,
      Colors.blue.shade50,
    ];
    return colors[index % colors.length];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Titre de la page
              const Text(
                'Catégories',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0000CC),
                ),
              ),
              const SizedBox(height: 8),
              // Description
              const Text(
                'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                style: TextStyle(fontSize: 12, color: Colors.black54),
              ),
              const SizedBox(height: 16),
              // Champ de recherche
              Row(
                children: [
                  const Text(
                    'Rechercher : ',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Rechercher une catégorie',
                          border: InputBorder.none,
                          suffixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Grille de catégories
              Expanded(
                child: FutureBuilder<List<Category>>(
                  future: futureCategories,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    } else if (!snapshot.hasData ||
                        filteredCategories.isEmpty) {
                      return const Center(
                        child: Text('Aucune catégorie trouvée'),
                      );
                    } else {
                      return GridView.builder(
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              mainAxisSpacing: 16,
                              crossAxisSpacing: 16,
                              childAspectRatio: 0.9,
                            ),
                        itemCount: filteredCategories.length,
                        itemBuilder: (context, index) {
                          Category category = filteredCategories[index];
                          return _buildCategoryCard(
                            category.nomCategorie,
                            category.description,
                            getCategoryBgColor(index),
                            getCategoryColor(index),
                          );
                        },
                      );
                    }
                  },
                ),
              ),
              // Bouton Voir plus
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    // Action pour voir plus
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0000CC),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  child: const Text('En voir plus'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String title,
    String description,
    Color bgColor,
    Color buttonColor,
  ) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade300),
      ),
      color: bgColor,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0000CC),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const Spacer(),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  // Action pour voir les ressources liées
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF0000CC),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  minimumSize: const Size(100, 30),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: const Text(
                  'Voir les ressources liées',
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
