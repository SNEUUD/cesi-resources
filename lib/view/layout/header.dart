import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resources/view/profile_view.dart';
import '../auth/login_view.dart';
import '../auth/register_view.dart';
import '../categories_view.dart';
import '../create_resource_view.dart';
import '../all_resources_view.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);
}

class _HeaderState extends State<Header> {
  String? _pseudo;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    final pseudo = prefs.getString('pseudoUtilisateur');
    setState(() {
      _pseudo = pseudo;
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pseudoUtilisateur');
    await prefs.remove('idUtilisateur');
    setState(() {
      _pseudo = null;
    });

    if (context.mounted) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Déconnecté avec succès')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80,
      titleSpacing: 20,
      title: Row(
        children: [
          Image.asset('assets/icons/logo.png', height: 40),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              '(re)sources relationnelles',
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: Color(0xFF000091),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
        ],
      ),
      actions: [
        Expanded(
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.only(right: 10),
            child: Row(
              children: [
                _navButton('Catégories', const CategoriesPage()),
                _navButton('Ressources', const AllResourcesView()),
                const SizedBox(width: 10),
                if (_pseudo == null) ...[
                  _actionButton(
                    label: 'Se connecter',
                    color: const Color(0xFF000091),
                    onPressed: () => _navigateTo(const LoginPage()),
                  ),
                  const SizedBox(width: 10),
                  _actionButton(
                    label: "S'inscrire",
                    color: Colors.grey,
                    onPressed: () => _navigateTo(const RegisterPage()),
                  ),
                ] else ...[
                  _navButton('Créer une ressource', const CreateResourcePage()),
                  _actionButton(
                    label: 'Connecté : $_pseudo',
                    color: const Color(0xFF000091),
                    onPressed: () => _navigateTo(const ProfilePage()),
                  ),
                  const SizedBox(width: 10),
                  _actionButton(
                    label: 'Déconnexion',
                    color: Colors.red,
                    onPressed: _logout,
                  ),
                ],
                const SizedBox(width: 20),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _navButton(String label, Widget page) {
    return TextButton(
      onPressed: () => _navigateTo(page),
      child: Text(label, style: const TextStyle(color: Color(0xFF000091))),
    );
  }

  Widget _actionButton({
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      ),
      onPressed: onPressed,
      child: Text(label, style: const TextStyle(color: Colors.white)),
    );
  }

  void _navigateTo(Widget page) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => page));
  }
}
