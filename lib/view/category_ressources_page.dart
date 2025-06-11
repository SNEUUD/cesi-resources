import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CategoryResourcesPage extends StatelessWidget {
  final String nomCategorie;

  const CategoryResourcesPage({super.key, required this.nomCategorie});

  Future<List<dynamic>> fetchResources() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/ressources?categorie=$nomCategorie'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des ressources');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ressources : $nomCategorie'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF000091),
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: FutureBuilder<List<dynamic>>(
        future: fetchResources(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucune ressource trouvée.'));
          } else {
            final ressources = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: ressources.length,
              itemBuilder: (context, index) {
                final ressource = ressources[index];

                Widget imageWidget;
                if (ressource['imageRessource'] != null &&
                    ressource['imageRessource'].isNotEmpty) {
                  try {
                    imageWidget = AspectRatio(
                      aspectRatio:
                          1, // carré, tu peux ajuster selon le rendu souhaité
                      child: Image.memory(
                        base64Decode(ressource['imageRessource']),
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    );
                  } catch (_) {
                    imageWidget = Container(
                      height: 300,
                      color: Colors.grey[300],
                      child: const Icon(Icons.broken_image, size: 80),
                    );
                  }
                } else {
                  imageWidget = Container(
                    height: 300,
                    color: Colors.grey[300],
                    child: const Icon(Icons.image_not_supported, size: 80),
                  );
                }

                return Card(
                  margin: const EdgeInsets.symmetric(
                    vertical: 10,
                    horizontal: 8,
                  ),
                  elevation: 2,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(18),
                        ),
                        child: imageWidget,
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ressource['titre'] ?? 'Sans titre',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                                color: Color(0xFF000091),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              ressource['description'] ?? '',
                              style: const TextStyle(
                                fontSize: 15,
                                color: Colors.black87,
                              ),
                              maxLines: 3,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                const Icon(
                                  Icons.favorite_border,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                                const SizedBox(width: 16),
                                const Icon(
                                  Icons.comment_outlined,
                                  size: 22,
                                  color: Colors.grey,
                                ),
                                const Spacer(),
                                Text(
                                  ressource['dateRessource'] != null
                                      ? ressource['dateRessource']
                                          .toString()
                                          .split('T')
                                          .first
                                      : '',
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
