const express = require('express');
const { performHealthCheck, methodNotAllowed } = require('../controllers/healthController');

const router = express.Router();

// Allowing only GET requests
router.get('/healthz', performHealthCheck);
router.all('/', methodNotAllowed);

module.exports = router;