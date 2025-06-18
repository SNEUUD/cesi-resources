import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 0.0, vertical: 12.0),
      alignment: Alignment.center,
      child: Container(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            // Si l'écran est trop petit, on passe en colonne
            final isSmall = constraints.maxWidth < 700;
            return isSmall
                ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _footerColumns(isSmall),
                )
                : Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: _footerColumns(isSmall),
                );
          },
        ),
      ),
    );
  }

  List<Widget> _footerColumns(bool isSmall) {
    return [
      Flexible(
        flex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.asset('assets/icons/logo.png', height: 50),
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
      SizedBox(width: isSmall ? 0 : 30, height: isSmall ? 30 : 0),
      Flexible(
        flex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '(re)sources relationnelles',
              style: TextStyle(
                color: Color(0xFF000091),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Contactez-nous',
                style: TextStyle(color: Color(0xFF000091)),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Politique de confidentialité',
                style: TextStyle(color: Color(0xFF000091)),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Mentions légales',
                style: TextStyle(color: Color(0xFF000091)),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Cookies',
                style: TextStyle(color: Color(0xFF000091)),
              ),
            ),
          ],
        ),
      ),
      SizedBox(width: isSmall ? 0 : 30, height: isSmall ? 30 : 0),
      Flexible(
        flex: 1,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Suivez-nous',
              style: TextStyle(
                color: Color(0xFF000091),
                fontWeight: FontWeight.bold,
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Instagram',
                style: TextStyle(color: Color(0xFF000091)),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'Facebook',
                style: TextStyle(color: Color(0xFF000091)),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'YouTube',
                style: TextStyle(color: Color(0xFF000091)),
              ),
            ),
            TextButton(
              onPressed: () {},
              child: const Text(
                'LinkedIn',
                style: TextStyle(color: Color(0xFF000091)),
              ),
            ),
          ],
        ),
      ),
    ];
  }
}
