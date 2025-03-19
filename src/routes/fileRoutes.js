const express = require('express');
const multer = require('multer');
// const multerS3 = require('multer-s3');
// const { fromIni } = require('@aws-sdk/credential-provider-ini');
const { File } = require('../models/file'); 
const { v4: uuidv4 } = require('uuid');
const { S3Client, PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');

const router = express.Router();

// Only for local
// const s3 = new S3Client({
//     region: process.env.AWS_REGION,
//     credentials: fromIni({ profile: 'dev' })
// });

const s3 = new S3Client({
    region: process.env.AWS_REGION
});


const upload = multer({ storage: multer.memoryStorage() });

/**
 * @route POST /files
 * @desc Uploads a file to S3 & stores metadata in DB
 */
router.post('/', upload.single('webapp-file'), async (req, res) => {
    try {
        if (!req.file) {
            console.log('No file uploaded');
            return res.status(400).json({ error: 'No file uploaded' });
        }

        const fileId = uuidv4();
        const fileExt = req.file.originalname;
        const fileKey = `uploads/${fileId}${fileExt}`;

        // Upload file to S3
        const uploadParams = {
            Bucket: process.env.S3_BUCKET_NAME,
            Key: fileKey,
            Body: req.file.buffer,
            ContentType: req.file.mimetype
        };

        await s3.send(new PutObjectCommand(uploadParams));

        // Construct metadata
        const fileMetadata = {
            id: fileId,
            file_name: req.file.originalname,
            url: `${process.env.S3_BUCKET_NAME}/${fileKey}`, // S3 path
            upload_date: new Date()
        };

        // Save metadata in DB
        await File.create(fileMetadata);

        console.log('File uploaded successfully:', fileMetadata);
        return res.status(201).json(fileMetadata);
        
    } catch (error) {
        console.error('File upload error:', error);
        return res.status(500).json({ error: 'File upload failed' });
    }
});


/**
 * @route GET /files/:id
 * @desc Retrieves file metadata from DB
 */
router.get('/:id', async (req, res) => {
    try {
        const file = await File.findByPk(req.params.id);

        if (!file) {
            return res.status(404).json({ error: 'File not found' });
        }

        return res.status(200).json(file);
    } catch (error) {
        console.error('Error fetching file metadata:', error);
        return res.status(500).json({ error: 'Failed to fetch file metadata' });
    }
});

/**
 * @route DELETE /files/:id
 * @desc Deletes a file from S3 & removes metadata from DB
 */
router.delete('/:id', async (req, res) => {
    try {
        const file = await File.findByPk(req.params.id);

        if (!file) {
            return res.status(404).json({ error: 'File not found' });
        }

        // Extract S3 file key from the stored URL
        const fileKey = file.url.split(`${process.env.S3_BUCKET_NAME}/`)[1];

        // Delete file from S3
        const deleteParams = {
            Bucket: process.env.S3_BUCKET_NAME,
            Key: fileKey
        };

        await s3.send(new DeleteObjectCommand(deleteParams));

        // Remove metadata from DB
        await file.destroy();

        console.log(`File ${fileKey} deleted successfully`);
        return res.status(200).json({ message: 'File deleted successfully' });

    } catch (error) {
        console.error('File delete error:', error);
        return res.status(500).json({ error: 'File deletion failed' });
    }
});


router.route('/')
        .all((req, res)=>
            {
            return res.status(405).set({
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            Pragma: 'no-cache',
            'X-Content-Type-Options': 'nosniff',
        }).end();
        })
module.exports = router;
