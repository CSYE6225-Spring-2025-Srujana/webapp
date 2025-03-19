const { S3Client } = require('@aws-sdk/client-s3');
const { fromIni } = require('@aws-sdk/credential-provider-ini');

// Load AWS credentials from IAM role
const s3 = new S3Client({
    region: process.env.AWS_REGION, // Make sure your region is set
    // credentials: {
    //   accessKeyId: process.env.AWS_ACCESS_KEY_ID,
    //   secretAccessKey: process.env.AWS_SECRET_ACCESS_KEY
    // }
    credentials: fromIni({ profile: 'dev' })
  });

module.exports = s3;