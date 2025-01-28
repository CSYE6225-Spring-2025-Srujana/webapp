const HealthCheck = require('../models/healthCheck')
const { sequelize } = require('../config/dbConfig');

const performHealthCheck = async (req, res) => {
  try {
    if(req.method ==='HEAD'){
        return res.status(405).set({
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          Pragma: 'no-cache',
          'X-Content-Type-Options': 'nosniff',
      }).end();  
    }

    const contentLength = req.get('Content-Length');
    if (
        (contentLength && contentLength !== '0') ||
        Object.keys(req.body).length > 0 || 
        Object.keys(req.query).length > 0 ||
        Object.keys(req.params).length > 0
      ) {
      return res.status(400).set({
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        Pragma: 'no-cache',
        'X-Content-Type-Options': 'nosniff',
      }).end();
    }
    
    // Authenticate database connection
    await sequelize.authenticate();

    // Insert a record into the HealthCheck table
    await HealthCheck.create({ datetime: new Date().toISOString() });

    // Return 200 OK with required headers
    return res
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
    return res
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
