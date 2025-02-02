const request = require('supertest');
const express = require('express');
const healthRoutes = require('../routes/healthRoutes');
const { sequelize } = require('../config/dbConfig');

const app = express();
app.use(express.json());
app.use('/healthz', healthRoutes);

describe('API Health Check Tests', () => {
  beforeAll(async () => {
    await sequelize.authenticate();
    await sequelize.sync({ alter: true });
  });

  afterAll(async () => {
    await sequelize.close();
  });

  beforeEach(() => {
    jest.restoreAllMocks(); // Reset mocks before each test
  });

  test('Should return 200 for GET /healthz', async () => {
    const response = await request(app).get('/healthz');
    expect(response.status).toBe(200);
  });

  test('Should return 400 for GET /healthz with query parameters', async () => {
    const response = await request(app).get('/healthz?test=123');
    expect(response.status).toBe(400);
  });

  test('Should return 405 for POST /healthz', async () => {
    const response = await request(app).post('/healthz');
    expect(response.status).toBe(405);
  });

  test('Should return 405 for HEAD /healthz', async () => {
    const response = await request(app).head('/healthz');
    expect(response.status).toBe(405);
  });

  test('Should return 404 for an unknown route', async () => {
    const response = await request(app).get('/unknown');
    expect(response.status).toBe(404);
  });

  test('Should return 503 if database connection fails', async () => {
    jest.spyOn(sequelize, 'authenticate').mockRejectedValue(new Error('DB Error'));
    const response = await request(app).get('/healthz');
    expect(response.status).toBe(503);
    sequelize.authenticate.mockRestore();
  });
});
