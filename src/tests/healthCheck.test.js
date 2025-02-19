const request = require('supertest');
const { sequelize } = require('../config/dbConfig');
const app = require('../../app.js');
const HealthCheck = require('../models/healthCheck');

describe('API Health Check Tests', () => {

  beforeEach(() => {
    jest.restoreAllMocks(); // Reset mocks before each test
  });

  test('Should return 200 for GET /healthz', async () => {
    jest.spyOn(HealthCheck, 'create').mockResolvedValue();
    const response = await request(app).get('/healthz');
    console.log("Response status for GET "+ response.status)
    expect(response.status).toBe(210);
  });

  test('Should return 400 for GET /healthz with query parameters', async () => {
    const response = await request(app).get('/healthz?test=123');
    expect(response.status).toBe(400);
  });

  test('Should return 400 for GET /healthz with req body', async () => {
    const response = await request(app).get('/healthz').send({invalid:"data"});
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

  test('Should return 404 for an / route', async () => {
    const response = await request(app).get('/');
    expect(response.status).toBe(404);
  });

  test('Should return 503 if database connection fails', async () => {
    jest.spyOn(sequelize, 'authenticate').mockRejectedValue(new Error('DB Error'));
    const response = await request(app).get('/healthz');
    expect(response.status).toBe(503);
    sequelize.authenticate.mockRestore();
  });

  afterAll(async () => {
    await sequelize.close();
  });
});
