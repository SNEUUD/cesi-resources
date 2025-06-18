import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class AllResourcesView extends StatefulWidget {
  const AllResourcesView({super.key});

  @override
  State<AllResourcesView> createState() => _AllResourcesViewState();
}

class _AllResourcesViewState extends State<AllResourcesView> {
  late Future<List<dynamic>> futureResources;
  String sortBy = 'dateDesc';
  String searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    futureResources = fetchAllResources();
    _searchController.addListener(() {
      setState(() {
        searchQuery = _searchController.text.trim().toLowerCase();
      });
    });
  }

  Future<List<dynamic>> fetchAllResources() async {
    final response = await http.get(
      Uri.parse('http://10.173.129.67:3000/ressourcesAll'),
    );
    if (response.statusCode == 200) {
      List<dynamic> ressources = jsonDecode(response.body);

      // Tri local selon le choix
      if (sortBy == 'dateDesc') {
        ressources.sort(
          (a, b) =>
              (b['dateRessource'] ?? '').compareTo(a['dateRessource'] ?? ''),
        );
      } else if (sortBy == 'dateAsc') {
        ressources.sort(
          (a, b) =>
              (a['dateRessource'] ?? '').compareTo(b['dateRessource'] ?? ''),
        );
      } else if (sortBy == 'titre') {
        ressources.sort(
          (a, b) => (a['titre'] ?? '').toString().toLowerCase().compareTo(
            (b['titre'] ?? '').toString().toLowerCase(),
          ),
        );
      } else if (sortBy == 'categorie') {
        ressources.sort(
          (a, b) => (a['nomCategorie'] ?? '')
              .toString()
              .toLowerCase()
              .compareTo((b['nomCategorie'] ?? '').toString().toLowerCase()),
        );
      }
      return ressources;
    } else {
      throw Exception('Erreur lors du chargement des ressources');
    }
  }

  void onSortChanged(String? value) {
    if (value != null) {
      setState(() {
        sortBy = value;
        futureResources = fetchAllResources();
      });
    }
  }

  List<dynamic> filterResources(List<dynamic> ressources) {
    if (searchQuery.isEmpty) return ressources;
    return ressources.where((ressource) {
      final titre = (ressource['titre'] ?? '').toString().toLowerCase();
      final description =
          (ressource['description'] ?? '').toString().toLowerCase();
      final categorie =
          (ressource['nomCategorie'] ?? '').toString().toLowerCase();
      return titre.contains(searchQuery) ||
          description.contains(searchQuery) ||
          categorie.contains(searchQuery);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Toutes les ressources'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF000091),
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                const Text(
                  "Trier par :",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                DropdownButton<String>(
                  value: sortBy,
                  items: const [
                    DropdownMenuItem(
                      value: 'dateDesc',
                      child: Text('Date (plus récentes)'),
                    ),
                    DropdownMenuItem(
                      value: 'dateAsc',
                      child: Text('Date (plus anciennes)'),
                    ),
                    DropdownMenuItem(value: 'titre', child: Text('Titre')),
                    DropdownMenuItem(
                      value: 'categorie',
                      child: Text('Catégorie'),
                    ),
                  ],
                  onChanged: onSortChanged,
                ),
                const Spacer(),
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: InputDecoration(
                      hintText: "Rechercher...",
                      prefixIcon: const Icon(Icons.search),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(
                        vertical: 0,
                        horizontal: 10,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: futureResources,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur : ${snapshot.error}'));
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(child: Text('Aucune ressource trouvée.'));
                } else {
                  final ressources = filterResources(snapshot.data!);
                  if (ressources.isEmpty) {
                    return const Center(
                      child: Text('Aucune ressource trouvée.'),
                    );
                  }
                  return ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: ressources.length,
                    itemBuilder: (context, index) {
                      final ressource = ressources[index];

                      Widget imageWidget;
                      if (ressource['imageRessource'] != null &&
                          ressource['imageRessource'].isNotEmpty) {
                        try {
                          imageWidget = Image.memory(
                            base64Decode(ressource['imageRessource']),
                            width: double.infinity,
                            height: 300,
                            fit: BoxFit.cover,
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
                          child: const Icon(
                            Icons.image_not_supported,
                            size: 80,
                          ),
                        );
                      }

                      return Center(
                        child: SizedBox(
                          width: 400,
                          child: Card(
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
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
                                      if (ressource['nomCategorie'] != null)
                                        Text(
                                          "Catégorie : ${ressource['nomCategorie']}",
                                          style: const TextStyle(
                                            fontSize: 13,
                                            color: Colors.deepPurple,
                                            fontWeight: FontWeight.w500,
                                          ),
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
                          ),
                        ),
                      );
                    },
                  );
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
