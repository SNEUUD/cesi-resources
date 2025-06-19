import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

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
  Map<int, bool> likedStatus = {};
  Map<int, int> likeCounts = {};
  Map<int, TextEditingController> commentControllers = {};
  Map<int, bool> showAllComments = {};

  // Couleurs du Design System de l'État
  static const Color bleuFrance = Color(0xFF000091);
  static const Color rougeMarianne = Color(0xFFE1000F);
  static const Color grisFrance = Color(0xFF666666);
  static const Color grisClair = Color(0xFFF6F6F6);
  static const Color vertSuccess = Color(0xFF00A95F);
  static const Color bleuCumulus = Color(0xFFE5E5F4);

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

  @override
  void dispose() {
    _searchController.dispose();
    for (var controller in commentControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<List<Map<String, dynamic>>> fetchCommentaires(int ressourceId) async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/ressources/$ressourceId/commentaires'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        throw Exception("Erreur chargement commentaires (${response.statusCode})");
      }
    } catch (e) {
      throw Exception("Erreur réseau: $e");
    }
  }

  Future<void> sendCommentaire(int ressourceId, String message) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('idUtilisateur');

    if (userId == null) {
      throw Exception("Utilisateur non connecté");
    }

    if (message.trim().isEmpty) {
      throw Exception("Le commentaire ne peut pas être vide");
    }

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/ressources/$ressourceId/commentaire'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'message': message.trim()}),
      );

      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw Exception(
          "Erreur lors de l'ajout du commentaire (${response.statusCode})",
        );
      }
    } catch (e) {
      throw Exception("Erreur réseau: $e");
    }
  }

  Future<void> fetchLikesForResource(int ressourceId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('idUtilisateur');
    if (userId == null) return;

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/ressources/$ressourceId/likes/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            likedStatus[ressourceId] = data['liked'] ?? false;
            likeCounts[ressourceId] = data['likeCount'] ?? 0;
          });
        }
      }
    } catch (e) {
      debugPrint("Erreur lors du chargement des likes: $e");
    }
  }

  Future<void> toggleLike(int ressourceId) async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('idUtilisateur');
    if (userId == null) return;

    try {
      final response = await http.post(
        Uri.parse('http://localhost:3000/interactions'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'userId': userId, 'ressourceId': ressourceId}),
      );

      if (response.statusCode == 200) {
        await fetchLikesForResource(ressourceId);
      }
    } catch (e) {
      debugPrint("Erreur lors du toggle like: $e");
    }
  }

  Future<List<dynamic>> fetchAllResources() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/ressourcesAll'),
      );

      if (response.statusCode == 200) {
        List<dynamic> ressources = jsonDecode(response.body);
        return _sortResources(ressources);
      } else {
        throw Exception('Erreur serveur (${response.statusCode})');
      }
    } catch (e) {
      throw Exception('Erreur lors du chargement des ressources: $e');
    }
  }

  List<dynamic> _sortResources(List<dynamic> ressources) {
    switch (sortBy) {
      case 'dateDesc':
        ressources.sort(
              (a, b) => (b['dateRessource'] ?? '').compareTo(a['dateRessource'] ?? ''),
        );
        break;
      case 'dateAsc':
        ressources.sort(
              (a, b) => (a['dateRessource'] ?? '').compareTo(b['dateRessource'] ?? ''),
        );
        break;
      case 'titre':
        ressources.sort(
              (a, b) => (a['titreRessource'] ?? '')
              .toString()
              .toLowerCase()
              .compareTo((b['titreRessource'] ?? '').toString().toLowerCase()),
        );
        break;
      case 'categorie':
        ressources.sort(
              (a, b) => (a['nomCatégorie'] ?? '')
              .toString()
              .toLowerCase()
              .compareTo((b['nomCatégorie'] ?? '').toString().toLowerCase()),
        );
        break;
    }
    return ressources;
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
      final titre = (ressource['titreRessource'] ?? '').toString().toLowerCase();
      final description = (ressource['messageRessource'] ?? '').toString().toLowerCase();
      final categorie = (ressource['nomCatégorie'] ?? '').toString().toLowerCase();
      return titre.contains(searchQuery) ||
          description.contains(searchQuery) ||
          categorie.contains(searchQuery);
    }).toList();
  }

  String formatDateTime(String datetime) {
    try {
      final date = DateTime.parse(datetime);
      return DateFormat('dd/MM/yyyy à HH:mm').format(date);
    } catch (e) {
      return datetime;
    }
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: rougeMarianne.withOpacity(0.3)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.error_outline,
              color: rougeMarianne,
              size: 48,
            ),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: rougeMarianne,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: const TextStyle(
                color: grisFrance,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                setState(() {
                  futureResources = fetchAllResources();
                });
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: bleuFrance,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState({required String title, required String subtitle, required IconData icon}) {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        margin: const EdgeInsets.all(24),
        constraints: const BoxConstraints(maxWidth: 600),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: grisFrance,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: grisFrance,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                subtitle,
                style: const TextStyle(
                  color: grisFrance,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildControlsBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          // Section tri
          Expanded(
            flex: 1,
            child: Row(
              children: [
                const Icon(Icons.sort, color: grisFrance, size: 20),
                const SizedBox(width: 8),
                const Text(
                  "Trier par :",
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                    color: grisFrance,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 200,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: DropdownButton<String>(
                    value: sortBy,
                    underline: const SizedBox(),
                    isExpanded: true,
                    style: const TextStyle(color: grisFrance, fontSize: 14),
                    items: const [
                      DropdownMenuItem(
                        value: 'dateDesc',
                        child: Text('Date (plus récentes)'),
                      ),
                      DropdownMenuItem(
                        value: 'dateAsc',
                        child: Text('Date (plus anciennes)'),
                      ),
                      DropdownMenuItem(
                        value: 'titre',
                        child: Text('Titre'),
                      ),
                      DropdownMenuItem(
                        value: 'categorie',
                        child: Text('Catégorie'),
                      ),
                    ],
                    onChanged: onSortChanged,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(width: 24),

          // Barre de recherche
          Expanded(
            flex: 1,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: const Color(0xFFDDDDDD)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: TextField(
                controller: _searchController,
                style: const TextStyle(fontSize: 14),
                decoration: const InputDecoration(
                  hintText: "Rechercher une ressource...",
                  hintStyle: TextStyle(
                    color: Color(0xFF999999),
                    fontSize: 14,
                  ),
                  prefixIcon: Icon(Icons.search, color: grisFrance, size: 20),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 12, horizontal: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResourceCard(dynamic ressource, List<Map<String, dynamic>> comments) {
    final ressourceId = ressource['idRessource'];
    final auteur = ressource['pseudoUtilisateur'] ?? 'Auteur inconnu';

    Widget? imageWidget;
    if (ressource['imageRessource'] != null && ressource['imageRessource'].isNotEmpty) {
      try {
        imageWidget = Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            image: DecorationImage(
              image: MemoryImage(base64Decode(ressource['imageRessource'])),
              fit: BoxFit.cover,
            ),
          ),
        );
      } catch (_) {
        imageWidget = null;
      }
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 24),
      constraints: const BoxConstraints(maxWidth: 800),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (imageWidget != null) imageWidget,
          Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec catégorie et métadonnées
                Row(
                  children: [
                    if (ressource['nomCatégorie'] != null)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: bleuCumulus,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          ressource['nomCatégorie'],
                          style: const TextStyle(
                            fontSize: 12,
                            color: bleuFrance,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    const Spacer(),
                    Row(
                      children: [
                        const Icon(Icons.person_outline, size: 16, color: grisFrance),
                        const SizedBox(width: 4),
                        Text(
                          "Par $auteur",
                          style: const TextStyle(fontSize: 13, color: grisFrance),
                        ),
                        if (ressource['dateRessource'] != null) ...[
                          const SizedBox(width: 16),
                          const Icon(Icons.access_time, size: 16, color: grisFrance),
                          const SizedBox(width: 4),
                          Text(
                            formatDateTime(ressource['dateRessource']),
                            style: const TextStyle(fontSize: 13, color: grisFrance),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Titre
                Text(
                  ressource['titreRessource'] ?? 'Sans titre',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 20,
                    color: bleuFrance,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 12),

                // Description
                Text(
                  ressource['messageRessource'] ?? '',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black87,
                    height: 1.5,
                  ),
                ),
                const SizedBox(height: 20),

                // Bouton J'aime
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => toggleLike(ressourceId),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: likedStatus[ressourceId] == true
                            ? rougeMarianne.withOpacity(0.1)
                            : Colors.transparent,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: likedStatus[ressourceId] == true
                              ? rougeMarianne
                              : grisFrance.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            likedStatus[ressourceId] == true
                                ? Icons.favorite
                                : Icons.favorite_border,
                            size: 18,
                            color: likedStatus[ressourceId] == true
                                ? rougeMarianne
                                : grisFrance,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            likeCounts[ressourceId]?.toString() ?? '0',
                            style: TextStyle(
                              fontSize: 14,
                              color: likedStatus[ressourceId] == true
                                  ? rougeMarianne
                                  : grisFrance,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Divider(height: 32, color: Color(0xFFE5E5E5)),

                // Section commentaires
                const Text(
                  'Commentaires',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: bleuFrance,
                  ),
                ),
                const SizedBox(height: 16),

                // Champ de commentaire
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: TextField(
                    controller: commentControllers[ressourceId],
                    maxLines: 3,
                    style: const TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Écrire un commentaire...",
                      hintStyle: TextStyle(
                        color: grisFrance.withOpacity(0.7),
                        fontSize: 14,
                      ),
                      suffixIcon: IconButton(
                        icon: const Icon(Icons.send, color: bleuFrance, size: 20),
                        onPressed: () async {
                          try {
                            await sendCommentaire(
                              ressourceId,
                              commentControllers[ressourceId]!.text,
                            );
                            commentControllers[ressourceId]!.clear();
                            setState(() {});
                          } catch (e) {
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Erreur : $e'),
                                  backgroundColor: rougeMarianne,
                                ),
                              );
                            }
                          }
                        },
                      ),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.all(16),
                    ),
                  ),
                ),

                // Liste des commentaires
                if (comments.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  ...comments
                      .take(showAllComments[ressourceId]! ? comments.length : 3)
                      .map((c) => Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: grisClair,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.person, size: 16, color: grisFrance),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                c['pseudo'] ?? 'Anonyme',
                                style: const TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontSize: 13,
                                  color: bleuFrance,
                                ),
                              ),
                            ),
                            Text(
                              c['dateCommentaire'] != null
                                  ? formatDateTime(c['dateCommentaire'])
                                  : '',
                              style: const TextStyle(
                                fontSize: 12,
                                color: grisFrance,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          c['messageCommentaire'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Colors.black87,
                            height: 1.4,
                          ),
                        ),
                      ],
                    ),
                  ))
                      .toList(),

                  // Bouton "Voir plus de commentaires"
                  if (!showAllComments[ressourceId]! && comments.length > 3)
                    TextButton.icon(
                      onPressed: () {
                        setState(() => showAllComments[ressourceId] = true);
                      },
                      icon: const Icon(Icons.expand_more, size: 16),
                      label: Text(
                        "Afficher les ${comments.length - 3} commentaires restants",
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: TextButton.styleFrom(
                        foregroundColor: bleuFrance,
                        padding: EdgeInsets.zero,
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset('assets/icons/logo.png', height: 40),
            const SizedBox(width: 16),
            const Text(
              'Toutes les ressources',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 20,
                color: bleuFrance,
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: bleuFrance,
        elevation: 0,
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(1),
          child: Divider(height: 1, color: Color(0xFFE5E5E5)),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: bleuFrance),
          onPressed: () {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (_) => const HomePage()),
                  (route) => false,
            );
          },
        ),
      ),
      backgroundColor: grisClair,
      body: Column(
        children: [
          _buildControlsBar(),
          const Divider(height: 1, color: Color(0xFFE5E5E5)),

          Expanded(
            child: FutureBuilder<List<dynamic>>(
              future: futureResources,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(bleuFrance),
                    ),
                  );
                } else if (snapshot.hasError) {
                  return _buildErrorState('${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildEmptyState(
                    title: 'Aucune ressource disponible',
                    subtitle: '',
                    icon: Icons.folder_open,
                  );
                } else {
                  final ressources = filterResources(snapshot.data!);
                  if (ressources.isEmpty) {
                    return _buildEmptyState(
                      title: 'Aucune ressource trouvée',
                      subtitle: 'Essayez de modifier vos critères de recherche',
                      icon: Icons.search_off,
                    );
                  }

                  return Center(
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 1200),
                      child: ListView.builder(
                        padding: const EdgeInsets.all(24),
                        itemCount: ressources.length,
                        itemBuilder: (context, index) {
                          final ressource = ressources[index];
                          final ressourceId = ressource['idRessource'];

                          if (!likedStatus.containsKey(ressourceId)) {
                            fetchLikesForResource(ressourceId);
                          }
                          commentControllers.putIfAbsent(
                            ressourceId,
                                () => TextEditingController(),
                          );
                          showAllComments.putIfAbsent(ressourceId, () => false);

                          return FutureBuilder<List<Map<String, dynamic>>>(
                            future: fetchCommentaires(ressourceId),
                            builder: (context, commentSnapshot) {
                              final comments = commentSnapshot.data ?? [];
                              return _buildResourceCard(ressource, comments);
                            },
                          );
                        },
                      ),
                    ),
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