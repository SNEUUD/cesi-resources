import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;


class ResourcesUserView extends StatefulWidget {
  const ResourcesUserView({super.key});

  @override
  State<ResourcesUserView> createState() => _ResourcesUserViewState();
}

class _ResourcesUserViewState extends State<ResourcesUserView> {
  List<dynamic> ressources = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserRessources();
  }

  Future<void> fetchUserRessources() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('idUtilisateur');

    if (userId == null) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Utilisateur non connecté')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/ressources/user/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          ressources = data['ressources'];
          isLoading = false;
        });
      } else {
        throw Exception('Erreur serveur : ${response.statusCode}');
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur : $e')),
      );
    }
  }

  Future<void> deleteRessource(int idRessource, String titre) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Confirmation"),
        content: Text('Supprimer la ressource "$titre" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text(
              'Supprimer',
              style: TextStyle(color: Color(0xFFE1000F)),
            ),
          ),
        ],
      ),
    );

    if (confirm == true) {
      try {
        final response = await http.delete(
          Uri.parse('http://localhost:3000/ressources/$idRessource'),
        );

        if (response.statusCode == 200) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Ressource supprimée')),
          );
          fetchUserRessources(); // refresh
        } else {
          throw Exception('Erreur : ${response.statusCode}');
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur : $e')),
        );
      }
    }
  }

  Future<void> updateRessource(Map<String, dynamic> r) async {
  final titreCtrl = TextEditingController(text: r['titre']);
  final descCtrl = TextEditingController(text: r['description']);
  List<String> categories = [];
  String selectedCat = "";
  String? updatedImageBase64 = r['imageRessource'];

  final ImagePicker picker = ImagePicker();

  bool loading = true;

  await showDialog(
    context: context,
    barrierDismissible: false,
    builder: (ctx) {
      fetchCategories() async {
        final response = await http.get(Uri.parse('http://localhost:3000/categories'));
        if (response.statusCode == 200) {
          final List<dynamic> data = jsonDecode(response.body);
          categories = data.map<String>((c) => c['nomCatégorie'] as String).toList();
          selectedCat = categories.contains(r['nomCategorie']) ? r['nomCategorie'] : categories.first;
        } else {
          categories = ['Éducation'];
          selectedCat = 'Éducation';
        }
        loading = false;
        (ctx as Element).markNeedsBuild();
      }

      fetchCategories();

      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            title: const Text("Modifier la ressource"),
            content: loading
                ? const SizedBox(height: 100, child: Center(child: CircularProgressIndicator()))
                : SingleChildScrollView(
                    child: Column(
                      children: [
                        TextField(
                          controller: titreCtrl,
                          decoration: const InputDecoration(labelText: 'Titre'),
                        ),
                        const SizedBox(height: 10),
                        TextField(
                          controller: descCtrl,
                          maxLines: 4,
                          decoration: const InputDecoration(labelText: 'Description'),
                        ),
                        const SizedBox(height: 10),
                        TextFormField(
  initialValue: selectedCat,
  readOnly: true,
  decoration: const InputDecoration(
    labelText: 'Catégorie',
    border: OutlineInputBorder(),
  ),
  style: const TextStyle(color: Colors.grey),
),

                        const SizedBox(height: 10),
                        Row(
                          children: [
                            ElevatedButton.icon(
                              onPressed: () async {
                                final picked = await picker.pickImage(source: ImageSource.gallery);
                                if (picked != null) {
                                  final bytes = await picked.readAsBytes();
                                  setState(() {
                                    updatedImageBase64 = base64Encode(bytes);
                                  });
                                }
                              },
                              icon: const Icon(Icons.image),
                              label: const Text("Changer l'image"),
                            ),
                            const SizedBox(width: 8),
                            if (updatedImageBase64 != null)
                              const Icon(Icons.check_circle, color: Colors.green)
                          ],
                        ),
                        if (updatedImageBase64 != null)
  Padding(
    padding: const EdgeInsets.only(top: 10),
    child: ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.memory(
        base64Decode(updatedImageBase64!),
        height: 150,
        width: double.infinity,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return Container(
            height: 150,
            color: Colors.grey[300],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.broken_image, color: Colors.grey, size: 40),
                  SizedBox(height: 8),
                  Text(
                    "Aperçu non disponible",
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    ),
  ),
                      ],
                    ),
                  ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Annuler")),
              if (!loading)
                ElevatedButton(
                  onPressed: () async {
                    final response = await http.put(
                      Uri.parse('http://localhost:3000/ressources/${r['idRessource']}'),
                      headers: {'Content-Type': 'application/json'},
                      body: jsonEncode({
                        'titre': titreCtrl.text,
                        'message': descCtrl.text,
                        'categorie': selectedCat,
                        'image': updatedImageBase64, // ✅ modifié ici
                      }),
                    );

                    Navigator.pop(context);
                    if (response.statusCode == 200) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Ressource modifiée (statut : masqué)')),
                      );
                      fetchUserRessources();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur : ${response.statusCode}')),
                      );
                    }
                  },
                  child: const Text("Modifier"),
                ),
            ],
          );
        },
      );
    },
  );
}


  Widget buildRessourceCard(Map<String, dynamic> r) {
    final status = r['statusRessource'] ?? 'masque';
    final isAffiche = status == 'affiche';

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    r['titre'] ?? 'Sans titre',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0000A0),
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: isAffiche ? Colors.green[100] : Colors.orange[100],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    isAffiche ? 'Affiché' : 'Masqué',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: isAffiche ? Colors.green[800] : Colors.orange[800],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              r['description'] ?? '',
              style: const TextStyle(fontSize: 14, color: Colors.black87),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Text(
                  "Catégorie : ${r['nomCategorie'] ?? 'Non spécifiée'}",
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.deepPurple,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => updateRessource(r),
                  icon: const Icon(Icons.edit_outlined),
                  tooltip: 'Modifier',
                  color: Colors.blue,
                ),
                IconButton(
                  onPressed: () => deleteRessource(r['idRessource'], r['titre']),
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Supprimer',
                  color: Colors.red,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes Ressources'),
        backgroundColor: const Color(0xFF0000A0),
        foregroundColor: Colors.white,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ressources.isEmpty
              ? const Center(child: Text("Aucune ressource trouvée."))
              : Padding(
                  padding: const EdgeInsets.all(16),
                  child: ListView.builder(
                    itemCount: ressources.length,
                    itemBuilder: (context, index) =>
                        buildRessourceCard(ressources[index]),
                  ),
                ),
    );
  }
}
