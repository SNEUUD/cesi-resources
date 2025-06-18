import 'package:flutter/material.dart';
import 'view/layout/header.dart';

// Ta classe Footer complète (copiée ici pour que le code soit complet)
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

// MainApp + HomePage

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(
        fontFamily: 'Roboto',
        textTheme: const TextTheme(
          bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400),
          bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400),
          bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w300),
        ),
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const Header(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(40),
                child: Row(
                  children: [
                    Expanded(
                      flex: 2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Faites un pas de plus vers une vie sereine et épanouie',
                            style: TextStyle(
                              fontSize: 48,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1E3A8A),
                              height: 1.2,
                            ),
                          ),
                          const SizedBox(height: 24),
                          const Text(
                            'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.',
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.grey,
                              height: 1.6,
                            ),
                          ),
                          const SizedBox(height: 32),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF1E3A8A),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 32,
                                vertical: 16,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Rejoins d\'aventure !',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 60),
                    Expanded(
                      flex: 1,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.asset(
                            'assets/icons/main.png',
                            fit: BoxFit.cover,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const Footer(),
        ],
      ),
    );
  }
}
