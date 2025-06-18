import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'layout/header.dart';
import 'layout/footer.dart';
import 'resources_user_view.dart';


class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  // État pour contrôler si on est en mode édition ou non
  bool isEditing = false;

  // Contrôleurs pour les champs de texte
  late TextEditingController nomController;
  late TextEditingController prenomController;
  late TextEditingController pseudoController;
  late TextEditingController passwordController;
  late TextEditingController dateNaissanceController;
  late TextEditingController emailController;
  late TextEditingController roleController;
  late TextEditingController sexeController;
  late TextEditingController oldPasswordController;
  late TextEditingController newPasswordController;
  late TextEditingController confirmPasswordController;

  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    // Initialisation des contrôleurs avec les valeurs vides
    nomController = TextEditingController();
    prenomController = TextEditingController();
    pseudoController = TextEditingController();
    passwordController = TextEditingController(text: '********');
    dateNaissanceController = TextEditingController();
    emailController = TextEditingController();
    roleController = TextEditingController();
    sexeController = TextEditingController();
    oldPasswordController = TextEditingController();
    newPasswordController = TextEditingController();
    confirmPasswordController = TextEditingController();

    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('idUtilisateur');

    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de récupérer l\'ID utilisateur')),
      );
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/profil/$userId'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final utilisateur = data['utilisateur'];

        setState(() {
          nomController.text = utilisateur['nom'] ?? '';
          prenomController.text = utilisateur['prénom'] ?? '';
          pseudoController.text = utilisateur['pseudo'] ?? '';
          dateNaissanceController.text = utilisateur['dateNaissance'] ?? '';
          emailController.text = utilisateur['email'] ?? '';
          sexeController.text = utilisateur['sexe'] ?? '';

          final roleId = utilisateur['role'] ?? 1;
          roleController.text = roleId == 1 ? 'Utilisateur' : 'Administrateur';

          isLoading = false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $e')),
      );
    }
  }

  Future<void> _updateUserData() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('idUtilisateur');

    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de récupérer l\'ID utilisateur')),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/profil/$userId/edit'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'nom': nomController.text,
          'prénom': prenomController.text,
          'pseudo': pseudoController.text,
          'email': emailController.text,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode != 200) {
        print('Réponse du serveur: ${response.body}');
        // Puis afficher le message d'erreur
      }

      if (response.statusCode == 200) {
        // Recharger les données pour s'assurer que l'affichage est à jour
        _loadUserData();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profil mis à jour avec succès!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $e')),
      );
    }
  }

  Future<void> _updatePassword() async {
    // Vérifications basiques
    if (oldPasswordController.text.isEmpty ||
        newPasswordController.text.isEmpty ||
        confirmPasswordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Tous les champs doivent être remplis')),
      );
      return;
    }

    if (newPasswordController.text != confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Les nouveaux mots de passe ne correspondent pas')),
      );
      return;
    }

    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('idUtilisateur');

    if (userId == null) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Impossible de récupérer l\'ID utilisateur')),
      );
      return;
    }

    try {
      final response = await http.put(
        Uri.parse('http://localhost:3000/profil/$userId/password'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode({
          'ancienMotDePasse': oldPasswordController.text,
          'nouveauMotDePasse': newPasswordController.text,
        }),
      );

      setState(() {
        isLoading = false;
      });

      if (response.statusCode == 200) {
        // Réinitialisation des champs de mot de passe
        oldPasswordController.clear();
        newPasswordController.clear();
        confirmPasswordController.clear();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Mot de passe mis à jour avec succès!')),
        );
      } else {
        print('Réponse du serveur: ${response.body}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erreur lors de la mise à jour du mot de passe: ${response.statusCode}')),
        );
      }
    } catch (e) {
      setState(() {
        isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de connexion: $e')),
      );
    }
  }

  @override
  void dispose() {
    // Libération des ressources
    nomController.dispose();
    prenomController.dispose();
    pseudoController.dispose();
    passwordController.dispose();
    dateNaissanceController.dispose();
    emailController.dispose();
    roleController.dispose();
    sexeController.dispose();
    oldPasswordController.dispose();
    newPasswordController.dispose();
    confirmPasswordController.dispose();

    super.dispose();
  }

  // Méthode pour basculer entre les modes visualisation et édition
  void toggleEditMode() {
    setState(() {
      isEditing = !isEditing;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Valeur de padding horizontal commune pour tous les éléments
    const double horizontalPadding = 20.0;

    return Scaffold(
      appBar: const Header(),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(42.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Titre principal
                  const Text(
                    'Mon profil',
                    style: TextStyle(
                      fontFamily: 'Chillax',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF0000A0), // Bleu foncé
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Paragraphe d'introduction
                  const Text(
                    'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF0000A0), // Bleu foncé
                    ),
                  ),
                  const SizedBox(height: 32),
                  // Container principal
                  Container(
                    padding: const EdgeInsets.all(22),
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF0000A0)), // Bordure bleue
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Padding pour la section photo et nom
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Row(
                            children: [
                              // Avatar rond bleu
                              Container(
                                width: 60,
                                height: 60,
                                decoration: const BoxDecoration(
                                  color: Color(0xFF0000A0), // Bleu foncé
                                  shape: BoxShape.circle,
                                ),
                                child: const Center(
                                  child: Text(
                                    'OG',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Nom avec style bleu
                              Text(
                                '${prenomController.text} ${nomController.text}',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Color(0xFF0000A0), // Bleu foncé
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Padding pour le texte descriptif
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Color(0xFF0000A0), // Bleu foncé
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
Center(
  child: ElevatedButton.icon(
    onPressed: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ResourcesUserView(),
        ),
      );
    },
    icon: Icon(Icons.folder, color: Colors.white),
    label: Text('Mes Ressources'),
    style: ElevatedButton.styleFrom(
      backgroundColor: Color(0xFF0000A0),
      foregroundColor: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
    ),
  ),
),


                        const SizedBox(height: 20),
                        // Container des détails du profil avec padding horizontal
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: horizontalPadding),
                          child: ProfileDetailsBox(
                            isEditing: isEditing,
                            nomController: nomController,
                            prenomController: prenomController,
                            pseudoController: pseudoController,
                            passwordController: passwordController,
                            dateNaissanceController: dateNaissanceController,
                            emailController: emailController,
                            roleController: roleController,
                            sexeController: sexeController,
                            oldPasswordController: oldPasswordController,
                            newPasswordController: newPasswordController,
                            confirmPasswordController: confirmPasswordController,
                            onSave: () {
                              setState(() {
                                isEditing = false;
                              });
                              _updateUserData();
                            },
                            onPasswordChange: _updatePassword,
                          ),
                        ),
                        const SizedBox(height: 20),
                        // Padding pour les boutons d'action
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 100),
                          child: !isEditing
                              ? Row(
                            // Si on n'est pas en mode édition, on garde la Row avec les deux boutons
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              ElevatedButton(
                                onPressed: toggleEditMode,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0000A0),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                child: const Text('Modifier mon profil'),
                              ),
                              const SizedBox(width: 64),
                              ElevatedButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return AlertDialog(
                                        title: const Text('Supprimer le profil'),
                                        content: const Text('Êtes-vous sûr de vouloir supprimer votre profil ?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () {
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Annuler'),
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // Action de suppression ici
                                              Navigator.of(context).pop();
                                            },
                                            child: const Text('Supprimer'),
                                          ),
                                        ],
                                      );
                                    },
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFFE1000F),
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                ),
                                child: const Text('Supprimer mon profil'),
                              ),
                            ],
                          )
                              : Center(
                            // Si on est en mode édition, on centre le bouton d'annulation
                            child: ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  isEditing = false;
                                });
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFFE1000F),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                              ),
                              child: const Text('< Annuler'),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Footer(), // Ajout du Footer ici
          ],
        ),
      ),
    );
  }
}

