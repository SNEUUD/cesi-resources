import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'Test d\'intégration : Connexion utilisateur puis création ressource',
    (WidgetTester tester) async {
      app.main();
      await tester.pumpAndSettle();

      // Partie connexion - comme tu avais avant
      final loginButton = find.text('Se connecter');
      if (loginButton.evaluate().isNotEmpty) {
        await tester.tap(loginButton);
        await tester.pumpAndSettle();

        final emailField = find.byType(TextField).at(0);
        final passwordField = find.byType(TextField).at(1);

        await tester.enterText(emailField, 'test');
        await tester.enterText(passwordField, 'test');

        final submitButton = find.text('Se connecter');
        await tester.tap(submitButton);
        await tester.pumpAndSettle();
      }

      // Vérifier la présence de l'id utilisateur dans shared_preferences
      final prefs = await SharedPreferences.getInstance();
      final idUtilisateur = prefs.getString('idUtilisateur');
      expect(
        idUtilisateur,
        isNotNull,
        reason:
            "L'id utilisateur doit être dans shared_preferences après connexion.",
      );

      // Aller sur la page création ressource
      final createResourceButton = find.text('Créer une ressource');
      await tester.tap(createResourceButton);
      await tester.pumpAndSettle();

      // Remplir les champs du formulaire création ressource (TextFormField avec labels)
      final titreField = find.widgetWithText(TextFormField, 'Intitulé *');
      final messageField = find.widgetWithText(TextFormField, 'Message *');

      await tester.enterText(titreField, 'Titre test intégration');
      await tester.enterText(messageField, 'Description test intégration');

      // Sélectionner une catégorie dans le DropdownButtonFormField
      final categoryDropdown = find.widgetWithText(
        DropdownButtonFormField<String>,
        'Catégorie *',
      );
      await tester.tap(categoryDropdown);
      await tester.pumpAndSettle();

      // Choisir la première catégorie disponible
      final firstCategory = find.byType(DropdownMenuItem<String>).first;
      await tester.tap(firstCategory);
      await tester.pumpAndSettle();

      // Appuyer sur le bouton "Enregistrer"
      final submitResourceButton = find.widgetWithText(
        ElevatedButton,
        'Enregistrer',
      );
      await tester.tap(submitResourceButton);
      await tester.pumpAndSettle();

      // Vérifier la présence du message de succès
      expect(find.text('Ressource ajoutée avec succès !'), findsOneWidget);
    },
  );
}
