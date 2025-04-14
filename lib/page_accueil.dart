import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec logo et bouton de connexion
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Logo (re)sources relationnelles
                  Row(
                    children: [
                      Container(
                        height: 40,
                        width: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFF000080),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Text(
                            "...",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      const Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "(re)sources",
                            style: TextStyle(
                              color: Color(0xFF000080),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            "relationnelles",
                            style: TextStyle(
                              color: Color(0xFF000080),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  
                  // Bouton de connexion
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF000080),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    ),
                    child: const Text("Se connecter / S'inscrire"),
                  ),
                ],
              ),
            ),
            
            // Section principale
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Colonne gauche avec texte
                  Expanded(
                    flex: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const Text(
                          "Faites un pas de plus vers une vie sereine et épanouie",
                          style: TextStyle(
                            color: Color(0xFF000080),
                            fontWeight: FontWeight.bold,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",
                          style: TextStyle(
                            color: Color(0xFF000080),
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF000080),
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20),
                            ),
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          ),
                          child: const Text("Rejoins d'aventure !"),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 20),
                  // Colonne droite avec image
                  Expanded(
                    flex: 5,
                    child: Container(
                      height: 250,
                      decoration: BoxDecoration(
                        color: const Color(0xFF000080),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text(
                          "Image\nà ajouter",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            
            // Section "Qu'est ce qui vous intéresse?"
            const SizedBox(height: 60),
            Container(
              padding: const EdgeInsets.symmetric(vertical: 15),
              decoration: BoxDecoration(
                color: const Color(0xFF000080),
                borderRadius: BorderRadius.circular(30),
              ),
              width: MediaQuery.of(context).size.width * 0.5,
              child: const Center(
                child: Text(
                  "Qu'est ce qui vous intéresse ?",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            
            // Catégories
            const SizedBox(height: 30),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Wrap(
                spacing: 20,
                runSpacing: 20,
                alignment: WrapAlignment.center,
                children: [
                  _buildCategoryButton("Communication", Colors.blue.shade50, Colors.blue.shade800),
                  _buildCategoryButton("Développement personnel", Colors.red.shade50, Colors.red.shade800),
                  _buildCategoryButton("Cultures", Colors.blue.shade100, Colors.blue.shade900),
                  _buildCategoryButton("Sport", Colors.red.shade50, Colors.red.shade800),
                  _buildCategoryButton("Cuisine", Colors.green.shade50, Colors.green.shade800),
                  _buildCategoryButton("Informatique", Colors.amber.shade50, Colors.amber.shade800),
                  _buildCategoryButton("Musique", Colors.green.shade50, Colors.green.shade800),
                  _buildCategoryButton("Développement professionnel", Colors.blue.shade900, Colors.white),
                  _buildCategoryButton("Parentalité", Colors.blue.shade50, Colors.blue.shade800),
                ],
              ),
            ),
            
            // Bouton "En voir plus"
            const SizedBox(height: 30),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF000080),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 10),
              ),
              child: const Text("En voir plus"),
            ),
            
            // Footer
            const SizedBox(height: 60),
            Container(
              color: Colors.grey.shade50,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 30),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Première colonne
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              height: 30,
                              width: 30,
                              decoration: BoxDecoration(
                                color: const Color(0xFF000080),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Center(
                                child: Text(
                                  "...",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "(re)sources",
                                  style: TextStyle(
                                    color: Color(0xFF000080),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  "relationnelles",
                                  style: TextStyle(
                                    color: Color(0xFF000080),
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Vous avez le pouvoir de changer.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          "Faites un pas de plus vers une vie sereine",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const Text(
                          "et épanouie.",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "© 2024 (re)sources relationnelles",
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Deuxième colonne
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "(re)sources relationnelles",
                          style: TextStyle(
                            color: Color(0xFF000080),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildFooterLink("Contactez-nous"),
                        const SizedBox(height: 10),
                        _buildFooterLink("Politique de confidentialité"),
                        const SizedBox(height: 10),
                        _buildFooterLink("Mentions légales"),
                        const SizedBox(height: 10),
                        _buildFooterLink("Cookies"),
                      ],
                    ),
                  ),
                  
                  // Troisième colonne
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Suivez-nous",
                          style: TextStyle(
                            color: Color(0xFF000080),
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 20),
                        _buildSocialLink("Instagram"),
                        const SizedBox(height: 10),
                        _buildSocialLink("Facebook"),
                        const SizedBox(height: 10),
                        _buildSocialLink("Youtube"),
                        const SizedBox(height: 10),
                        _buildSocialLink("LinkedIn"),
                      ],
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
  
  Widget _buildCategoryButton(String text, Color bgColor, Color textColor) {
    return Container(
      width: 180,
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: textColor, width: 1),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget _buildFooterLink(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF000080),
        fontSize: 12,
      ),
    );
  }
  
  Widget _buildSocialLink(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Color(0xFF000080),
        fontSize: 12,
      ),
    );
  }
}