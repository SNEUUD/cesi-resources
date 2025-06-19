import 'package:flutter/material.dart';
import 'package:resources/view/layout/footer.dart';
import 'view/layout/header.dart';

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
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
    final isMobile = MediaQuery.of(context).size.width < 600;

    return Scaffold(
      appBar: const Header(),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Container(
                color: Colors.white,
                padding: isMobile
                    ? const EdgeInsets.all(20)
                    : const EdgeInsets.all(40),
                child: isMobile ? _buildMobileContent() : _buildDesktopContent(),
              ),
            ),
          ),
          const Footer(),
        ],
      ),
    );
  }

  Widget _buildDesktopContent() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: _buildTextColumn(fontSizeTitle: 48, fontSizeText: 16, spacing: 24),
        ),
        const SizedBox(width: 60),
        Expanded(
          flex: 1,
          child: _buildImage(),
        ),
      ],
    );
  }

  Widget _buildMobileContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextColumn(fontSizeTitle: 32, fontSizeText: 14, spacing: 16),
        const SizedBox(height: 24),
        _buildImage(),
      ],
    );
  }

  Widget _buildTextColumn({required double fontSizeTitle, required double fontSizeText, required double spacing}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Faites un pas de plus vers une vie sereine et épanouie',
          style: TextStyle(
            fontSize: fontSizeTitle,
            fontWeight: FontWeight.bold,
            color: const Color(0xFF1E3A8A),
            height: 1.2,
          ),
        ),
        SizedBox(height: spacing),
        Text(
          'Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua...',
          style: TextStyle(
            fontSize: fontSizeText,
            color: Colors.grey,
            height: 1.6,
          ),
        ),
        SizedBox(height: spacing * 1.3),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF1E3A8A),
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: Text(
            "Rejoins l'aventure !",
            style: TextStyle(fontSize: fontSizeText),
          ),
        ),
      ],
    );
  }

  Widget _buildImage() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.asset(
          'assets/icons/main.png', // Vérifie que ce fichier existe bien
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
