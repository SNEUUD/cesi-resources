import 'package:flutter/material.dart';

import 'layout/header.dart';

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

  @override
  void initState() {
    super.initState();
    // Initialisation des contrôleurs avec les valeurs actuelles
    nomController = TextEditingController(text: 'GIRAULT');
    prenomController = TextEditingController(text: 'Ophélie');
    pseudoController = TextEditingController(text: 'ophgrt');
    passwordController = TextEditingController(text: '********');
    dateNaissanceController = TextEditingController(text: '07/09/1998');
    emailController = TextEditingController(text: 'ophgrt@gmail.com');
    roleController = TextEditingController(text: 'Utilisateur');
    sexeController = TextEditingController(text: 'Femme');
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
        child: Padding(
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
                        onSave: () {
                          setState(() {
                            isEditing = false;
                            // Ici, vous pourriez également sauvegarder les données
                            // dans une base de données ou un service d'API
                            print('Informations enregistrées!');
                            // Afficher éventuellement un message de confirmation
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Profil mis à jour avec succès!')),
                            );
                          });
                        },
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
  final VoidCallback onSave; // Nouvelle fonction callback

  const ProfileDetailsBox({
    Key? key,
    required this.isEditing,
    required this.nomController,
    required this.prenomController,
    required this.pseudoController,
    required this.passwordController,
    required this.dateNaissanceController,
    required this.emailController,
    required this.roleController,
    required this.sexeController,
    required this.onSave, // Ajout du paramètre requis
  }) : super(key: key);

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
                _buildField('Ancien mot de passe : ', TextEditingController(), true, isPassword: true),
                const SizedBox(height: 10),
                _buildField('Nouveau mot de passe : ', TextEditingController(), true, isPassword: true),
                const SizedBox(height: 10),
                _buildField('Confirmer le mot de passe : ', TextEditingController(), true, isPassword: true),
                const SizedBox(height: 20),
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      widget.onSave();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0000A0), // Fond bleu foncé
                      foregroundColor: Colors.white, // Texte blanc
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text('Enregistrer les informations'),
                  ),
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
