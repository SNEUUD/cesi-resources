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
  db.query("SELECT nomCatégorie, descriptionCatégorie FROM Catégories", (err, results) => {
    if (err) {
      console.error("Erreur lors de la requête SQL :", err);
      return res.status(500).json({ error: "Erreur serveur" });
    }
    console.log("Catégories récupérées :", results);
    res.json(results);
  });
});

// Route pour récupérer les détails du profil utilisateur
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

    // Formatage de la date de naissance
    const utilisateur = results[0];
    if (utilisateur.dateNaissance) {
      const date = new Date(utilisateur.dateNaissance);
      utilisateur.dateNaissance = date.toLocaleDateString('fr-FR');
    }

    res.status(200).json({ utilisateur });
  });
});

// Route pour modifier les informations du profil
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

  db.query(
      sql,
      [nom, prénom, pseudo, email, idUtilisateur],
      (err, result) => {
        if (err) {
          console.error("Erreur lors de la mise à jour du profil :", err);
          return res.status(500).json({ error: "Erreur serveur" });
        }

        if (result.affectedRows === 0) {
          return res.status(404).json({ error: "Utilisateur non trouvé" });
        }

        res.status(200).json({
          message: "Profil mis à jour avec succès"
        });
      }
  );
});

// Route pour modifier le mot de passe
app.put("/profil/:idUtilisateur/password", (req, res) => {
  const { idUtilisateur } = req.params;
  const { ancienMotDePasse, nouveauMotDePasse } = req.body;

  // Récupérer l'utilisateur
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

        // Vérifier si le mot de passe correspond
        if (utilisateur.motDePasseUtilisateur !== ancienMotDePasse) {
          return res.status(401).json({ error: "Ancien mot de passe incorrect" });
        }

        // Mettre à jour le mot de passe
        const sql = `
        UPDATE Utilisateurs
        SET motDePasseUtilisateur = ?
        WHERE idUtilisateur = ?
      `;

        db.query(
            sql,
            [nouveauMotDePasse, idUtilisateur],
            (err, result) => {
              if (err) {
                console.error("Erreur lors de la mise à jour du mot de passe :", err);
                return res.status(500).json({ error: "Erreur serveur" });
              }

              res.status(200).json({
                message: "Mot de passe mis à jour avec succès"
              });
            }
        );
      }
  );
});


app.listen(3000, () => {
  console.log("Backend listening on port 3000");
});
