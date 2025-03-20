const { File } = require('../models/file'); 
const { v4: uuidv4 } = require('uuid');
const { S3Client, PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const multer = require('multer');
const { fromIni } = require('@aws-sdk/credential-provider-ini');

// Only for local
const s3 = new S3Client({
    region: process.env.AWS_REGION,
    credentials: fromIni({ profile: 'dev' })
});

// const s3 = new S3Client({
//     region: process.env.AWS_REGION
// });

const upload = multer({ storage: multer.memoryStorage() });

const uploadFile = async (req, res) => {
    try {
        if (!req.file) {
            console.log('Bad Request - File not found');
            return res.status(400).set({
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                Pragma: 'no-cache',
                'X-Content-Type-Options': 'nosniff',
            }).end();  
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
            url: `${process.env.S3_BUCKET_NAME}/${fileKey}`,
            upload_date: new Date()
        };

        // Save metadata in DB
        await File.create(fileMetadata);

        return res.status(201).json(fileMetadata);
    } catch (error) {
        console.error('File upload error:', error);
        return res.status(400).set({
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            Pragma: 'no-cache',
            'X-Content-Type-Options': 'nosniff',
        }).end();  
    }
};

const getFileMetadata = async (req, res) => {
    try {
        const file = await File.findByPk(req.params.id);

        if (!file) {
            console.log('File not found');
            return res.status(404).set({
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                Pragma: 'no-cache',
                'X-Content-Type-Options': 'nosniff',
            }).end();  
        }

        return res.status(200).json(file);
    } catch (error) {
        console.error('Error fetching file metadata:', error);
        return res.status(404).set({
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            Pragma: 'no-cache',
            'X-Content-Type-Options': 'nosniff',
        }).end();
    }
};

const deleteFile = async (req, res) => {
    try {
        const file = await File.findByPk(req.params.id);

        if (!file) {
            console.log('File not found');
            return res.status(404).set({
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                Pragma: 'no-cache',
                'X-Content-Type-Options': 'nosniff',
            }).end();  
        }

        const fileKey = file.url.split(`${process.env.S3_BUCKET_NAME}/`)[1];

        // Delete file from S3
        const deleteParams = {
            Bucket: process.env.S3_BUCKET_NAME,
            Key: fileKey
        };

        await s3.send(new DeleteObjectCommand(deleteParams));

        // Remove metadata from DB
        await file.destroy();

        return res.status(204).set({
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            Pragma: 'no-cache',
            'X-Content-Type-Options': 'nosniff',
        }).end();  
    } catch (error) {
        console.error('File delete error:', error);
        return res.status(400).set({
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            Pragma: 'no-cache',
            'X-Content-Type-Options': 'nosniff',
        }).end();  
    }
};

/**
 * Handles unsupported methods for /files routes
 */
const methodNotAllowed = (req, res) => {
    return res.status(405).set({
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        Pragma: 'no-cache',
        'X-Content-Type-Options': 'nosniff',
    }).end();
};

module.exports = { uploadFile, getFileMetadata, deleteFile, upload, methodNotAllowed };
