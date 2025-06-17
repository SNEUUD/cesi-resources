import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // Répartit l'espace de manière égale
          crossAxisAlignment: CrossAxisAlignment.start, // Aligne les colonnes en haut
          children: [
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Centre le contenu horizontalement
                children: [
                  Image.asset(
                    'assets/icons/logo.png',
                    height: 50,
                  ),
                  const SizedBox(height: 15.0),
                  const Text(
                    'Vous avez le pouvoir de changer.',
                    style: TextStyle(color: Color(0xFF000091)),
                  ),
                  const Text(
                    'Faites un pas de plus vers une vie sereine et épanouie.',
                    style: TextStyle(color: Color(0xFF000091)),
                  ),
                  const SizedBox(height: 15.0),
                  const Text(
                    '© 2025 (re)sources relationnelles',
                    style: TextStyle(color: Color(0xFF000091)),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Centre le contenu horizontalement
                children: [
                  const Text(
                    '(re)sources relationnelles',
                    style: TextStyle(
                      color: Color(0xFF000091),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to contact page
                    },
                    child: const Text(
                      'Contactez-nous',
                      style: TextStyle(color: Color(0xFF000091)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to privacy policy
                    },
                    child: const Text(
                      'Politique de confidentialité',
                      style: TextStyle(color: Color(0xFF000091)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to legal mentions
                    },
                    child: const Text(
                      'Mentions légales',
                      style: TextStyle(color: Color(0xFF000091)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to cookies policy
                    },
                    child: const Text(
                      'Cookies',
                      style: TextStyle(color: Color(0xFF000091)),
                    ),
                  ),
                ],
              ),
            ),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start, // Centre le contenu horizontalement
                children: [
                  const Text(
                    'Suivez-nous',
                    style: TextStyle(
                      color: Color(0xFF000091),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to Instagram
                    },
                    child: const Text(
                      'Instagram',
                      style: TextStyle(color: Color(0xFF000091)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to Facebook
                    },
                    child: const Text(
                      'Facebook',
                      style: TextStyle(color: Color(0xFF000091)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to YouTube
                    },
                    child: const Text(
                      'YouTube',
                      style: TextStyle(color: Color(0xFF000091)),
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      // Navigate to LinkedIn
                    },
                    child: const Text(
                      'LinkedIn',
                      style: TextStyle(color: Color(0xFF000091)),
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
