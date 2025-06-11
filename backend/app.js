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

// --- AJOUT DE RESSOURCE ---
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

// --- PROFIL UTILISATEUR ---
app.get("/profil/:idUtilisateur", (req, res) => {
  const { idUtilisateur } = req.params;

  const sql = `
    SELECT nomUtilisateur as nom, 
           prénomUtilisateur as prénom, 
           dateNaissanceUtilisateur as dateNaissance,
           sexeUtilisateur as sexe, 
           pseudoUtilisateur as pseudo, 
           emailUtilisateur as email, 
           Roles_idRole as role
    FROM Utilisateurs 
    WHERE idUtilisateur = ?
  `;

  db.query(sql, [idUtilisateur], (err, results) => {
    if (err) {
      console.error("Erreur lors de la récupération du profil :", err);
      return res.status(500).json({ error: "Erreur serveur" });
    }

    if (results.length === 0) {
      return res.status(404).json({ error: "Utilisateur non trouvé" });
    }

    const utilisateur = results[0];
    if (utilisateur.dateNaissance) {
      const date = new Date(utilisateur.dateNaissance);
      utilisateur.dateNaissance = date.toLocaleDateString("fr-FR");
    }

    res.status(200).json({ utilisateur });
  });
});

// --- MODIFIER PROFIL ---
app.put("/profil/:idUtilisateur/edit", (req, res) => {
  const { idUtilisateur } = req.params;
  const { nom, prénom, pseudo, email } = req.body;

  const sql = `
    UPDATE Utilisateurs
    SET nomUtilisateur = ?,
        prénomUtilisateur = ?,
        pseudoUtilisateur = ?,
        emailUtilisateur = ?
    WHERE idUtilisateur = ?
  `;

  db.query(sql, [nom, prénom, pseudo, email, idUtilisateur], (err, result) => {
    if (err) {
      console.error("Erreur lors de la mise à jour du profil :", err);
      return res.status(500).json({ error: "Erreur serveur" });
    }

    if (result.affectedRows === 0) {
      return res.status(404).json({ error: "Utilisateur non trouvé" });
    }

    res.status(200).json({ message: "Profil mis à jour avec succès" });
  });
});

// --- MODIFIER MOT DE PASSE ---
app.put("/profil/:idUtilisateur/password", (req, res) => {
  const { idUtilisateur } = req.params;
  const { ancienMotDePasse, nouveauMotDePasse } = req.body;

  db.query(
    "SELECT idUtilisateur, motDePasseUtilisateur FROM Utilisateurs WHERE idUtilisateur = ?",
    [idUtilisateur],
    (err, results) => {
      if (err) {
        console.error("Erreur lors de la récupération de l'utilisateur :", err);
        return res.status(500).json({ error: "Erreur serveur" });
      }

      if (results.length === 0) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }

      const utilisateur = results[0];
      if (utilisateur.motDePasseUtilisateur !== ancienMotDePasse) {
        return res.status(401).json({ error: "Ancien mot de passe incorrect" });
      }

      const sql = `
        UPDATE Utilisateurs
        SET motDePasseUtilisateur = ?
        WHERE idUtilisateur = ?
      `;

      db.query(sql, [nouveauMotDePasse, idUtilisateur], (err) => {
        if (err) {
          console.error("Erreur lors de la mise à jour du mot de passe :", err);
          return res.status(500).json({ error: "Erreur serveur" });
        }

        res
          .status(200)
          .json({ message: "Mot de passe mis à jour avec succès" });
      });
    }
  );
});

// --- RESSOURCES PAR CATÉGORIE ---
app.get("/ressources", (req, res) => {
  const { categorie } = req.query;
  if (!categorie) {
    return res.status(400).json({ error: "Catégorie manquante" });
  }

  const sql = `
    SELECT r.idRessource, r.titreRessource AS titre, r.messageRessource AS description, 
           r.dateRessource, r.statusRessource, r.imageRessource
    FROM Ressources r
    JOIN Catégories c ON r.Catégories_idCatégorie = c.idCatégorie
    WHERE c.nomCatégorie = ?
    ORDER BY r.dateRessource DESC
  `;

  db.query(sql, [categorie], (err, results) => {
    if (err) {
      console.error("Erreur lors de la récupération des ressources :", err);
      return res.status(500).json({ error: "Erreur serveur" });
    }

    // Encoder les images en base64
    const ressources = results.map((ressource) => {
      return {
        ...ressource,
        imageRessource: ressource.imageRessource
          ? Buffer.from(ressource.imageRessource).toString("base64")
          : null,
      };
    });

    res.json(ressources);
  });
});

// --- LANCEMENT DU SERVEUR ---
app.listen(3000, () => {
  console.log("Backend listening on port 3000");
});
