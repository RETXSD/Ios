const admin = require('firebase-admin');

admin.initializeApp({
  projectId: 'todolist-adr-2026'
});

const db = admin.firestore();

function formatDate(value) {
  if (!value) return 'No due date';
  if (typeof value.toDate === 'function') {
    return value.toDate().toLocaleDateString();
  }
  if (value.seconds) {
    return new Date(value.seconds * 1000).toLocaleDateString();
  }
  return new Date(value).toLocaleDateString();
}

async function getActiveTasks() {
  try {
    const usersSnapshot = await db.collection('users').get();

    if (usersSnapshot.empty) {
      console.log('No users found.');
      return;
    }

    let foundAny = false;

    for (const userDoc of usersSnapshot.docs) {
      const todosSnapshot = await userDoc.ref
        .collection('todos')
        .where('isCompleted', '==', false)
        .get();

      if (todosSnapshot.empty) {
        continue;
      }

      if (!foundAny) {
        console.log('\n✅ ACTIVE TASKS:\n');
        foundAny = true;
      }

      console.log(`👤 User: ${userDoc.id}`);
      todosSnapshot.forEach((doc) => {
        const task = doc.data();
        console.log(`📋 ${task.title || '(untitled task)'}`);
        console.log(`   ID: ${task.id || doc.id}`);
        console.log(`   Note: ${task.note || 'No notes'}`);
        console.log(`   Due Date: ${formatDate(task.dueDate)}`);
        console.log(`   Created: ${formatDate(task.createdAt)}`);
        console.log('');
      });
    }

    if (!foundAny) {
      console.log('No active tasks found.');
    }
  } catch (error) {
    console.error('❌ Error fetching tasks:', error);
  } finally {
    process.exit(0);
  }
}

getActiveTasks();
