const express = require('express')
const healthRoutes = require('./src/routes/healthRoutes')
const { sequelize } = require('./src/config/dbConfig')

const PORT = process.env.PORT || 8080;

const app = express();

(async () => {
  try {
    // Test the database connection
    await sequelize.authenticate();
    console.log('Connected to the database successfully.');

    const dbForceChanges = process.env.DB_FORCE_CHANGES?.toLowerCase() === 'true';

    console.log('DB_FORCE_CHANGES ' , dbForceChanges);
    await sequelize.sync({   
      alter: !dbForceChanges, 
      force: dbForceChanges 
    }); 
    console.log('Database bootstrapped and synchronized successfully.');

  } catch (error) {
    console.error('Failed to bootstrap the database:', error);
  }
})();

app.use('/healthz', healthRoutes);

app.all('*', (req, res) => {
  return res.status(404).set({
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    Pragma: 'no-cache',
    'X-Content-Type-Options': 'nosniff',
  }).end();
});


app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});

module.exports = app;