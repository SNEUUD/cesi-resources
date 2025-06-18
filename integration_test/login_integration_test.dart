import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import '../lib/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Test d\'intégration : Connexion utilisateur', (
    WidgetTester tester,
  ) async {
    app.main();
    await tester.pumpAndSettle();

    // Naviguer vers la page de connexion si besoin (adapter selon votre navigation)
    final loginButton = find.text('Se connecter');
    if (loginButton.evaluate().isNotEmpty) {
      await tester.tap(loginButton);
      await tester.pumpAndSettle();
    }

    // Remplir les champs email et mot de passe
    final emailField = find.byType(TextField).at(0);
    final passwordField = find.byType(TextField).at(1);

    await tester.enterText(emailField, 'test');
    await tester.enterText(passwordField, 'test');

    // Appuyer sur le bouton de connexion
    final submitButton = find.text('Se connecter');
    await tester.tap(submitButton);
    await tester.pumpAndSettle();

    // Vérifier la présence du message de bienvenue ou la redirection
    expect(find.textContaining('Bienvenue'), findsOneWidget);

    // Vérifier la présence de l'id dans les shared_preferences
    final prefs = await SharedPreferences.getInstance();
    final idUtilisateur = prefs.getString('idUtilisateur');
    expect(
      idUtilisateur,
      isNotNull,
      reason:
          "L'id utilisateur doit être présent dans les shared_preferences après connexion.",
    );
  });
}
