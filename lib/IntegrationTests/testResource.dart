import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  test('Création et vérification d\'une ressource via l\'API', () async {
    // Données de test
    final title = "Titre test intégration";
    final message = "Description test intégration";
    final selectedDate = DateTime(2024, 6, 1, 12, 0, 0);
    final imageBase64 = "fauseimage"; // ou une image encodée
    final utilisateurId = "2e0d487d-535b-42b5-91a9-ecaffafb7cfc"; // Remplacez par un id réel
    final status = "affiche";
    final category = "Musique";

    // 1. Création de la ressource
    final postResponse = await http.post(
      Uri.parse('http://localhost:3000/test/resources'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': title,
        'message': message,
        'date': selectedDate.toIso8601String(),
        'image': imageBase64,
        'userId': utilisateurId,
        'status': status,
        'category': category,
      }),
    );

    expect(postResponse.statusCode, anyOf(200, 201));

    // 2. Vérification de la présence en base
    final getResponse = await http.get(
      Uri.parse('http://localhost:3000/test/ressourcesAll'),
    );
    expect(getResponse.statusCode, 200);

    final List ressources = jsonDecode(getResponse.body);
    final existe = ressources.any((r) =>
    r['titre'] == title &&
        r['description'] == message &&
        r['nomCategorie'] == category
    );
    expect(existe, isTrue);
  });
}