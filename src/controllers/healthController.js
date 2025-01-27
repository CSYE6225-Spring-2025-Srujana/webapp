const HealthCheck = require('../models/healthCheck')
const { sequelize } = require('../config/dbConfig')

const performHealthCheck = async (req, res) => {
  try {
    // Authenticate database connection
    await sequelize.authenticate();

    // Insert a record into the HealthCheck table
    await HealthCheck.create({ datetime: new Date().toISOString() });

    // Return 200 OK with required headers
    res
      .status(200)
      .set({
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        Pragma: 'no-cache',
        'X-Content-Type-Options': 'nosniff',
      })
      .end();
  } catch (error) {
    console.error('Health check failed:', error);

    // Return 503 Service Unavailable with required headers
    res
      .status(503)
      .set({
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        Pragma: 'no-cache',
        'X-Content-Type-Options': 'nosniff',
      })
      .end();
  }
};


module.exports = { performHealthCheck };
