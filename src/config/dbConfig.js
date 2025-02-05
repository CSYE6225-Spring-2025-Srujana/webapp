const { Sequelize } = require('sequelize');
const dotenv = require('dotenv');

// const envFile = process.env.NODE_ENV === 'test' ? '.env.test' : '.env';
const envFile = '.env';
console.log(`Loading environment variables from ${envFile}`);
dotenv.config({ path: envFile });


// Initialize Sequelize
const sequelize = new Sequelize(process.env.DB_NAME, process.env.DB_USER, process.env.DB_PASSWORD, {
  host: process.env.DB_HOST,
  port: process.env.DB_PORT || 3306,
  dialect: process.env.DB_DIALECT,
  logging: false,
});

module.exports = { sequelize };