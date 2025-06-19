import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

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
    // Dispose of all comment controllers
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
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: rougeMarianne.withOpacity(0.3)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              color: rougeMarianne,
              size: MediaQuery.of(context).size.width * 0.12,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(
              'Erreur de chargement',
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.045,
                fontWeight: FontWeight.w600,
                color: rougeMarianne,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.01),
            Text(
              error,
              style: TextStyle(
                color: grisFrance,
                fontSize: MediaQuery.of(context).size.width * 0.035,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  futureResources = fetchAllResources();
                });
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: bleuFrance,
                foregroundColor: Colors.white,
                padding: EdgeInsets.symmetric(
                  horizontal: MediaQuery.of(context).size.width * 0.08,
                  vertical: 12,
                ),
              ),
              child: Text(
                'Réessayer',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.04,
                ),
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
        padding: EdgeInsets.all(MediaQuery.of(context).size.width * 0.06),
        margin: EdgeInsets.symmetric(
          horizontal: MediaQuery.of(context).size.width * 0.04,
          vertical: 16,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: grisFrance,
              size: MediaQuery.of(context).size.width * 0.12,
            ),
            SizedBox(height: MediaQuery.of(context).size.height * 0.02),
            Text(
              title,
              style: TextStyle(
                fontSize: MediaQuery.of(context).size.width * 0.045,
                fontWeight: FontWeight.w500,
                color: grisFrance,
              ),
              textAlign: TextAlign.center,
            ),
            if (subtitle.isNotEmpty) ...[
              SizedBox(height: MediaQuery.of(context).size.height * 0.01),
              Text(
                subtitle,
                style: TextStyle(
                  color: grisFrance,
                  fontSize: MediaQuery.of(context).size.width * 0.035,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final isSmallScreen = screenWidth < 400;

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Image.asset(
              'assets/icons/logo.png',
              height: isSmallScreen ? 32 : 40,
            ),
          ],
        ),
        backgroundColor: Colors.white,
        foregroundColor: bleuFrance,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE5E5E5)),
        ),
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: bleuFrance,
            size: isSmallScreen ? 20 : 24,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      backgroundColor: grisClair,
      body: Column(
        children: [
          // Titre principal
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(
              horizontal: screenWidth * 0.04,
              vertical: screenHeight * 0.02,
            ),
            child: Text(
              'Toutes les ressources',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: screenWidth * 0.07,
                color: bleuFrance,
                height: 1.2,
              ),
            ),
          ),

          // Barre de contrôles
          Container(
            color: Colors.white,
            padding: EdgeInsets.all(screenWidth * 0.04),
            child: Column(
              children: [
                // Section tri - responsive
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.sort,
                          color: grisFrance,
                          size: isSmallScreen ? 18 : 20,
                        ),
                        SizedBox(width: screenWidth * 0.02),
                        Text(
                          "Trier par :",
                          style: TextStyle(
                            fontWeight: FontWeight.w500,
                            color: grisFrance,
                            fontSize: screenWidth * 0.035,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: screenHeight * 0.015),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.symmetric(horizontal: screenWidth * 0.03),
                      decoration: BoxDecoration(
                        border: Border.all(color: const Color(0xFFDDDDDD)),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<String>(
                        value: sortBy,
                        underline: const SizedBox(),
                        isExpanded: true,
                        style: TextStyle(
                          color: grisFrance,
                          fontSize: screenWidth * 0.035,
                        ),
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
                SizedBox(height: screenHeight * 0.02),

                // Barre de recherche
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: TextField(
                    controller: _searchController,
                    style: TextStyle(fontSize: screenWidth * 0.035),
                    decoration: InputDecoration(
                      hintText: "Rechercher une ressource...",
                      hintStyle: TextStyle(
                        color: grisFrance.withOpacity(0.7),
                        fontSize: screenWidth * 0.035,
                      ),
                      prefixIcon: Icon(
                        Icons.search,
                        color: grisFrance,
                        size: isSmallScreen ? 18 : 20,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        vertical: screenHeight * 0.015,
                        horizontal: screenWidth * 0.04,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 1),

          // Liste des ressources
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
                  return ListView.builder(
                    padding: EdgeInsets.all(screenWidth * 0.04),
                    itemCount: ressources.length,
                    itemBuilder: (context, index) {
                      final ressource = ressources[index];
                      final ressourceId = ressource['idRessource'];
                      final auteur = ressource['pseudoUtilisateur'] ?? 'Auteur inconnu';

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
                          Widget? imageWidget;
                          if (ressource['imageRessource'] != null &&
                              ressource['imageRessource'].isNotEmpty) {
                            try {
                              imageWidget = ConstrainedBox(
                                constraints: BoxConstraints(
                                  maxHeight: screenHeight * 0.3,
                                  maxWidth: double.infinity,
                                ),
                                child: Image.memory(
                                  base64Decode(ressource['imageRessource']),
                                  fit: BoxFit.contain,
                                ),
                              );
                            } catch (_) {
                              imageWidget = null;
                            }
                          }

                          return Container(
                            margin: EdgeInsets.only(bottom: screenHeight * 0.02),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(8),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (imageWidget != null)
                                  ClipRRect(
                                    borderRadius: const BorderRadius.vertical(
                                      top: Radius.circular(8),
                                    ),
                                    child: imageWidget,
                                  ),
                                Padding(
                                  padding: EdgeInsets.all(screenWidth * 0.05),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      // Catégorie
                                      if (ressource['nomCatégorie'] != null)
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: screenWidth * 0.02,
                                            vertical: screenHeight * 0.005,
                                          ),
                                          decoration: BoxDecoration(
                                            color: bleuCumulus,
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            ressource['nomCatégorie'],
                                            style: TextStyle(
                                              fontSize: screenWidth * 0.03,
                                              color: bleuFrance,
                                              fontWeight: FontWeight.w500,
                                            ),
                                          ),
                                        ),
                                      SizedBox(height: screenHeight * 0.015),

                                      // Titre
                                      Text(
                                        ressource['titreRessource'] ?? 'Sans titre',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: screenWidth * 0.05,
                                          color: bleuFrance,
                                          height: 1.3,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.01),

                                      // Auteur et date - responsive
                                      Wrap(
                                        spacing: screenWidth * 0.04,
                                        runSpacing: screenHeight * 0.005,
                                        children: [
                                          Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Icon(
                                                Icons.person_outline,
                                                size: isSmallScreen ? 14 : 16,
                                                color: grisFrance,
                                              ),
                                              SizedBox(width: screenWidth * 0.01),
                                              Flexible(
                                                child: Text(
                                                  "Par $auteur",
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.032,
                                                    color: grisFrance,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ],
                                          ),
                                          if (ressource['dateRessource'] != null)
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  Icons.access_time,
                                                  size: isSmallScreen ? 14 : 16,
                                                  color: grisFrance,
                                                ),
                                                SizedBox(width: screenWidth * 0.01),
                                                Text(
                                                  formatDateTime(ressource['dateRessource']),
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.032,
                                                    color: grisFrance,
                                                  ),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                      SizedBox(height: screenHeight * 0.02),

                                      // Description
                                      Text(
                                        ressource['messageRessource'] ?? '',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.037,
                                          color: Colors.black87,
                                          height: 1.5,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.025),

                                      // Bouton J'aime - responsive
                                      Material(
                                        color: Colors.transparent,
                                        child: InkWell(
                                          borderRadius: BorderRadius.circular(20),
                                          onTap: () => toggleLike(ressourceId),
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                              horizontal: screenWidth * 0.03,
                                              vertical: screenHeight * 0.01,
                                            ),
                                            child: Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                Icon(
                                                  likedStatus[ressourceId] == true
                                                      ? Icons.favorite
                                                      : Icons.favorite_border,
                                                  size: isSmallScreen ? 18 : 20,
                                                  color: likedStatus[ressourceId] == true
                                                      ? rougeMarianne
                                                      : grisFrance,
                                                ),
                                                SizedBox(width: screenWidth * 0.015),
                                                Text(
                                                  likeCounts[ressourceId]?.toString() ?? '0',
                                                  style: TextStyle(
                                                    fontSize: screenWidth * 0.035,
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

                                      Divider(
                                        height: screenHeight * 0.04,
                                        color: const Color(0xFFE5E5E5),
                                      ),

                                      // Section commentaires
                                      Text(
                                        'Commentaires',
                                        style: TextStyle(
                                          fontSize: screenWidth * 0.04,
                                          fontWeight: FontWeight.w600,
                                          color: bleuFrance,
                                        ),
                                      ),
                                      SizedBox(height: screenHeight * 0.015),

                                      // Champ de commentaire - responsive
                                      Container(
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFFDDDDDD)),
                                          borderRadius: BorderRadius.circular(4),
                                        ),
                                        child: TextField(
                                          controller: commentControllers[ressourceId],
                                          maxLines: isSmallScreen ? 2 : 3,
                                          style: TextStyle(fontSize: screenWidth * 0.035),
                                          decoration: InputDecoration(
                                            hintText: "Écrire un commentaire...",
                                            hintStyle: TextStyle(
                                              color: grisFrance.withOpacity(0.7),
                                              fontSize: screenWidth * 0.035,
                                            ),
                                            suffixIcon: IconButton(
                                              icon: Icon(
                                                Icons.send,
                                                color: bleuFrance,
                                                size: isSmallScreen ? 18 : 20,
                                              ),
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
                                                        content: Text(
                                                          'Erreur : $e',
                                                          style: TextStyle(
                                                            fontSize: screenWidth * 0.035,
                                                          ),
                                                        ),
                                                        backgroundColor: rougeMarianne,
                                                      ),
                                                    );
                                                  }
                                                }
                                              },
                                            ),
                                            border: InputBorder.none,
                                            contentPadding: EdgeInsets.all(screenWidth * 0.03),
                                          ),
                                        ),
                                      ),

                                      // Liste des commentaires - responsive
                                      if (commentSnapshot.hasData && commentSnapshot.data!.isNotEmpty) ...[
                                        SizedBox(height: screenHeight * 0.02),
                                        ...commentSnapshot.data!
                                            .take(showAllComments[ressourceId]!
                                            ? commentSnapshot.data!.length
                                            : 3)
                                            .map((c) => Container(
                                          margin: EdgeInsets.only(bottom: screenHeight * 0.015),
                                          padding: EdgeInsets.all(screenWidth * 0.03),
                                          decoration: BoxDecoration(
                                            color: grisClair,
                                            borderRadius: BorderRadius.circular(6),
                                          ),
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Row(
                                                children: [
                                                  Icon(
                                                    Icons.person,
                                                    size: isSmallScreen ? 14 : 16,
                                                    color: grisFrance,
                                                  ),
                                                  SizedBox(width: screenWidth * 0.015),
                                                  Expanded(
                                                    child: Text(
                                                      c['pseudo'] ?? 'Anonyme',
                                                      style: TextStyle(
                                                        fontWeight: FontWeight.w500,
                                                        fontSize: screenWidth * 0.032,
                                                        color: bleuFrance,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                  Text(
                                                    c['dateCommentaire'] != null
                                                        ? formatDateTime(c['dateCommentaire'])
                                                        : '',
                                                    style: TextStyle(
                                                      fontSize: screenWidth * 0.028,
                                                      color: grisFrance,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              SizedBox(height: screenHeight * 0.008),
                                              Text(
                                                c['messageCommentaire'] ?? '',
                                                style: TextStyle(
                                                  fontSize: screenWidth * 0.035,
                                                  color: Colors.black87,
                                                  height: 1.4,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ))
                                            .toList(),

                                        // Bouton "Voir plus de commentaires" - responsive
                                        if (!showAllComments[ressourceId]! &&
                                            commentSnapshot.data!.length > 3)
                                          TextButton.icon(
                                            onPressed: () {
                                              setState(() => showAllComments[ressourceId] = true);
                                            },
                                            icon: Icon(
                                              Icons.expand_more,
                                              size: isSmallScreen ? 14 : 16,
                                            ),
                                            label: Text(
                                              "Afficher les ${commentSnapshot.data!.length - 3} commentaires restants",
                                              style: TextStyle(
                                                fontSize: screenWidth * 0.032,
                                              ),
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
                        },
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