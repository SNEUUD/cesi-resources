import 'package:flutter/material.dart';
import '../auth/login_view.dart';
import '../auth/register_view.dart';

class Header extends StatelessWidget implements PreferredSizeWidget {
  const Header({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      // Row pour organiser le titre à gauche et les boutons à droite
      title: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: const [
          Text('(RE)SOURCES'), // Titre à gauche
        ],
      ),
      actions: [
        // Row avec deux boutons
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginPage()),
                );
              },
              child: const Text('Se connecter'),
            ),
            const SizedBox(width: 10), // Espacement entre les boutons
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
              child: const Text("S'inscrire"),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
