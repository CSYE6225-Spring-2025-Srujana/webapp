const express = require('express');
const { uploadFile, getFileMetadata, deleteFile, upload, methodNotAllowed } = require('../controllers/fileController');

const router = express.Router();

router.route('/')
    .head(methodNotAllowed)
    .post(upload.single('webapp-file'), uploadFile)
    .get((req, res)=>
        {
        return res.status(400).set({
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        Pragma: 'no-cache',
        'X-Content-Type-Options': 'nosniff',
    }).end();
    })  
    .delete((req, res)=>
        {
        return res.status(400).set({
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        Pragma: 'no-cache',
        'X-Content-Type-Options': 'nosniff',
    }).end();
    }) 
    .all(methodNotAllowed);

router.route('/:id')
    .head(methodNotAllowed)
    .get(getFileMetadata)
    .delete(deleteFile)
    .all(methodNotAllowed);

module.exports = router;
