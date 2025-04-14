import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Ligne principale avec 3 colonnes
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Logo et baseline
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Row(
                    children: [
                      Icon(Icons.message, color: Colors.red, size: 30), // Remplace par le vrai logo
                      SizedBox(width: 8),
                      Text(
                        '(re)sources\nrelationnelles',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.indigo,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  Text(
                    'Vous avez le pouvoir de changer.\nFaites un pas de plus vers une vie sereine et épanouie.',
                    style: TextStyle(fontSize: 14, color: Colors.black87),
                  ),
                  SizedBox(height: 10),
                  Text('© 2024 (re)sources relationnelles', style: TextStyle(fontSize: 12)),
                ],
              ),

              // Liens institutionnels
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '(re)sources relationnelles',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 10),
                  _FooterLink('Contactez-nous', 'mailto:contact@example.com'),
                  _FooterLink('Politique de confidentialité', 'https://example.com/confidentialite'),
                  _FooterLink('Mentions légales', 'https://example.com/mentions'),
                  _FooterLink('Cookies', 'https://example.com/cookies'),
                ],
              ),

              // Réseaux sociaux
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Suivez-nous',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo),
                  ),
                  const SizedBox(height: 10),
                  _FooterLink('Instagram', 'https://instagram.com'),
                  _FooterLink('Facebook', 'https://facebook.com'),
                  _FooterLink('Youtube', 'https://youtube.com'),
                  _FooterLink('Linkedin', 'https://linkedin.com'),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _FooterLink extends StatelessWidget {
  final String text;
  final String url;

  const _FooterLink(this.text, this.url, {super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final uri = Uri.parse(url);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri);
        }
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.indigo,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    );
  }
}
