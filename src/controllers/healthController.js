const HealthCheck = require('../models/healthCheck')

// Health Check Handler
const performHealthCheck = async (req, res) => {
  try {
    // Insert a record into the HealthCheck table
    await HealthCheck.create({});
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

// Method Not Allowed Handler
const methodNotAllowed = (req, res) => {
  res
    .status(405)
    .set({
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      Pragma: 'no-cache',
      'X-Content-Type-Options': 'nosniff',
    })
    .end();
};

module.exports = { performHealthCheck, methodNotAllowed };
