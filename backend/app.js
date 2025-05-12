const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
require("dotenv").config();
const { v4: uuidv4 } = require("uuid");

const app = express();
app.use(cors());
app.use(express.json());

const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

app.post("/register", (req, res) => {
  const {
    nomUtilisateur,
    prénomUtilisateur,
    dateNaissanceUtilisateur,
    sexeUtilisateur,
    pseudoUtilisateur,
    emailUtilisateur,
    motDePasseUtilisateur,
  } = req.body;

  const idUtilisateur = uuidv4();

  const reformattedDate = dateNaissanceUtilisateur
    .split("/")
    .reverse()
    .join("-");

  const sql = `
    INSERT INTO Utilisateurs 
    (idUtilisateur, nomUtilisateur, prénomUtilisateur, dateNaissanceUtilisateur, sexeUtilisateur, pseudoUtilisateur, emailUtilisateur, motDePasseUtilisateur, statusUtilisateur, Roles_idRole)
    VALUES (?, ?, ?, ?, ?, ?, ?, ?, 'activé', 1)
  `;

  db.query(
    sql,
    [
      idUtilisateur,
      nomUtilisateur,
      prénomUtilisateur,
      reformattedDate,
      sexeUtilisateur,
      pseudoUtilisateur,
      emailUtilisateur,
      motDePasseUtilisateur,
    ],
    (err, result) => {
      if (err) {
        console.error("Erreur d'inscription :", err);
        return res.status(500).json({ error: "Erreur serveur" });
      }
      res.status(201).json({ message: "Utilisateur inscrit avec succès !" });
    }
  );
});

app.post("/login", (req, res) => {
  const { emailUtilisateur, motDePasseUtilisateur } = req.body;

  const sql = `
    SELECT * FROM Utilisateurs 
    WHERE emailUtilisateur = ? AND motDePasseUtilisateur = ?
  `;

  db.query(sql, [emailUtilisateur, motDePasseUtilisateur], (err, results) => {
    if (err) {
      console.error("Erreur lors de la connexion :", err);
      return res.status(500).json({ error: "Erreur serveur" });
    }

    if (results.length === 0) {
      // Aucun utilisateur trouvé avec ces identifiants
      return res.status(401).json({ error: "Email ou mot de passe incorrect" });
    }

    // Utilisateur trouvé
    const utilisateur = results[0];
    res.status(200).json({
      message: "Connexion réussie",
      utilisateur: {
        id: utilisateur.idUtilisateur,
        nom: utilisateur.nomUtilisateur,
        prénom: utilisateur.prénomUtilisateur,
        email: utilisateur.emailUtilisateur,
        pseudo: utilisateur.pseudoUtilisateur,
        role: utilisateur.Roles_idRole,
      },
    });
  });
});

// Route pour récupérer toutes les catégories avec leurs descriptions
app.get("/categories", (req, res) => {
  db.query("SELECT idCatégorie, nomCatégorie, descriptionCatégorie FROM Catégories", (err, results) => {
    if (err) {
      console.error("Erreur lors de la requête SQL :", err);
      return res.status(500).json({ error: "Erreur serveur" });
    }
    console.log("Catégories récupérées :", results);
    res.json(results);
  });
});


app.listen(3000, () => {
  console.log("Backend listening on port 3000");
});


// ELIIIIIIIIIOOOOOOOOO
app.get("/resources/category/:categoryName", (req, res) => {
  const categoryName = req.params.categoryName;

  // Requête SQL pour récupérer les ressources d'une catégorie spécifique
  const query = `
    SELECT r.idRessource,r.titreRessource,r.messageRessource,r.dateRessource,r.imageRessource,u.pseudoUtilisateur,r.statusRessource,c.nomCatégorie
FROM Ressources r
JOIN Catégories c ON r.Catégories_idCatégorie = c.idCatégorie
JOIN Utilisateurs u ON r.Utilisateurs_idUtilisateur = u.idUtilisateur
WHERE c.nomCatégorie = ? AND r.statusRessource = 'affiche';
  `;

  db.query(query, [categoryName], (err, results) => {
    if (err) {
      console.error("Erreur lors de la requête SQL :", err);
      return res.status(500).json({ error: "Erreur serveur" });
    }
    console.log(`Ressources de la catégorie ${categoryName} récupérées :`, results);
    res.json(results);
  });
});
