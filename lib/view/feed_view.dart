import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'layout/header.dart';

class Resource {
  final int idRessource;
  final String titreRessource;
  final String messageRessource;
  final String dateRessource;
  final Uint8List? imageRessource;
  final String utilisateursIdUtilisateur;
  final String statusRessource;
  final String nomCategorie;

  Resource({
    required this.idRessource,
    required this.titreRessource,
    required this.messageRessource,
    required this.dateRessource,
    this.imageRessource,
    required this.utilisateursIdUtilisateur,
    required this.statusRessource,
    required this.nomCategorie,
  });

  factory Resource.fromJson(Map<String, dynamic> json) {
    return Resource(
      idRessource: json['idRessource'],
      titreRessource: json['titreRessource'],
      messageRessource: json['messageRessource'],
      dateRessource: json['dateRessource'],
      imageRessource:
          json['imageRessource'] != null
              ? Uint8List.fromList(
                List<int>.from(json['imageRessource']['data']),
              )
              : null,
      utilisateursIdUtilisateur: json['pseudoUtilisateur'],
      statusRessource: json['statusRessource'],
      nomCategorie: json['nomCatégorie'],
    );
  }
}

class FeedView extends StatefulWidget {
  final String categoryName;

  const FeedView({Key? key, required this.categoryName}) : super(key: key);

  @override
  State<FeedView> createState() => _FeedViewState();
}

class _FeedViewState extends State<FeedView> {
  late Future<List<Resource>> futureResources;
  final TextEditingController _searchController = TextEditingController();
  List<Resource> allResources = [];
  List<Resource> filteredResources = [];

  @override
  void initState() {
    super.initState();
    futureResources = fetchResources(widget.categoryName);
    futureResources.then((resources) {
      setState(() {
        allResources = resources;
        filteredResources = resources;
      });
    });

    _searchController.addListener(() {
      filterResources(_searchController.text);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void filterResources(String query) {
    if (query.isEmpty) {
      setState(() {
        filteredResources = allResources;
      });
    } else {
      setState(() {
        filteredResources =
            allResources
                .where(
                  (resource) => resource.titreRessource.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
                )
                .toList();
      });
    }
  }

  Future<List<Resource>> fetchResources(String categoryName) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/resources/category/$categoryName'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = jsonDecode(response.body);
        return data.map((json) => Resource.fromJson(json)).toList();
      } else {
        throw Exception(
          'Échec de chargement des ressources: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Erreur de connexion: $e');
    }
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
              Text(
                'Ressources - ${widget.categoryName}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0000CC),
                ),
              ),
              const SizedBox(height: 8),
              // Description
              Text(
                'Découvrez toutes les ressources disponibles dans la catégorie ${widget.categoryName}.',
                style: const TextStyle(fontSize: 12, color: Colors.black54),
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
                          hintText: 'Rechercher une ressource',
                          border: InputBorder.none,
                          suffixIcon: Icon(Icons.search),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Liste des ressources
              Expanded(
                child: FutureBuilder<List<Resource>>(
                  future: futureResources,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Erreur: ${snapshot.error}'));
                    } else if (!snapshot.hasData || filteredResources.isEmpty) {
                      return const Center(
                        child: Text(
                          'Aucune ressource trouvée pour cette catégorie',
                        ),
                      );
                    } else {
                      return ListView.builder(
                        itemCount: filteredResources.length,
                        itemBuilder: (context, index) {
                          Resource resource = filteredResources[index];
                          return _buildResourceCard(resource);
                        },
                      );
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResourceCard(Resource resource) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              resource.titreRessource,

              style: const TextStyle(
                fontSize: 22,
                color: Colors.black87,
                fontWeight: FontWeight.bold,
              ),
            ),

            // Affichage de l'image si disponible
            if (resource.imageRessource != null &&
                resource.imageRessource!.isNotEmpty)
              Center(
                child:
                    resource.imageRessource != null
                        ? MouseRegion(
                          cursor: SystemMouseCursors.click,
                          child: GestureDetector(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder:
                                    (_) => Dialog(
                                      backgroundColor: Colors.transparent,
                                      insetPadding: EdgeInsets.all(10),
                                      child: InteractiveViewer(
                                        child: Image.memory(
                                          resource.imageRessource!,
                                          fit: BoxFit.contain,
                                        ),
                                      ),
                                    ),
                              );
                            },
                            child: Image.memory(
                              resource.imageRessource!,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                          ),
                        )
                        : Container(), // ou une image de remplacement
              ),
            const SizedBox(height: 12),
            // Message de la ressource
            Text(
              resource.messageRessource,
              style: const TextStyle(fontSize: 16, color: Colors.black87),
            ),
            const SizedBox(height: 12),
            // Date de la ressource
            Text(
              'Publiée le: ${_formatDate(resource.dateRessource)}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            // Autres détails si nécessaire
            Text(
              'Partagée par l\'utilisateur #${resource.utilisateursIdUtilisateur}',
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),

            // Nouvelle ligne avec les actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                // Bouton Like
                _buildActionButton(
                  icon: Icons.favorite_border,
                  label: 'J\'aime',
                  onPressed: () {
                    // Fonctionnalité like à implémenter
                  },
                ),

                // Bouton Commenter
                _buildActionButton(
                  icon: Icons.comment_outlined,
                  label: 'Commenter',
                  onPressed: () {
                    // Fonctionnalité commenter à implémenter
                  },
                ),

                // Bouton Partager
                _buildActionButton(
                  icon: Icons.share,
                  label: 'Partager',
                  onPressed: () {
                    // Fonctionnalité partager à implémenter
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Méthode helper pour créer des boutons d'action
  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        IconButton(
          icon: Icon(icon, color: Colors.grey[700]),
          onPressed: onPressed,
        ),
        Text(label, style: TextStyle(color: Colors.grey[700], fontSize: 12)),
      ],
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    } catch (e) {
      return dateString;
    }
  }
}
