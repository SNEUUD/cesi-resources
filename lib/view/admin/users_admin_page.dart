import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class UsersAdminPage extends StatefulWidget {
  const UsersAdminPage({super.key});

  @override
  State<UsersAdminPage> createState() => _UsersAdminPageState();
}

class _UsersAdminPageState extends State<UsersAdminPage> {
  late Future<List<dynamic>> futureUsers;

  @override
  void initState() {
    super.initState();
    futureUsers = fetchUsers();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion des utilisateurs'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF000091),
        elevation: 1,
      ),
      body: FutureBuilder<List<dynamic>>(
        future: futureUsers,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur : ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Aucun utilisateur trouvé.'));
          } else {
            final users = snapshot.data!;
            return ListView.separated(
              itemCount: users.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final user = users[index];
                return ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(user['pseudo'] ?? 'Sans pseudo'),
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
                        icon: const Icon(Icons.delete, color: Colors.red),
                        tooltip: 'Supprimer',
                        onPressed: () => deleteUser(user['id'].toString()),
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
