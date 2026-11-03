const test = require('node:test');
const assert = require('node:assert');
const { createApp } = require('../src/app');

async function withServer(pool, fn) {
  const server = createApp(pool).listen(0);
  try {
    await fn(`http://127.0.0.1:${server.address().port}`);
  } finally {
    server.close();
  }
}

test('GET /health returns ok without touching the DB', async () => {
  const pool = { query: () => assert.fail('DB must not be queried') };
  await withServer(pool, async (base) => {
    const res = await fetch(`${base}/health`);
    assert.strictEqual(res.status, 200);
    assert.deepStrictEqual(await res.json(), { status: 'ok' });
  });
});

test('GET /api/status returns DB time on success', async () => {
  const pool = { query: async () => ({ rows: [{ time: '2026-01-01T00:00:00Z' }] }) };
  await withServer(pool, async (base) => {
    const res = await fetch(`${base}/api/status`);
    const body = await res.json();
    assert.strictEqual(res.status, 200);
    assert.strictEqual(body.databaseConnected, true);
    assert.strictEqual(body.serverTime, '2026-01-01T00:00:00Z');
  });
});

test('GET /api/status returns 503 and hides error details on DB failure', async () => {
  const pool = { query: async () => { throw new Error('connect ECONNREFUSED 10.0.1.5:5432'); } };
  const origError = console.error;
  console.error = () => {};
  try {
    await withServer(pool, async (base) => {
      const res = await fetch(`${base}/api/status`);
      const text = await res.text();
      assert.strictEqual(res.status, 503);
      assert.ok(!text.includes('10.0.1.5'));
    });
  } finally {
    console.error = origError;
  }
});
