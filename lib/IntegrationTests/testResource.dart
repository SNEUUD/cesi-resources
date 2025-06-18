import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  test('Création et vérification d\'une ressource via l\'API', () async {
    // Données de test
    final _title = "Titre test intégration";
    final _message = "Description test intégration";
    final _selectedDate = DateTime(2024, 6, 1, 12, 0, 0);
    final imageBase64 = "fauseimage"; // ou une image encodée
    final _utilisateurId = "2e0d487d-535b-42b5-91a9-ecaffafb7cfc"; // Remplacez par un id réel
    final _status = "affiche";
    final _category = "Musique";

    // 1. Création de la ressource
    final postResponse = await http.post(
      Uri.parse('http://localhost:3000/test/resources'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'title': _title,
        'message': _message,
        'date': _selectedDate.toIso8601String(),
        'image': imageBase64,
        'userId': _utilisateurId,
        'status': _status,
        'category': _category,
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
    r['titre'] == _title &&
        r['description'] == _message &&
        r['nomCategorie'] == _category
    );
    expect(existe, isTrue);
  });
}