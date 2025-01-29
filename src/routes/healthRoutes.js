const express = require('express');
const { performHealthCheck, methodNotAllowed } = require('../controllers/healthController');

const router = express.Router();

// Allowing only GET requests
router.route('/').get(performHealthCheck)
        .all((req, res)=>
            {
            return res.status(405).set({
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            Pragma: 'no-cache',
            'X-Content-Type-Options': 'nosniff',
        }).end();
        })


module.exports = router;