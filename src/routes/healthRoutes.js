const express = require('express');
const { performHealthCheck, methodNotAllowed } = require('../controllers/healthController');
const { checkPayload } = require('../middleware/checkPayload')

const router = express.Router();

// Allowing only GET requests
router.get('/', checkPayload, performHealthCheck);


module.exports = router;