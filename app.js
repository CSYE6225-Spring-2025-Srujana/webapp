const express = require('express')
const healthRoutes = require('./src/routes/healthRoutes')
const { sequelize } = require('./src/config/dbConfig')

const PORT = process.env.PORT || 8080;

const app = express();

(async () => {
  try {
    // Test the database connection
    await sequelize.authenticate();
    console.log('Connected to the database successfully.');

    await sequelize.sync({ alter: true }); 
    console.log('Database bootstrapped and synchronized successfully.');

  } catch (error) {
    console.error('Failed to bootstrap the database:', error);
  }
})();

app.use(express.json());


//check for method
app.use((req, res, next) => {
  if (req.path === '/healthz' && req.method !== 'GET') {
    return res.status(405).set({
      'Cache-Control': 'no-cache, no-store, must-revalidate',
      Pragma: 'no-cache',
      'X-Content-Type-Options': 'nosniff',
    }).end();
  }
  next();
});

app.use('/healthz', healthRoutes);

app.all('*', (req, res) => {
  res.status(404).set({
    'Cache-Control': 'no-cache, no-store, must-revalidate',
    Pragma: 'no-cache',
    'X-Content-Type-Options': 'nosniff',
  }).end();
});


app.listen(PORT, () => {
  console.log(`Server running at http://localhost:${PORT}`);
});

