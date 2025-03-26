const HealthCheck = require('../models/healthCheck')
const { sequelize } = require('../config/dbConfig');
const { logger, logApiCall, logDbQuery } = require('../utils/logger');

const performHealthCheck = async (req, res) => {
  const startTime = Date.now();
  const apiName = req.originalUrl;
  try {
    if(req.method ==='HEAD'){
        logger.error('Health check failed: Does not support HEAD API call');
        logApiCall(apiName, Date.now() - startTime);
        return res.status(405).set({
          'Cache-Control': 'no-cache, no-store, must-revalidate',
          Pragma: 'no-cache',
          'X-Content-Type-Options': 'nosniff',
      }).end();  
    }

    const contentLength = parseInt(req.headers['content-length'] || '0');
    if (
        (contentLength && contentLength !== '0') ||
        Object.keys(req.body || {}).length > 0 || 
        Object.keys(req.query || {}).length > 0 ||
        Object.keys(req.params || {}).length > 0
      ) {
      logger.warn('Health check failed: Invalid request');
      logApiCall(apiName, Date.now() - startTime);
      return res.status(400).set({
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        Pragma: 'no-cache',
        'X-Content-Type-Options': 'nosniff',
      }).end();
    }
    
    // Authenticate database connection
    await sequelize.authenticate();

    // Insert a record into the HealthCheck table
    const dbStartTime = Date.now();
    await HealthCheck.create();
    logger.info("Created a record")
    logDbQuery(Date.now() - dbStartTime);

    logApiCall(apiName, Date.now() - startTime);
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
    logger.error('Health check failed:', error);
    logApiCall(apiName, Date.now() - startTime);
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
