import 'package:flutter/material.dart';

class Footer extends StatelessWidget {
  const Footer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.white,
      padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1200),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isSmall = constraints.maxWidth < 700;

            return isSmall
                ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _logoSection(),
                const SizedBox(height: 25),

                // Ligne unique pour la 1ère colonne (liens)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _footerLinks()
                        .map((text) => Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        text,
                        style: const TextStyle(color: Color(0xFF000091)),
                      ),
                    ))
                        .toList(),
                  ),
                ),

                const SizedBox(height: 20),

                // Ligne unique pour la 2ème colonne (réseaux sociaux)
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _footerSocials()
                        .map((text) => Padding(
                      padding: const EdgeInsets.only(right: 20),
                      child: Text(
                        text,
                        style: const TextStyle(color: Color(0xFF000091)),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ],
            )
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Flexible(flex: 1, child: _logoSection()),
                const SizedBox(width: 30),
                Flexible(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _footerLinks()
                        .map((text) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          text,
                          style: const TextStyle(color: Color(0xFF000091)),
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ),
                const SizedBox(width: 30),
                Flexible(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _footerSocials()
                        .map((text) => Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: TextButton(
                        onPressed: () {},
                        child: Text(
                          text,
                          style: const TextStyle(color: Color(0xFF000091)),
                        ),
                      ),
                    ))
                        .toList(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _logoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image.asset('assets/icons/logo.png', height: 50),
        const SizedBox(height: 15),
        const Text(
          'Vous avez le pouvoir de changer.',
          style: TextStyle(color: Color(0xFF000091)),
        ),
        const Text(
          'Faites un pas de plus vers une vie sereine et épanouie.',
          style: TextStyle(color: Color(0xFF000091)),
        ),
        const SizedBox(height: 15),
        const Text(
          '© 2025 (re)sources relationnelles',
          style: TextStyle(color: Color(0xFF000091)),
        ),
      ],
    );
  }

  List<String> _footerLinks() {
    return [
      'Contactez-nous',
      'Politique de confidentialité',
      'Mentions légales',
      'Cookies',
    ];
  }

  List<String> _footerSocials() {
    return [
      'Instagram',
      'Facebook',
      'YouTube',
      'LinkedIn',
    ];
  }
}
