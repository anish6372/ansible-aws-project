const express = require('express');

function createApp(pool) {
  const app = express();
  app.disable('x-powered-by');

  // Liveness: process is up. No dependencies, so the LB never kills a healthy app over a DB blip.
  app.get('/health', (req, res) => res.json({ status: 'ok' }));

  // Readiness / status: verifies the DB round trip.
  app.get('/api/status', async (req, res) => {
    try {
      const result = await pool.query('SELECT NOW() AS time');
      res.json({
        status: 'success',
        databaseConnected: true,
        serverTime: result.rows[0].time,
      });
    } catch (err) {
      console.error(JSON.stringify({ level: 'error', msg: 'db check failed', err: err.message }));
      // Do not leak driver/host details to clients.
      res.status(503).json({ status: 'error', databaseConnected: false });
    }
  });

  return app;
}

module.exports = { createApp };
