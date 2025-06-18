import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:resources/view/profile_view.dart';
import '../auth/login_view.dart';
import '../categories_view.dart';
import '../create_resource_view.dart';
import '../all_resources_view.dart';
import '../auth/register_view.dart';
import '../page_accueil.dart';

class Header extends StatefulWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
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

    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Déconnecté avec succès')));
  }

  void _openMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('Catégories'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const CategoriesPage()));
              },
            ),
            ListTile(
              leading: const Icon(Icons.book),
              title: const Text('Ressources'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => const AllResourcesView()));
              },
            ),
            if (_pseudo != null) ...[
              ListTile(
                leading: const Icon(Icons.add),
                title: const Text('Créer une ressource'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const CreateResourcePage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.person),
                title: Text('Profil ($_pseudo)'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const ProfilePage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.logout),
                title: const Text('Déconnexion'),
                onTap: () {
                  Navigator.pop(context);
                  _logout();
                },
              ),
            ] else ...[
              ListTile(
                leading: const Icon(Icons.login),
                title: const Text('Se connecter'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const LoginPage()));
                },
              ),
              ListTile(
                leading: const Icon(Icons.app_registration),
                title: const Text("S'inscrire"),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => const RegisterPage()));
                },
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isMobile = MediaQuery.of(context).size.width < 600;

    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      toolbarHeight: 80,
      leading: isMobile
          ? IconButton(
        icon: const Icon(Icons.menu, color: Color(0xFF000091)),
        onPressed: _openMenu,
      )
          : null,
      title: Row(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (context) => const HomePage()),
                    (route) => false,
              );
            },
            child: Image.asset('assets/icons/logo.png', height: 40),
          ),
          const SizedBox(width: 8),
          if (!isMobile)
            const Text(
              '(re)sources relationnelles',
              style: TextStyle(
                color: Color(0xFF000091),
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
        ],
      ),
      actions: isMobile
          ? null
          : [
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const CategoriesPage()),
            );
          },
          child: const Text(
            'Catégories',
            style: TextStyle(color: Color(0xFF000091)),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const AllResourcesView()),
            );
          },
          child: const Text(
            'Ressources',
            style: TextStyle(color: Color(0xFF000091)),
          ),
        ),
        const SizedBox(width: 10),
        if (_pseudo == null)
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000091),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const LoginPage(),
                    ),
                  );
                },
                child: const Text(
                  'Se connecter',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RegisterPage(),
                    ),
                  );
                },
                child: const Text(
                  "S'inscrire",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          )
        else
          Row(
            children: [
              TextButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const CreateResourcePage(),
                    ),
                  );
                },
                child: const Text(
                  'Créer une ressource',
                  style: TextStyle(color: Color(0xFF000091)),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF000091),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfilePage(),
                    ),
                  );
                },
                child: Text(
                  'Connecté : $_pseudo',
                  style: const TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 12,
                  ),
                ),
                onPressed: _logout,
                child: const Text(
                  'Déconnexion',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        const SizedBox(width: 20),
      ],
    );
  }
}
