import 'package:flutter_test/flutter_test.dart';

List<Map<String, String>> filtrerRessources(List<Map<String, String>> ressources, String requete) {
  requete = requete.toLowerCase();
  return ressources.where((ressource) {
    final titre = ressource['titre']?.toLowerCase() ?? '';
    final description = ressource['description']?.toLowerCase() ?? '';
    final categorie = ressource['nomCategorie']?.toLowerCase() ?? '';
    return titre.contains(requete) || description.contains(requete) || categorie.contains(requete);
  }).toList();
}

void main() {
  test('filtrerRessources retourne les correspondances attendues', () {
    final donnees = [
      {
        'titre': 'Musique Relaxante',
        'description': 'Une ressource pour se détendre',
        'nomCategorie': 'Musique',
      },
      {
        'titre': 'Sport et santé',
        'description': 'Faire du sport régulièrement',
        'nomCategorie': 'Bien-être',
      },
    ];

    final resultat = filtrerRessources(donnees, 'musique');

    expect(resultat.length, 1);
    expect(resultat.first['titre'], 'Musique Relaxante');
  });

  test('filtrerRessources ignore la casse et cherche dans la description', () {
    final donnees = [
      {
        'titre': 'Yoga',
        'description': 'Relaxation par les postures',
        'nomCategorie': 'Sport',
      },
    ];

    final resultat = filtrerRessources(donnees, 'RELAXATION');
    expect(resultat.length, 1);
    expect(resultat.first['titre'], 'Yoga');
  });

  test('filtrerRessources retourne tout si la requête est vide', () {
    final donnees = [
      {'titre': 'A', 'description': 'B', 'nomCategorie': 'C'},
      {'titre': 'D', 'description': 'E', 'nomCategorie': 'F'},
    ];

    final resultat = filtrerRessources(donnees, '');
    expect(resultat.length, 2);
  });
}
