const cors = require('cors');
const express = require('express');
const Database = require('better-sqlite3');
const fs = require('fs');
const path = require('path');

const app = express();
const port = process.env.PORT || 3000;
const dbDir = path.join(__dirname, '..', 'database');
const dbPath = path.join(dbDir, 'bmi_calculator.db');

fs.mkdirSync(dbDir, { recursive: true });

const db = new Database(dbPath);

db.exec(`
  CREATE TABLE IF NOT EXISTS bmi_results (
    id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    age TEXT NOT NULL,
    bmi TEXT NOT NULL,
    status TEXT NOT NULL,
    normal_weight_range TEXT NOT NULL,
    saved_date TEXT NOT NULL,
    height INTEGER NOT NULL,
    weight INTEGER NOT NULL,
    advice TEXT NOT NULL,
    bmi_value REAL NOT NULL,
    profile_image_path TEXT NOT NULL,
    synced INTEGER NOT NULL DEFAULT 0
  )
`);

const toApiRow = (row) => ({
  id: row.id,
  name: row.name,
  age: row.age,
  bmi: row.bmi,
  status: row.status,
  normalWeightRange: row.normal_weight_range,
  savedDate: row.saved_date,
  height: row.height,
  weight: row.weight,
  advice: row.advice,
  bmiBmi: row.bmi_value,
  profileImagePath: row.profile_image_path,
  synced: row.synced === 1,
});

app.use(cors());
app.use(express.json());

app.get('/api/results', (_req, res) => {
  const rows = db
    .prepare('SELECT * FROM bmi_results ORDER BY saved_date ASC')
    .all();
  res.json(rows.map(toApiRow));
});

app.post('/api/results', (req, res) => {
  const result = req.body;
  if (!result?.id) {
    return res.status(400).json({ error: 'Missing result id' });
  }

  db.prepare(`
    INSERT OR REPLACE INTO bmi_results (
      id, name, age, bmi, status, normal_weight_range, saved_date,
      height, weight, advice, bmi_value, profile_image_path, synced
    ) VALUES (
      @id, @name, @age, @bmi, @status, @normal_weight_range, @saved_date,
      @height, @weight, @advice, @bmi_value, @profile_image_path, @synced
    )
  `).run({
    id: String(result.id),
    name: result.name ?? '',
    age: result.age ?? '',
    bmi: result.bmi ?? '',
    status: result.status ?? '',
    normal_weight_range: result.normalWeightRange ?? '',
    saved_date: result.savedDate ?? new Date().toISOString(),
    height: Number(result.height ?? 0),
    weight: Number(result.weight ?? 0),
    advice: result.advice ?? '',
    bmi_value: Number(result.bmiBmi ?? 0),
    profile_image_path: result.profileImagePath ?? '',
    synced: result.synced ? 1 : 1,
  });

  res.status(201).json({ ok: true });
});

app.delete('/api/results/:id', (req, res) => {
  db.prepare('DELETE FROM bmi_results WHERE id = ?').run(req.params.id);
  res.status(204).send();
});

app.delete('/api/results', (_req, res) => {
  db.prepare('DELETE FROM bmi_results').run();
  res.status(204).send();
});

app.listen(port, '0.0.0.0', () => {
  console.log(`BMI API listening on http://0.0.0.0:${port}`);
  console.log(`Database file: ${dbPath}`);
});
