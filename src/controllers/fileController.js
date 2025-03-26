const { File } = require('../models/file'); 
const { v4: uuidv4 } = require('uuid');
const { S3Client, PutObjectCommand, DeleteObjectCommand } = require('@aws-sdk/client-s3');
const multer = require('multer');
const { logger, logApiCall, logDbQuery, logS3Call } = require('../utils/logger');

const s3 = new S3Client({
    region: process.env.AWS_REGION
});

const upload = multer({ storage: multer.memoryStorage() });

const uploadFile = async (req, res) => {
    const apiStartTime = Date.now();
    const apiName = req.originalUrl;

    try {
        if (!req.file) {
            logger.error('Bad Request - File not found');
            logApiCall(apiName , Date.now() - apiStartTime);

            return res.status(400).set({
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                Pragma: 'no-cache',
                'X-Content-Type-Options': 'nosniff',
            }).end();  
        }

        const fileId = uuidv4();
        const fileKey = `${fileId}/${req.file.originalname}`;

        // Upload file to S3
        const uploadParams = {
            Bucket: process.env.S3_BUCKET_NAME,
            Key: fileKey,
            Body: req.file.buffer,
            ContentType: req.file.mimetype
        };

        // Construct metadata
        const fileMetadata = {
            id: fileId,
            file_name: req.file.originalname,
            url: `${process.env.S3_BUCKET_NAME}/${fileKey}`
        };

        // Save metadata in DB and measure db call
        const dbStartTime = Date.now();
        const result = await File.create(fileMetadata);
        const dbDuration = Date.now() - dbStartTime;
        logDbQuery(dbDuration);

        //Save file to s3 and measure time taken
        const s3StartTime = Date.now();
        await s3.send(new PutObjectCommand(uploadParams));
        const s3Duration = Date.now() - s3StartTime;
        logS3Call(s3Duration);

        logger.info(`File uploaded successfully: ${fileMetadata.file_name}`);

        logApiCall(apiName , Date.now() - apiStartTime);

        return res.status(201).json(result);
    } catch (error) {
        logger.error('File upload error:', error);
        return res.status(503).set({ 
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
            logger.error('File not found');
            return res.status(404).set({
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                Pragma: 'no-cache',
                'X-Content-Type-Options': 'nosniff',
            }).end();  
        }

        return res.status(200).json(file);
    } catch (error) {
        logger.error('Error fetching file metadata:', error);
        return res.status(503).set({
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
            logger.error('File not found');
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

        logger.info(`File deleted successfully: ${fileKey}`);

        return res.status(204).set({
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            Pragma: 'no-cache',
            'X-Content-Type-Options': 'nosniff',
        }).end();  
    } catch (error) {
        logger.error('File delete error:', error);
        return res.status(503).set({
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            Pragma: 'no-cache',
            'X-Content-Type-Options': 'nosniff',
        }).end();  
    }
};

/**
 * Handles unsupported methods for /file routes
 */
const methodNotAllowed = (req, res) => {
    return res.status(405).set({
        'Cache-Control': 'no-cache, no-store, must-revalidate',
        Pragma: 'no-cache',
        'X-Content-Type-Options': 'nosniff',
    }).end();
};

module.exports = { uploadFile, getFileMetadata, deleteFile, upload, methodNotAllowed };