// Widget séparé pour le container des détails du profil
class ProfileDetailsBox extends StatefulWidget {
  final bool isEditing;
  final TextEditingController nomController;
  final TextEditingController prenomController;
  final TextEditingController pseudoController;
  final TextEditingController passwordController;
  final TextEditingController dateNaissanceController;
  final TextEditingController emailController;
  final TextEditingController roleController;
  final TextEditingController sexeController;
  final TextEditingController oldPasswordController;
  final TextEditingController newPasswordController;
  final TextEditingController confirmPasswordController;
  final VoidCallback onPasswordChange; // Nouvelle fonction callback
  final VoidCallback onSave; // Nouvelle fonction callback

  const ProfileDetailsBox({
    super.key,
    required this.isEditing,
    required this.nomController,
    required this.prenomController,
    required this.pseudoController,
    required this.passwordController,
    required this.dateNaissanceController,
    required this.emailController,
    required this.roleController,
    required this.sexeController,
    required this.oldPasswordController,
    required this.newPasswordController,
    required this.confirmPasswordController,
    required this.onSave, // Ajout du paramètre requis
    required this.onPasswordChange, // Ajout du paramètre requis
  });

  @override
  State<ProfileDetailsBox> createState() => _ProfileDetailsBoxState();
}

class _ProfileDetailsBoxState extends State<ProfileDetailsBox> {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: const Color(0xFF0000A0)), // Bordure bleue
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Titre du bloc de détails
          Row(
            children: [
              const Text(
                'Détails du profil',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF0000A0), // Bleu foncé
                ),
              ),
              if (widget.isEditing)
                const Padding(
                  padding: EdgeInsets.only(left: 10),
                  child: Text(
                    '(Mode édition)',
                    style: TextStyle(
                      fontSize: 14,
                      fontStyle: FontStyle.italic,
                      color: Color(0xFF0000A0),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 20),
          // Grille de détails en 2 colonnes
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Colonne de gauche
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField('Nom : ', widget.nomController, widget.isEditing),
                    const SizedBox(height: 16),
                    _buildField('Prénom : ', widget.prenomController, widget.isEditing),
                    const SizedBox(height: 16),
                    _buildField('Pseudo : ', widget.pseudoController, widget.isEditing),
                    const SizedBox(height: 16),
                    _buildField('Mot de passe : ', widget.passwordController, widget.isEditing, isPassword: true, enabled: false),
                  ],
                ),
              ),
              // Colonne de droite
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildField('Date de naissance : ', widget.dateNaissanceController, widget.isEditing, enabled: false),
                    const SizedBox(height: 16),
                    _buildField('Email : ', widget.emailController, widget.isEditing),
                    const SizedBox(height: 16),
                    _buildField('Rôle : ', widget.roleController, widget.isEditing, enabled: false),
                    const SizedBox(height: 16),
                    _buildField('Sexe : ', widget.sexeController, widget.isEditing, enabled: false),
                  ],
                ),
              ),
            ],
          ),
          if (widget.isEditing)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const Text(
                  'Modification de votre mot de passe',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF0000A0), // Bleu foncé
                  ),
                ),
                const SizedBox(height: 10),
                _buildField('Ancien mot de passe : ', widget.oldPasswordController, true, isPassword: true),
                const SizedBox(height: 10),
                _buildField('Nouveau mot de passe : ', widget.newPasswordController, true, isPassword: true),
                const SizedBox(height: 10),
                _buildField('Confirmer le mot de passe : ', widget.confirmPasswordController, true, isPassword: true),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: widget.onSave,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0000A0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Enregistrer le profil'),
                    ),
                    const SizedBox(width: 20),
                    ElevatedButton(
                      onPressed: widget.onPasswordChange,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0000A0),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      ),
                      child: const Text('Changer le mot de passe'),
                    ),
                  ],
                ),
              ],
            ),
        ],
      ),
    );
  }

  // Méthode pour construire un champ (lecture ou édition selon le mode)
  Widget _buildField(String label, TextEditingController controller, bool isEditing, {bool isPassword = false, bool enabled = true}) {
    if (isEditing) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Color(0xFF0000A0),
            ),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              enabled: enabled,
              obscureText: isPassword,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0000A0),
              ),
              decoration: const InputDecoration(
                contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 8),
                isDense: true,
                border: OutlineInputBorder(),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0000A0), width: 1.0),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF0000A0), width: 2.0),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Container(),
          )
        ],
      );
    } else {
      return RichText(
        text: TextSpan(
          children: [
            TextSpan(
              text: label,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Color(0xFF0000A0),
              ),
            ),
            TextSpan(
              text: controller.text,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF0000A0),
              ),
            ),
          ],
        ),
      );
    }
  }
}