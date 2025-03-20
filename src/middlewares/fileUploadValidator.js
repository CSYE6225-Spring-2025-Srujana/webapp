const multer = require('multer');

// Configure Multer storage (if not already configured elsewhere)
const upload = multer({ storage: multer.memoryStorage() }); // Store in memory

const fileUploadValidator = (req, res, next) => {
    upload.single('webapp-file')(req, res, (err) => {
        if (err) {
            return res.status(400).set({
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                Pragma: 'no-cache',
                'X-Content-Type-Options': 'nosniff',
            }).send();
        }

        // If no file was uploaded, return 400
        if (!req.file) {
            return res.status(400).set({
                'Cache-Control': 'no-cache, no-store, must-revalidate',
                Pragma: 'no-cache',
                'X-Content-Type-Options': 'nosniff',
            }).send();
        }

        // If everything is fine, proceed to the next middleware/controller
        next();
    });
};

module.exports = fileUploadValidator;
