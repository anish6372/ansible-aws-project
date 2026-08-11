const express = require('express');
const { Pool } = require('pg');

const app = express();
const port = 3000;

// Use environment variables or default to standard DB credentials
const pool = new Pool({
  user: process.env.DB_USER || 'db_admin',
  host: process.env.DB_HOST, // This will be passed by Ansible
  database: 'postgres', // default db
  password: process.env.DB_PASSWORD,
  port: 5432,
});

app.get('/api/status', async (req, res) => {
  try {
    const client = await pool.connect();
    const result = await client.query('SELECT NOW() as time');
    client.release();
    res.json({
      status: 'success',
      databaseConnected: true,
      serverTime: result.rows[0].time
    });
  } catch (err) {
    console.error(err);
    res.status(500).json({
      status: 'error',
      databaseConnected: false,
      error: err.message
    });
  }
});

app.listen(port, () => {
  console.log(`Backend API listening on port ${port}`);
});
