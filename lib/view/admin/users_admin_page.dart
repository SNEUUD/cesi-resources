import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../create_resource_view.dart';

class UsersAdminPage extends StatefulWidget {
  const UsersAdminPage({super.key});

  @override
  State<UsersAdminPage> createState() => _UsersAdminPageState();
}

class _UsersAdminPageState extends State<UsersAdminPage> {
  late Future<List<dynamic>> futureUsers;
  late Future<List<dynamic>> futureMaskedResources;

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers();
    futureMaskedResources = fetchMaskedResources();
  }

  Future<List<dynamic>> fetchUsers() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/utilisateurs'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des utilisateurs');
    }
  }

  Future<void> suspendUser(String userId) async {
    final response = await http.patch(
      Uri.parse('http://localhost:3000/utilisateurs/$userId/suspendre'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'statusUtilisateur': 'désactivé'}),
    );
    if (response.statusCode == 200) {
      setState(() {
        futureUsers = fetchUsers();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Compte suspendu')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suspension')),
      );
    }
  }

  Future<void> deleteUser(String userId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/utilisateurs/$userId'),
    );
    if (response.statusCode == 200) {
      setState(() {
        futureUsers = fetchUsers();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Compte supprimé')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }

  Future<void> updateUserStatus(String userId, String status) async {
    final response = await http.patch(
      Uri.parse('http://localhost:3000/utilisateurs/$userId/suspendre'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'statusUtilisateur': status}),
    );
    if (response.statusCode == 200) {
      setState(() {
        futureUsers = fetchUsers();
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            status == 'désactivé' ? 'Compte suspendu' : 'Compte réactivé',
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors du changement de statut')),
      );
    }
  }

  Future<List<dynamic>> fetchMaskedResources() async {
    final response = await http.get(
      Uri.parse('http://localhost:3000/resources_admin'),
    );
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors du chargement des ressources');
    }
  }

  Future<void> validateResource(String resourceId) async {
    final response = await http.patch(
      Uri.parse('http://localhost:3000/resources_admin/$resourceId/valider'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'statusRessource': 'affiche'}),
    );
    if (response.statusCode == 200) {
      setState(() {
        futureMaskedResources = fetchMaskedResources();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ressource validée')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la validation')),
      );
    }
  }

  Future<void> deleteResource(String resourceId) async {
    final response = await http.delete(
      Uri.parse('http://localhost:3000/resources_admin/$resourceId'),
    );
    if (response.statusCode == 200) {
      setState(() {
        futureMaskedResources = fetchMaskedResources();
      });
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ressource supprimée')));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erreur lors de la suppression')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs & ressources à valider'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF000091),
        elevation: 1,
      ),
      backgroundColor: Colors.grey[100],
      body: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Colonne Utilisateurs
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                    child: Text(
                      "Utilisateurs",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Color(0xFF000091),
                      ),
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: futureUsers,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Erreur : ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('Aucun utilisateur trouvé.'),
                          );
                        } else {
                          final users = snapshot.data!;
                          return ListView.separated(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            itemCount: users.length,
                            separatorBuilder:
                                (_, __) => const SizedBox(height: 10),
                            itemBuilder: (context, index) {
                              final user = users[index];
                              return Card(
                                elevation: 2,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                                child: ListTile(
                                  leading: const Icon(
                                    Icons.person,
                                    color: Color(0xFF000091),
                                  ),
                                  title: Text(
                                    user['pseudo'] ?? 'Sans pseudo',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  subtitle: Text(user['email'] ?? ''),
                                  trailing: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      IconButton(
                                        icon: Icon(
                                          user['status'] == 'désactivé'
                                              ? Icons.block
                                              : Icons.check_circle,
                                          color:
                                              user['status'] == 'désactivé'
                                                  ? Colors.orange
                                                  : Colors.green,
                                        ),
                                        tooltip:
                                            user['status'] == 'désactivé'
                                                ? 'Réactiver'
                                                : 'Suspendre',
                                        onPressed:
                                            () => updateUserStatus(
                                              user['id'].toString(),
                                              user['status'] == 'désactivé'
                                                  ? 'activé'
                                                  : 'désactivé',
                                            ),
                                      ),
                                      IconButton(
                                        icon: const Icon(
                                          Icons.delete,
                                          color: Colors.red,
                                        ),
                                        tooltip: 'Supprimer',
                                        onPressed:
                                            () => deleteUser(
                                              user['id'].toString(),
                                            ),
                                      ),
                                    ],
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
            ),
            // Colonne Ressources masquées
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 8,
                    ),
                    child: Row(
                      children: [
                        const Text(
                          "Ressources à valider",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 20,
                            color: Color(0xFF000091),
                          ),
                        ),
                        const Spacer(),
                        ElevatedButton.icon(
                          icon: const Icon(Icons.add),
                          label: const Text('Créer une ressource'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000091),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => const CreateResourcePage(),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: FutureBuilder<List<dynamic>>(
                      future: futureMaskedResources,
                      builder: (context, snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        } else if (snapshot.hasError) {
                          return Center(
                            child: Text('Erreur : ${snapshot.error}'),
                          );
                        } else if (!snapshot.hasData ||
                            snapshot.data!.isEmpty) {
                          return const Center(
                            child: Text('Aucune ressource à valider.'),
                          );
                        } else {
                          final resources = snapshot.data!;
                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 8,
                            ),
                            itemCount: resources.length,
                            itemBuilder: (context, index) {
                              final res = resources[index];

                              Widget imageWidget;
                              if (res['image'] != null &&
                                  res['image'].isNotEmpty) {
                                try {
                                  imageWidget = Image.memory(
                                    base64Decode(res['image']),
                                    width: double.infinity,
                                    height: 180,
                                    fit: BoxFit.cover,
                                  );
                                } catch (_) {
                                  imageWidget = Container(
                                    height: 180,
                                    color: Colors.grey[300],
                                    child: const Icon(
                                      Icons.broken_image,
                                      size: 80,
                                    ),
                                  );
                                }
                              } else {
                                imageWidget = Container(
                                  height: 180,
                                  color: Colors.grey[300],
                                  child: const Icon(
                                    Icons.image_not_supported,
                                    size: 80,
                                  ),
                                );
                              }

                              return Center(
                                child: SizedBox(
                                  width: 500,
                                  child: Card(
                                    margin: const EdgeInsets.symmetric(
                                      vertical: 10,
                                      horizontal: 8,
                                    ),
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(18),
                                    ),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        if (res['image'] != null &&
                                            res['image'].isNotEmpty)
                                          ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                              18,
                                            ),
                                            child: SizedBox(
                                              width: 140,
                                              height: 140,
                                              child: imageWidget,
                                            ),
                                          ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 16,
                                              vertical: 12,
                                            ),
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  res['title'] ?? 'Sans titre',
                                                  style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Color(0xFF000091),
                                                  ),
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                if (res['categorie'] != null)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                          top: 2.0,
                                                          bottom: 6.0,
                                                        ),
                                                    child: Text(
                                                      "Catégorie : ${res['categorie']}",
                                                      style: const TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Colors.deepPurple,
                                                        fontWeight:
                                                            FontWeight.w500,
                                                      ),
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                    ),
                                                  ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  res['message'] ?? '',
                                                  style: const TextStyle(
                                                    fontSize: 15,
                                                    color: Colors.black87,
                                                  ),
                                                  maxLines: 3,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  children: [
                                                    const Icon(
                                                      Icons.calendar_today,
                                                      size: 18,
                                                      color: Colors.grey,
                                                    ),
                                                    const SizedBox(width: 8),
                                                    Text(
                                                      res['date'] != null
                                                          ? res['date']
                                                              .toString()
                                                              .split('T')
                                                              .first
                                                          : '',
                                                      style: const TextStyle(
                                                        fontSize: 13,
                                                        color: Colors.grey,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 10),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    ElevatedButton.icon(
                                                      icon: const Icon(
                                                        Icons.check_circle,
                                                        color: Colors.white,
                                                      ),
                                                      label: const Text(
                                                        'Valider',
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.green,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ),
                                                      onPressed:
                                                          () => validateResource(
                                                            res['idRessource']
                                                                .toString(),
                                                          ),
                                                    ),
                                                    const SizedBox(width: 8),
                                                    ElevatedButton.icon(
                                                      icon: const Icon(
                                                        Icons.delete,
                                                        color: Colors.white,
                                                      ),
                                                      label: const Text(
                                                        'Supprimer',
                                                      ),
                                                      style: ElevatedButton.styleFrom(
                                                        backgroundColor:
                                                            Colors.red,
                                                        shape: RoundedRectangleBorder(
                                                          borderRadius:
                                                              BorderRadius.circular(
                                                                12,
                                                              ),
                                                        ),
                                                      ),
                                                      onPressed:
                                                          () => deleteResource(
                                                            res['idRessource']
                                                                .toString(),
                                                          ),
                                                    ),
                                                    const SizedBox(width: 12),
                                                  ],
                                                ),
                                              ],
                                            ),
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
            ),
          ],
        ),
      ),
    );
  }
}
