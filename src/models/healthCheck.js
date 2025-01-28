const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/dbConfig');
const { without } = require('lodash');

const HealthCheck = sequelize.define('healthCheck', {
  checkId: {
    type: DataTypes.INTEGER,
    autoIncrement: true,
    primaryKey: true,
  },
  dateTime: {
    type: DataTypes.DATE ,
    allowNull: false,
    defaultValue: sequelize.literal("timezone('UTC', now())"),
  }
},
{
  timestamps: false, // Disable createdAt and updatedAt fields
});

module.exports = HealthCheck;