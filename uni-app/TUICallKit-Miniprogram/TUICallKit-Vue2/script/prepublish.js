#!/usr/bin/env node
// Pre-publish script for the demo project.
// Replaces sensitive credentials and workspace protocols before publishing,
// and restores them from backup after publish.
//
// Usage:
//   node ./script/prepublish.js
//   node ./script/prepublish.js --restore
'use strict';

const fs = require('fs');
const path = require('path');

const root = path.resolve(__dirname, '..');
const backupDir = path.resolve(root, '.prepublish-backup');
const files = [
  'debug/GenerateTestUserSig-es.js',
  'package.json',
];

const action = process.argv[2];

// ── Restore ────────────────────────────────────────────────────────
if (action === '--restore') {
  let restored = 0;
  for (const file of files) {
    const backupPath = path.join(backupDir, path.basename(file));
    const targetPath = path.join(root, file);
    if (fs.existsSync(backupPath)) {
      fs.copyFileSync(backupPath, targetPath);
      fs.unlinkSync(backupPath);
      restored++;
    }
  }
  if (restored > 0) {
    console.log('[prepublish] restored %d file(s) from backup', restored);
  } else {
    console.log('[prepublish] no backup found — already restored');
  }
  // Clean up backup dir if empty
  if (fs.existsSync(backupDir)) {
    try { fs.rmdirSync(backupDir); } catch (_) { /* not empty, ignore */ }
  }
  process.exit(0);
}

// ── Replace ────────────────────────────────────────────────────────
if (fs.existsSync(backupDir)) {
  console.log('[prepublish] backup already exists, skipping');
  process.exit(0);
}

fs.mkdirSync(backupDir, { recursive: true });

// 1) GenerateTestUserSig-es.js — scrub credentials
{
  const file = files[0];
  const targetPath = path.join(root, file);
  const backupPath = path.join(backupDir, path.basename(file));
  fs.copyFileSync(targetPath, backupPath);

  let content = fs.readFileSync(targetPath, 'utf-8');
  content = content.replace(/let SDKAPPID = \d+;/, 'let SDKAPPID = 0;');
  content = content.replace(/let SECRETKEY = '[^']*';/, "let SECRETKEY = '';");
  fs.writeFileSync(targetPath, content);
  console.log('[prepublish] scrubbed credentials in %s', file);
}

// 2) package.json — replace workspace:* → latest
{
  const file = files[1];
  const targetPath = path.join(root, file);
  const backupPath = path.join(backupDir, path.basename(file));
  fs.copyFileSync(targetPath, backupPath);

  let content = fs.readFileSync(targetPath, 'utf-8');
  content = content.replace(/"workspace:\*"/g, '"latest"');
  fs.writeFileSync(targetPath, content);
  console.log('[prepublish] replaced workspace:* → latest in %s', file);
}

console.log('[prepublish] done.');
