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

// --- INSCRIPTION UTILISATEUR ---
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
    (err) => {
      if (err) {
        console.error("Erreur d'inscription :", err);
        return res.status(500).json({ error: "Erreur serveur" });
      }
      res.status(201).json({ message: "Utilisateur inscrit avec succès !" });
    }
  );
});

// --- CONNEXION UTILISATEUR ---
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
      return res.status(401).json({ error: "Email ou mot de passe incorrect" });
    }

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

// --- RÉCUPÉRATION DES CATÉGORIES ---
app.get("/categories", (req, res) => {
  db.query(
    "SELECT idCatégorie, nomCatégorie, descriptionCatégorie FROM Catégories",
    (err, results) => {
      if (err) {
        console.error("Erreur lors de la requête SQL :", err);
        return res.status(500).json({ error: "Erreur serveur" });
      }
      res.json(results);
    }
  );
});

app.post("/resources", (req, res) => {
  const {
    title,
    message,
    date,
    image, // base64
    userId,
    status,
    category,
  } = req.body;

  if (!title || !message || !date) {
    return res.status(400).json({ error: "Champs requis manquants" });
  }

  const imageBuffer = image ? Buffer.from(image, "base64") : null;

  // Tu dois ici convertir le nom de la catégorie en son id
  const categorySql = `SELECT idCatégorie FROM Catégories WHERE nomCatégorie = ?`;

  db.query(categorySql, [category], (err, categoryResults) => {
    if (err || categoryResults.length === 0) {
      console.error("Erreur de catégorie :", err);
      return res.status(400).json({ error: "Catégorie invalide" });
    }

    const categoryId = categoryResults[0].idCatégorie;

    const sql = `
      INSERT INTO Ressources (
        titreRessource,
        messageRessource,
        dateRessource,
        imageRessource,
        Utilisateurs_idUtilisateur,
        statusRessource,
        Catégories_idCatégorie
      ) VALUES (?, ?, ?, ?, ?, ?, ?)
    `;

    db.query(
      sql,
      [
        title,
        message,
        date,
        imageBuffer,
        userId || null,
        status || "affiche",
        categoryId,
      ],
      (err) => {
        if (err) {
          console.error("Erreur lors de l'ajout de la ressource :", err);
          return res.status(500).json({ error: "Erreur serveur" });
        }
        res.status(201).json({ message: "Ressource ajoutée avec succès !" });
      }
    );
  });
});

// --- LANCEMENT DU SERVEUR ---
app.listen(3000, () => {
  console.log("Backend listening on port 3000");
});
