const express = require('express')
const healthRoutes = require('./src/routes/healthRoutes')
const fileRoutes = require('./src/routes/fileRoutes.js')
const { sequelize } = require('./src/config/dbConfig')
const {logger} = require('./src/utils/logger');

const PORT = process.env.PORT || 8080;

const app = express();


(async () => {
  try {
    // Test the database connection
    await sequelize.authenticate();
    logger.info('Connected to the database successfully.');

    const dbForceChanges = process.env.DB_FORCE_CHANGES?.toLowerCase() === 'true';

    logger.info('DB_FORCE_CHANGES ' , dbForceChanges);
    await sequelize.sync({   
      alter: !dbForceChanges, 
      force: dbForceChanges 
    }); 
    logger.info('Database bootstrapped and synchronized successfully.');

  } catch (error) {
    logger.error('Failed to bootstrap the database:', error);
  }
})();

app.use('/healthz', healthRoutes);
app.use('/v1/file', fileRoutes);

app.all('*', (req, res) => {
  return res.status(404).set({
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    Pragma: 'no-cache',
    'X-Content-Type-Options': 'nosniff',
  }).end();
});


app.listen(PORT, () => {
  logger.info(`Server running at http://localhost:${PORT}`);
});

module.exports = app;