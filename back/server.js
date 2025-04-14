const express = require("express");
const cors = require("cors");
require("dotenv").config();

const usersRoutes = require("./routes/users");

const app = express();
app.use(cors());
app.use(express.json());

app.use("/users", usersRoutes);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`🚀 Serveur lancé sur http://localhost:${PORT}`);
});
