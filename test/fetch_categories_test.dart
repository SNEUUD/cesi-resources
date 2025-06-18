import 'package:flutter_test/flutter_test.dart';

class Categorie {
  final String nomCategorie;
  final String description;

  Categorie({required this.nomCategorie, required this.description});

  factory Categorie.fromJson(Map<String, dynamic> json) {
    return Categorie(
      nomCategorie: json['nomCatégorie'],
      description: json['descriptionCatégorie'],
    );
  }
}

void main() {
  test('Categorie.fromJson analyse correctement les données', () {
    final json = {
      'nomCatégorie': 'Éducation',
      'descriptionCatégorie': 'Ressources éducatives',
    };

    final categorie = Categorie.fromJson(json);

    expect(categorie.nomCategorie, 'Éducation');
    expect(categorie.description, 'Ressources éducatives');
  });

  test('Categorie.fromJson fonctionne avec des chaînes vides', () {
    final json = {
      'nomCatégorie': '',
      'descriptionCatégorie': '',
    };

    final categorie = Categorie.fromJson(json);

    expect(categorie.nomCategorie, '');
    expect(categorie.description, '');
  });
}
