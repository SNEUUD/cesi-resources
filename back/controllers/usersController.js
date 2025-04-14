const db = require("../db");

const getUsers = async (req, res) => {
  try {
    const conn = await db.getConnection();
    const rows = await conn.query("SELECT * FROM users"); // remplace par ta table
    conn.release();
    res.json(rows);
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: "Erreur serveur" });
  }
};

module.exports = { getUsers };