const express = require('express')
const { sequelize } = require('./src/config/dbConfig');
const healthRoutes = require('./src/routes/healthRoutes');


const PORT = process.env.PORT || 8080;

const app = express();

// Bootstraps database
(async () => {
  try {
    await sequelize.authenticate();
    console.log('Connected to the database successfully.');
    await sequelize.sync({ alter: true }); 
    console.log('Database synchronized.');
  } catch (error) {
    console.error('Failed to connect to the database:', error);
    process.exit(1); 
  }
})();

app.use(express.json());

app.use('/healthz', healthRoutes);

app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});