const express = require("express");
const cors = require("cors");
const { v4: uuidv4 } = require("uuid");

// Charger le bon fichier .env selon l'environnement
const environment = process.env.NODE_ENV || "development";
require("dotenv").config({
  path: environment === "test" ? ".env.test" : ".env",
});

// Connexions à la BDD
const { db, dbTest } = require("./db");

const app = express();
app.use(cors());
app.use(express.json());

const getDB = (req) => (req.path.startsWith("/test") ? dbTest : db);

// --- INSCRIPTION UTILISATEUR ---
app.post(["/register", "/test/register"], (req, res) => {
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

  const conn = getDB(req);
  conn.query(
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
app.post(["/login", "/test/login"], (req, res) => {
  const { emailUtilisateur, motDePasseUtilisateur } = req.body;

  const sql = `
    SELECT * FROM Utilisateurs
    WHERE emailUtilisateur = ? AND motDePasseUtilisateur = ?
  `;

  const conn = getDB(req);
  conn.query(sql, [emailUtilisateur, motDePasseUtilisateur], (err, results) => {
    if (err) {
      console.error("Erreur lors de la connexion :", err);
      return res.status(500).json({ error: "Erreur serveur" });
    }

    if (results.length === 0) {
      return res.status(401).json({ error: "Email ou mot de passe incorrect" });
    }

    const utilisateur = results[0];

    // Vérification du statut
    if (utilisateur.statusUtilisateur === "désactivé") {
      return res.status(403).json({
        error: "Compte suspendu. Veuillez contacter l'administrateur.",
      });
    }

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
app.get(["/categories", "/test/categories"], (req, res) => {
  const conn = getDB(req);
  conn.query(
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
app.post(["/resources", "/test/resources"], (req, res) => {
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

  const conn = getDB(req);
  const imageBuffer = image ? Buffer.from(image, "base64") : null;

  const categorySql = `SELECT idCatégorie FROM Catégories WHERE nomCatégorie = ?`;

  conn.query(categorySql, [category], (err, categoryResults) => {
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

    conn.query(
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
app.get(
  ["/profil/:idUtilisateur", "/test/profil/:idUtilisateur"],
  (req, res) => {
    const { idUtilisateur } = req.params;
    const conn = getDB(req);

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

    conn.query(sql, [idUtilisateur], (err, results) => {
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
  }
);

// --- MODIFIER PROFIL ---
app.put(
  ["/profil/:idUtilisateur/edit", "/test/profil/:idUtilisateur/edit"],
  (req, res) => {
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

    const conn = getDB(req);
    conn.query(
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

        res.status(200).json({ message: "Profil mis à jour avec succès" });
      }
    );
  }
);

// --- MODIFIER MOT DE PASSE ---
app.put(
  ["/profil/:idUtilisateur/password", "/test/profil/:idUtilisateur/password"],
  (req, res) => {
    const { idUtilisateur } = req.params;
    const { ancienMotDePasse, nouveauMotDePasse } = req.body;

    const conn = getDB(req);
    conn.query(
      "SELECT idUtilisateur, motDePasseUtilisateur FROM Utilisateurs WHERE idUtilisateur = ?",
      [idUtilisateur],
      (err, results) => {
        if (err) {
          console.error(
            "Erreur lors de la récupération de l'utilisateur :",
            err
          );
          return res.status(500).json({ error: "Erreur serveur" });
        }

        if (results.length === 0) {
          return res.status(404).json({ error: "Utilisateur non trouvé" });
        }

        const utilisateur = results[0];
        if (utilisateur.motDePasseUtilisateur !== ancienMotDePasse) {
          return res
            .status(401)
            .json({ error: "Ancien mot de passe incorrect" });
        }

        const sql = `
          UPDATE Utilisateurs
          SET motDePasseUtilisateur = ?
          WHERE idUtilisateur = ?
        `;

        conn.query(sql, [nouveauMotDePasse, idUtilisateur], (err) => {
          if (err) {
            console.error(
              "Erreur lors de la mise à jour du mot de passe :",
              err
            );
            return res.status(500).json({ error: "Erreur serveur" });
          }

          res
            .status(200)
            .json({ message: "Mot de passe mis à jour avec succès" });
        });
      }
    );
  }
);

// --- RESSOURCES PAR CATÉGORIE ---
app.get(["/ressources", "/test/ressources"], (req, res) => {
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

  const conn = getDB(req);
  conn.query(sql, [categorie], (err, results) => {
    if (err) {
      console.error("Erreur lors de la récupération des ressources :", err);
      return res.status(500).json({ error: "Erreur serveur" });
    }

    const ressources = results.map((ressource) => ({
      ...ressource,
      imageRessource: ressource.imageRessource
        ? Buffer.from(ressource.imageRessource).toString("base64")
        : null,
    }));

    res.json(ressources);
  });
});

// --- TOUTES LES RESSOURCES ---
app.get(["/ressourcesAll", "/test/ressourcesAll"], (req, res) => {
  const sql = `
    SELECT r.idRessource, r.titreRessource AS titre, r.messageRessource AS description,
           r.dateRessource, r.statusRessource, r.imageRessource, c.nomCatégorie AS nomCategorie
    FROM Ressources r
           JOIN Catégories c ON r.Catégories_idCatégorie = c.idCatégorie
    ORDER BY r.dateRessource DESC
  `;

  const conn = getDB(req);
  conn.query(sql, (err, results) => {
    if (err) {
      console.error("Erreur lors de la récupération des ressources :", err);
      return res.status(500).json({ error: "Erreur serveur" });
    }

    const ressources = results.map((ressource) => ({
      ...ressource,
      imageRessource: ressource.imageRessource
        ? Buffer.from(ressource.imageRessource).toString("base64")
        : null,
    }));

    res.json(ressources);
  });
});

// --- GESTION DES UTILISATEURS (ADMIN) ---
app.get(["/utilisateurs", "/test/utilisateurs"], (req, res) => {
  const conn = getDB(req);
  conn.query(
    "SELECT idUtilisateur as id, pseudoUtilisateur as pseudo, emailUtilisateur as email, statusUtilisateur as status, Roles_idRole as role FROM Utilisateurs",
    (err, results) => {
      if (err) {
        console.error("Erreur lors de la récupération des utilisateurs :", err);
        return res.status(500).json({ error: "Erreur serveur" });
      }
      res.json(results);
    }
  );
});

// Suspendre un utilisateur (désactiver le compte)
app.patch(
  ["/utilisateurs/:id/suspendre", "/test/utilisateurs/:id/suspendre"],
  (req, res) => {
    const { id } = req.params;
    const { statusUtilisateur } = req.body; // attend 'désactivé' ou 'activé'
    const conn = getDB(req);

    // Par défaut, on désactive si rien n'est précisé
    const newStatus = statusUtilisateur === "activé" ? "activé" : "désactivé";

    conn.query(
      "UPDATE Utilisateurs SET statusUtilisateur = ? WHERE idUtilisateur = ?",
      [newStatus, id],
      (err, result) => {
        if (err) {
          console.error("Erreur lors de la suspension :", err);
          return res.status(500).json({ error: "Erreur serveur" });
        }
        if (result.affectedRows === 0) {
          return res.status(404).json({ error: "Utilisateur non trouvé" });
        }
        res.json({
          message: `Utilisateur ${
            newStatus === "désactivé" ? "suspendu" : "activé"
          } avec succès`,
        });
      }
    );
  }
);

// Supprimer un utilisateur
app.delete(["/utilisateurs/:id", "/test/utilisateurs/:id"], (req, res) => {
  const { id } = req.params;
  const conn = getDB(req);
  conn.query(
    "DELETE FROM Utilisateurs WHERE idUtilisateur = ?",
    [id],
    (err, result) => {
      if (err) {
        console.error("Erreur lors de la suppression :", err);
        return res.status(500).json({ error: "Erreur serveur" });
      }
      if (result.affectedRows === 0) {
        return res.status(404).json({ error: "Utilisateur non trouvé" });
      }
      res.json({ message: "Utilisateur supprimé avec succès" });
    }
  );
});

// --- RESSOURCES MASQUÉES (ADMIN) ---
app.get(["/resources_admin", "/test/resources_admin"], (req, res) => {
  const conn = getDB(req);
  const sql = `
    SELECT r.idRessource, r.titreRessource AS title, r.messageRessource AS message,
           r.dateRessource AS date, r.statusRessource AS status, r.imageRessource AS image,
           c.nomCatégorie AS categorie
    FROM Ressources r
    JOIN Catégories c ON r.Catégories_idCatégorie = c.idCatégorie
    WHERE r.statusRessource = 'masque'
    ORDER BY r.dateRessource DESC
  `;
  conn.query(sql, (err, results) => {
    if (err) {
      console.error(
        "Erreur lors de la récupération des ressources masquées :",
        err
      );
      return res.status(500).json({ error: "Erreur serveur" });
    }
    const ressources = results.map((ressource) => ({
      ...ressource,
      image: ressource.image
        ? Buffer.from(ressource.image).toString("base64")
        : null,
    }));
    res.json(ressources);
  });
});

// Valider une ressource masquée
app.patch(
  ["/resources_admin/:id/valider", "/test/resources_admin/:id/valider"],
  (req, res) => {
    const conn = getDB(req);
    const { id } = req.params;
    // Si rien n'est envoyé, on force à 'affiche'
    const status = req.body.statusRessource || "affiche";
    conn.query(
      "UPDATE Ressources SET statusRessource = ? WHERE idRessource = ?",
      [status, id],
      (err, result) => {
        if (err) {
          console.error("Erreur lors de la validation de la ressource :", err);
          return res.status(500).json({ error: "Erreur serveur" });
        }
        res.json({ message: "Ressource validée" });
      }
    );
  }
);

// --- LANCEMENT DU SERVEUR ---
app.listen(3000, () => {
  console.log(`Backend (${environment}) listening on port 3000`);
});
