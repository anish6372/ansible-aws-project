const { Pool } = require('pg');
const { createApp } = require('./app');

const port = Number(process.env.PORT) || 3000;
const host = process.env.HOST || '127.0.0.1'; // loopback by default; nginx fronts it

const pool = new Pool({
  user: process.env.DB_USER || 'db_admin',
  host: process.env.DB_HOST || '127.0.0.1',
  database: process.env.DB_NAME || 'postgres',
  password: process.env.DB_PASSWORD,
  port: Number(process.env.DB_PORT) || 5432,
  ssl: process.env.DB_SSL === 'true' ? { rejectUnauthorized: true } : false,
  max: 5,
  connectionTimeoutMillis: 3000,
});

const server = createApp(pool).listen(port, host, () => {
  console.log(JSON.stringify({ level: 'info', msg: `listening on ${port}` }));
});

function shutdown(signal) {
  console.log(JSON.stringify({ level: 'info', msg: `${signal} received, shutting down` }));
  server.close(() => pool.end().finally(() => process.exit(0)));
  setTimeout(() => process.exit(1), 10000).unref();
}
process.on('SIGTERM', () => shutdown('SIGTERM'));
process.on('SIGINT', () => shutdown('SIGINT'));
