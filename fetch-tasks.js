const admin = require('firebase-admin');

// Initialize Firebase Admin SDK with your project
const serviceAccountPath = process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (!serviceAccountPath) {
  console.log('Using default credentials...');
}

admin.initializeApp({
  projectId: 'todolist-adr-2026'
});

const db = admin.firestore();

async function getAllTasksPerUser() {
  try {
    const todosRef = db.collection('todos');
    const snapshot = await todosRef.get();

    if (snapshot.empty) {
      console.log('No tasks found in Firestore.');
      return;
    }

    // Group tasks by userId
    const byUser = {};
    snapshot.forEach((doc) => {
      const task = doc.data();
      const uid = task.userId || '(no userId)';
      if (!byUser[uid]) byUser[uid] = [];
      byUser[uid].push({ docId: doc.id, ...task });
    });

    const totalDone    = snapshot.docs.filter(d => d.data().isCompleted).length;
    const totalPending = snapshot.size - totalDone;

    console.log('\n' + '═'.repeat(60));
    console.log('🔥 FIRESTORE — ALL TASKS PER USER');
    console.log('═'.repeat(60));
    console.log(`📊 Total tasks : ${snapshot.size}  ✅ ${totalDone} done  ⏳ ${totalPending} pending`);
    console.log(`👥 Unique users: ${Object.keys(byUser).length}`);
    console.log('═'.repeat(60));

    const fmtDate = (ts) => {
      if (!ts) return 'N/A';
      const d = ts.toDate ? ts.toDate() : new Date(ts.seconds * 1000);
      return d.toLocaleString('en-GB', { dateStyle: 'medium', timeStyle: 'short' });
    };

    Object.entries(byUser).forEach(([uid, tasks], i) => {
      const done    = tasks.filter(t => t.isCompleted).length;
      const pending = tasks.length - done;

      console.log(`\n👤 User ${i + 1}: ${uid}`);
      console.log(`   ${tasks.length} task(s) — ✅ ${done} done  ⏳ ${pending} pending`);
      console.log('─'.repeat(60));

      tasks.forEach((task, j) => {
        const status = task.isCompleted ? '✅' : '⏳';
        console.log(`\n  [${j + 1}] ${status} ${task.title}`);
        console.log(`       Note     : ${task.note || '(none)'}`);
        console.log(`       Due      : ${fmtDate(task.dueDate)}`);
        console.log(`       Created  : ${fmtDate(task.createdAt)}`);
        if (task.completedAt) {
          console.log(`       Done at  : ${fmtDate(task.completedAt)}`);
        }
        console.log(`       Doc ID   : ${task.docId}`);
      });
    });

    console.log('\n' + '═'.repeat(60));
    console.log('✅ Done.\n');

  } catch (error) {
    console.error('❌ Error fetching tasks:', error.message);
  } finally {
    process.exit(0);
  }
}

getAllTasksPerUser();
