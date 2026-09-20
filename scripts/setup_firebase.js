/**
 * Firebase Setup Script for Smart Student Assessment Management System
 * 
 * This script creates:
 * 1. Admin user: admin@assessment.edu / Admin@123
 * 2. Faculty user: faculty@assessment.edu / Faculty@123
 * 3. Seeds their Firestore profiles
 *
 * Run: node scripts/setup_firebase.js
 */

const https = require('https');

const API_KEY = 'AIzaSyDWmD7dsKww98LheYajoA6PE3Ic4c3C6RY';
const PROJECT_ID = 'planning-with-ai-a4f22';

function makeRequest(options, body) {
  return new Promise((resolve, reject) => {
    const req = https.request(options, (res) => {
      let data = '';
      res.on('data', (chunk) => data += chunk);
      res.on('end', () => {
        try { resolve({ status: res.statusCode, data: JSON.parse(data) }); }
        catch { resolve({ status: res.statusCode, data }); }
      });
    });
    req.on('error', reject);
    if (body) req.write(JSON.stringify(body));
    req.end();
  });
}

async function createUser(email, password, displayName) {
  const options = {
    method: 'POST',
    hostname: 'identitytoolkit.googleapis.com',
    path: `/v1/accounts:signUp?key=${API_KEY}`,
    headers: { 'Content-Type': 'application/json' },
  };
  return makeRequest(options, { email, password, displayName, returnSecureToken: true });
}

async function signIn(email, password) {
  const options = {
    method: 'POST',
    hostname: 'identitytoolkit.googleapis.com',
    path: `/v1/accounts:signInWithPassword?key=${API_KEY}`,
    headers: { 'Content-Type': 'application/json' },
  };
  return makeRequest(options, { email, password, returnSecureToken: true });
}

function firestoreSet(collection, docId, data, token) {
  const fields = {};
  for (const [key, val] of Object.entries(data)) {
    if (typeof val === 'string') fields[key] = { stringValue: val };
    else if (typeof val === 'number') fields[key] = { integerValue: val.toString() };
    else if (typeof val === 'boolean') fields[key] = { booleanValue: val };
  }
  const options = {
    method: 'PATCH',
    hostname: 'firestore.googleapis.com',
    path: `/v1/projects/${PROJECT_ID}/databases/(default)/documents/${collection}/${docId}`,
    headers: { 'Content-Type': 'application/json', 'Authorization': `Bearer ${token}` },
  };
  return makeRequest(options, { fields });
}

async function getOrCreateUser(email, password, displayName) {
  const result = await createUser(email, password, displayName);
  if (result.status === 200) {
    console.log(`   Created: ${email} (UID: ${result.data.localId})`);
    return { uid: result.data.localId, token: result.data.idToken };
  }
  if (result.data?.error?.message === 'EMAIL_EXISTS') {
    console.log(`   Already exists: ${email} - signing in...`);
    const signInResult = await signIn(email, password);
    if (signInResult.status === 200) {
      return { uid: signInResult.data.localId, token: signInResult.data.idToken };
    }
    throw new Error(`Sign in failed: ${JSON.stringify(signInResult.data?.error)}`);
  }
  const errMsg = result.data?.error?.message || 'Unknown error';
  if (errMsg.includes('CONFIGURATION_NOT_FOUND') || errMsg.includes('TOO_MANY_ATTEMPTS') || errMsg.includes('operation-not-allowed')) {
    console.log('\n⚠️  Email/Password sign-in is NOT enabled in Firebase!');
    console.log('👉 Enable it here:');
    console.log(`   https://console.firebase.google.com/project/${PROJECT_ID}/authentication/providers`);
    console.log('   1. Click "Email/Password"');
    console.log('   2. Toggle "Enable" ON');
    console.log('   3. Save, then re-run this script.\n');
    process.exit(1);
  }
  throw new Error(`Create user failed: ${errMsg}`);
}

async function main() {
  console.log('🚀 Smart Student Assessment - Firebase Setup');
  console.log('='.repeat(50));
  console.log(`📦 Project: ${PROJECT_ID}\n`);

  console.log('👤 Setting up Admin user...');
  const admin = await getOrCreateUser('admin@assessment.edu', 'Admin@123', 'Admin User');
  console.log(`   ✅ Admin UID: ${admin.uid}`);

  console.log('\n👩‍🏫 Setting up Faculty user...');
  const faculty = await getOrCreateUser('faculty@assessment.edu', 'Faculty@123', 'Faculty Member');
  console.log(`   ✅ Faculty UID: ${faculty.uid}`);

  const now = new Date().toISOString();
  console.log('\n🗄️  Seeding Firestore profiles...');

  const adminProfile = await firestoreSet('users', admin.uid, {
    id: admin.uid, name: 'Admin User', email: 'admin@assessment.edu',
    role: 'Admin', phone: '9876543210', department: 'Administration', createdAt: now,
  }, admin.token);
  console.log(`   ✅ Admin profile: ${adminProfile.status === 200 ? 'OK' : 'Status ' + adminProfile.status}`);

  const facultyProfile = await firestoreSet('users', faculty.uid, {
    id: faculty.uid, name: 'Faculty Member', email: 'faculty@assessment.edu',
    role: 'Faculty', phone: '9876543211', department: 'Computer Science', createdAt: now,
  }, faculty.token);
  console.log(`   ✅ Faculty profile: ${facultyProfile.status === 200 ? 'OK' : 'Status ' + facultyProfile.status}`);

  console.log('\n' + '='.repeat(50));
  console.log('✅ Firebase Setup Complete!\n');
  console.log('📋 Login Credentials:');
  console.log('   Admin:   admin@assessment.edu   /  Admin@123');
  console.log('   Faculty: faculty@assessment.edu /  Faculty@123\n');
}

main().catch(err => {
  console.error('\n❌ Setup failed:', err.message);
  process.exit(1);
});
