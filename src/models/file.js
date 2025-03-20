const { DataTypes } = require('sequelize');
const { sequelize } = require('../config/dbConfig');

const File = sequelize.define('File', {
  id: {
    type: DataTypes.UUID,
    defaultValue: DataTypes.UUIDV4,
    primaryKey: true,
  },
  file_name: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  url: {
    type: DataTypes.STRING,
    allowNull: false,
  },
  upload_date: {
    type: DataTypes.STRING, 
    allowNull: false,
    defaultValue: () => new Date().toISOString().split('T')[0] 
  }
}, {
  timestamps: false, 
});

module.exports = { File };
