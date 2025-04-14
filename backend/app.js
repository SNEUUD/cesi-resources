const express = require("express");
const mysql = require("mysql2");
const cors = require("cors");
require("dotenv").config();

const app = express();
app.use(cors());
app.use(express.json());

// Connexion à ta base MariaDB
const db = mysql.createConnection({
  host: process.env.DB_HOST,
  user: process.env.DB_USER,
  password: process.env.DB_PASSWORD,
  database: process.env.DB_NAME,
});

// Route simple pour tester
app.get("/users", (req, res) => {
  db.query("SELECT * FROM Utilisateurs", (err, results) => {
    if (err) {
      console.error("Erreur lors de la requête SQL :", err);
      return res.status(500).json(err);
    }
    console.log("Résultat de la requête :", results); // 👈 Log ici
    res.json(results);
  });
});


// Lancement du serveur
app.listen(3000, () => {
  console.log("Backend listening on port 3000");
});
