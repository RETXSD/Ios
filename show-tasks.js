#!/usr/bin/env node
// show-tasks.js — Show all Firebase Auth users + their Firestore tasks
// Usage: node show-tasks.js

const https  = require('https');
const fs     = require('fs');
const path   = require('path');
const { execSync } = require('child_process');

const PROJECT_ID = 'todolist-adr-2026';
const API_KEY    = 'AIzaSyDRLvJSlc6l_siq_xPcs6qiLHSDUqzDmFw';
const USERS_TMP  = '/tmp/firebase-users.json';

// ─── ANSI colours ────────────────────────────────────────────────────────────
const c = {
  reset:   '\x1b[0m',
  bold:    '\x1b[1m',
  dim:     '\x1b[2m',
  cyan:    '\x1b[36m',
  green:   '\x1b[32m',
  yellow:  '\x1b[33m',
  red:     '\x1b[31m',
  blue:    '\x1b[34m',
  magenta: '\x1b[35m',
  white:   '\x1b[97m',
  bgBlue:  '\x1b[44m',
};

const ln  = (ch = '─', n = 64) => ch.repeat(n);

// ─── helpers ─────────────────────────────────────────────────────────────────
function fetchUrl(url) {
  return new Promise((resolve, reject) => {
    https.get(url, res => {
      let raw = '';
      res.on('data', d => raw += d);
      res.on('end', () => resolve(JSON.parse(raw)));
    }).on('error', reject);
  });
}

function getVal(field) {
  if (!field) return null;
  if (field.stringValue   !== undefined) return field.stringValue;
  if (field.booleanValue  !== undefined) return field.booleanValue;
  if (field.timestampValue !== undefined) return field.timestampValue;
  if (field.nullValue     !== undefined) return null;
  return JSON.stringify(field);
}

function fmtDate(ts) {
  if (!ts) return `${c.dim}N/A${c.reset}`;
  return new Date(ts).toLocaleString('en-GB', { dateStyle: 'medium', timeStyle: 'short' });
}

function fmtEpoch(ms) {
  if (!ms) return `${c.dim}N/A${c.reset}`;
  return new Date(Number(ms)).toLocaleString('en-GB', { dateStyle: 'medium', timeStyle: 'short' });
}

function provider(u) {
  if (u.providerUserInfo && u.providerUserInfo.length > 0) {
    return u.providerUserInfo.map(p => p.providerId).join(', ');
  }
  return 'email/password';
}

// ─── Step 1: export Firebase Auth users ──────────────────────────────────────
function exportUsers() {
  process.stdout.write(`${c.cyan}⏳  Exporting Firebase Auth users…${c.reset}\n`);
  try {
    execSync(
      `firebase auth:export ${USERS_TMP} --format=json --project ${PROJECT_ID}`,
      { stdio: ['ignore', 'pipe', 'pipe'] }
    );
    const raw  = fs.readFileSync(USERS_TMP, 'utf8');
    const data = JSON.parse(raw);
    return data.users || [];
  } catch (e) {
    console.error(`${c.red}❌  Could not export users. Are you logged in to Firebase CLI?\n   Run: firebase login${c.reset}`);
    process.exit(1);
  }
}

// ─── Step 2: fetch Firestore todos ───────────────────────────────────────────
async function fetchTodos() {
  process.stdout.write(`${c.cyan}⏳  Fetching tasks from Firestore…${c.reset}\n`);
  let allDocs = [], pageToken = '';
  do {
    const url = `https://firestore.googleapis.com/v1/projects/${PROJECT_ID}/databases/(default)/documents/todos`
      + `?key=${API_KEY}&pageSize=300`
      + (pageToken ? `&pageToken=${encodeURIComponent(pageToken)}` : '');
    const data = await fetchUrl(url);
    if (data.error) {
      console.error(`${c.red}❌  Firestore: ${data.error.message}${c.reset}`);
      process.exit(1);
    }
    allDocs = allDocs.concat(data.documents || []);
    pageToken = data.nextPageToken || '';
  } while (pageToken);
  return allDocs;
}

