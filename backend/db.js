// db.js
const mysql = require("mysql2");
require("dotenv").config();

const config = {
    host: process.env.DB_HOST,
    user: process.env.DB_USER,
    password: process.env.DB_PASSWORD,
};

const db = mysql.createConnection({
    ...config,
    database: process.env.DB_NAME,
});

const dbTest = mysql.createConnection({
    ...config,
    database: process.env.DB_NAME_TEST,
});

module.exports = { db, dbTest };
