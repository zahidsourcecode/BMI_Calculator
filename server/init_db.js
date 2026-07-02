const fs = require('fs');
const path = require('path');
const Database = require('better-sqlite3');

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
db.close();

console.log(`Created: ${dbPath}`);