// ─── main ─────────────────────────────────────────────────────────────────────
async function main() {
  const users   = exportUsers();
  const allDocs = await fetchTodos();

  // Index tasks by userId
  const byUser = {};
  for (const doc of allDocs) {
    const f = doc.fields || {};
    const task = {
      docId:       doc.name.split('/').pop(),
      title:       getVal(f.title)       || '(no title)',
      note:        getVal(f.note)        || '',
      isCompleted: getVal(f.isCompleted) || false,
      dueDate:     getVal(f.dueDate),
      createdAt:   getVal(f.createdAt),
      completedAt: getVal(f.completedAt),
      userId:      getVal(f.userId)      || '(no userId)',
    };
    if (!byUser[task.userId]) byUser[task.userId] = [];
    byUser[task.userId].push(task);
  }

  // Totals
  const totalTasks = allDocs.length;
  const totalDone  = allDocs.filter(d => getVal(d.fields?.isCompleted)).length;
  const now        = new Date();

  // ── Banner ──────────────────────────────────────────────────────────────
  console.log('\n' + c.cyan + c.bold + ln('═') + c.reset);
  console.log(c.bold + c.white + '  🔥  FIREBASE — ALL USERS & TASKS' + c.reset);
  console.log(c.cyan + ln('═') + c.reset);
  console.log(
    `  👥 Total users  : ${c.bold}${users.length}${c.reset}` +
    `   📦 Total tasks: ${c.bold}${totalTasks}${c.reset}` +
    `   ✅ ${c.green}${totalDone} done${c.reset}` +
    `   ⏳ ${c.yellow}${totalTasks - totalDone} pending${c.reset}`
  );
  console.log(c.cyan + ln('═') + c.reset);

  // ── Per-user ─────────────────────────────────────────────────────────────
  users.forEach((user, ui) => {
    const uid       = user.localId;
    const name      = user.displayName || `${c.dim}(no name)${c.reset}`;
    const email     = user.email       || `${c.dim}(no email)${c.reset}`;
    const verified  = user.emailVerified ? `${c.green}✔ verified${c.reset}` : `${c.yellow}✘ unverified${c.reset}`;
    const prov      = provider(user);
    const joined    = fmtEpoch(user.createdAt);
    const lastLogin = fmtEpoch(user.lastSignedInAt);

    const tasks   = byUser[uid] || [];
    const done    = tasks.filter(t => t.isCompleted).length;
    const pending = tasks.length - done;

    // User header
    console.log('');
    console.log(c.bold + c.bgBlue + c.white +
      `  👤  User ${ui + 1} / ${users.length}  ` + c.reset);
    console.log(`  ${c.bold}Name      :${c.reset}  ${c.white}${name}${c.reset}`);
    console.log(`  ${c.bold}Email     :${c.reset}  ${email}  ${verified}`);
    console.log(`  ${c.bold}Provider  :${c.reset}  ${prov}`);
    console.log(`  ${c.bold}UID       :${c.reset}  ${c.dim}${uid}${c.reset}`);
    console.log(`  ${c.bold}Joined    :${c.reset}  ${joined}`);
    console.log(`  ${c.bold}Last login:${c.reset}  ${lastLogin}`);
    console.log(
      `  ${c.bold}Tasks     :${c.reset}  ${c.bold}${tasks.length}${c.reset} total` +
      `  —  ✅ ${c.green}${done} done${c.reset}  ⏳ ${c.yellow}${pending} pending${c.reset}`
    );
    console.log('  ' + c.dim + ln('─', 62) + c.reset);

    if (tasks.length === 0) {
      console.log(`  ${c.dim}  (no tasks)${c.reset}`);
    } else {
      tasks.forEach((task, ti) => {
        const due     = task.dueDate ? new Date(task.dueDate) : null;
        const overdue = due && !task.isCompleted && due < now;
        const status  = task.isCompleted
          ? `${c.green}✅ DONE   ${c.reset}`
          : `${c.yellow}⏳ PENDING${c.reset}`;

        console.log('');
        console.log(
          `  ${c.bold}  [${ti + 1}]${c.reset}  ${status}  ` +
          c.bold + c.white + task.title + c.reset +
          (overdue ? `  ${c.red}🔴 OVERDUE${c.reset}` : '')
        );
        console.log(
          `         ${c.dim}Note     :${c.reset} ` +
          (task.note ? task.note : `${c.dim}(none)${c.reset}`)
        );
        console.log(
          `         ${c.dim}Due      :${c.reset} ` +
          (overdue ? c.red : '') + fmtDate(task.dueDate) + c.reset
        );
        console.log(`         ${c.dim}Created  :${c.reset} ${fmtDate(task.createdAt)}`);
        if (task.completedAt) {
          console.log(`         ${c.dim}Done at  :${c.reset} ${c.green}${fmtDate(task.completedAt)}${c.reset}`);
        }
        console.log(`         ${c.dim}Doc ID   :${c.reset} ${c.dim}${task.docId}${c.reset}`);
      });
    }

    if (ui < users.length - 1) {
      console.log('\n' + c.dim + ln('═', 64) + c.reset);
    }
  });

  console.log('\n' + c.cyan + ln('═') + c.reset);
  console.log(c.green + c.bold + '  ✅  Done.\n' + c.reset);
}

main().catch(err => {
  console.error(`${c.red}❌  ${err.message}${c.reset}`);
  process.exit(1);
});
