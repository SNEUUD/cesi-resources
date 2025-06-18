import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resources/view/profile_view.dart';
import '../../main.dart';
import '../auth/login_view.dart';
import '../categories_view.dart';
import '../create_resource_view.dart';
import '../all_resources_view.dart'; // <-- à créer si besoin
import '../auth/register_view.dart';
import '../admin/users_admin_page.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}

class _HeaderState extends State<Header> {
  String? _pseudo;
  String? _roleId;

  @override
  void initState() {
    super.initState();
    _loadSession();
  }

  Future<void> _loadSession() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _pseudo = prefs.getString('pseudoUtilisateur');
      _roleId = prefs.getInt('roleUtilisateur')?.toString();
    });
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('pseudoUtilisateur');
    await prefs.remove('idUtilisateur');
    await prefs.remove('roleUtilisateur');
    setState(() {
      _pseudo = null;
      _roleId = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Déconnecté avec succès')),
    );
    Navigator.of(context).pop(); // Ferme la bottom sheet
  }

  void _navigate(Widget page) {
    Navigator.of(context).pop(); // Ferme la bottom sheet
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => page));
  }

  void _openBottomMenu() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: _buildBottomMenuContent(),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomMenuContent() {
    if (_pseudo == null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Catégories'),
            onTap: () => _navigate(const CategoriesPage()),
          ),
          ListTile(
            title: const Text('Ressources'),
            onTap: () => _navigate(const AllResourcesView()),
          ),
          ListTile(
            title: const Text('Se connecter'),
            onTap: () => _navigate(const LoginPage()),
          ),
          ListTile(
            title: const Text("S'inscrire"),
            onTap: () => _navigate(const RegisterPage()),
          ),
        ],
      );
    } else {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListTile(
            title: const Text('Catégories'),
            onTap: () => _navigate(const CategoriesPage()),
          ),
          ListTile(
            title: const Text('Ressources'),
            onTap: () => _navigate(const AllResourcesView()),
          ),
          ListTile(
            title: const Text('Créer une ressource'),
            onTap: () => _navigate(const CreateResourcePage()),
          ),
          if (_roleId == '2' || _roleId == '3')
            ListTile(
              title: const Text('Administration'),
              onTap: () => _navigate(const UsersAdminPage()),
            ),
          ListTile(
            title: Text('Connecté : $_pseudo'),
            onTap: () => _navigate(const ProfilePage()),
          ),
          ListTile(
            title: const Text('Déconnexion', style: TextStyle(color: Colors.red)),
            onTap: _logout,
          ),
        ],
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmall = MediaQuery.of(context).size.width < 700;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (_) => const HomePage()),
                    (route) => false,
              );
            },
            child: Image.asset('assets/icons/logo.png', height: 40),
          ),
          const SizedBox(width: 8),
          if (!isSmall)
            const Text(
              '(re)sources relationnelles',
              style: TextStyle(color: Color(0xFF000091)),
            ),
        ],
      ),
      actions: isSmall
          ? null
          : [
        _buildMenuButtons(false),
        const SizedBox(width: 20),
      ],
      leading: isSmall
          ? IconButton(
        icon: const Icon(Icons.menu, color: Color(0xFF000091)),
        onPressed: _openBottomMenu,
      )
          : null,
    );
  }

  Widget _buildMenuButtons(bool isSmall) {
    if (_pseudo == null) {
      return Row(
        children: [
          TextButton(
            onPressed: () => _navigate(const CategoriesPage()),
            child: const Text('Catégories', style: TextStyle(color: Color(0xFF000091))),
          ),
          TextButton(
            onPressed: () => _navigate(const AllResourcesView()),
            child: const Text('Ressources', style: TextStyle(color: Color(0xFF000091))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000091),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => _navigate(const LoginPage()),
            child: const Text('Se connecter', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.grey,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => _navigate(const RegisterPage()),
            child: const Text("S'inscrire", style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    } else {
      return Row(
        children: [
          TextButton(
            onPressed: () => _navigate(const CategoriesPage()),
            child: const Text('Catégories', style: TextStyle(color: Color(0xFF000091))),
          ),
          TextButton(
            onPressed: () => _navigate(const AllResourcesView()),
            child: const Text('Ressources', style: TextStyle(color: Color(0xFF000091))),
          ),
          TextButton(
            onPressed: () => _navigate(const CreateResourcePage()),
            child: const Text('Créer une ressource', style: TextStyle(color: Color(0xFF000091))),
          ),
          if (_roleId == '2' || _roleId == '3')
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              onPressed: () => _navigate(const UsersAdminPage()),
              child: const Text('Administration', style: TextStyle(color: Colors.white)),
            ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF000091),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: () => _navigate(const ProfilePage()),
            child: Text('Connecté : $_pseudo', style: const TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            ),
            onPressed: _logout,
            child: const Text('Déconnexion', style: TextStyle(color: Colors.white)),
          ),
        ],
      );
    }
  }
}