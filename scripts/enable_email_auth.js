/**
 * Enable Firebase Email/Password Authentication via Management API
 * Run: node scripts/enable_email_auth.js <ACCESS_TOKEN>
 *
 * Get access token by running: firebase login:print-token
 */

const https = require('https');

const PROJECT_ID = 'planning-with-ai-a4f22';

async function makeRequest(options, body) {
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

async function enableEmailAuth(accessToken) {
  // Use the Firebase Identity Toolkit Admin API to enable Email/Password sign-in
  const body = {
    signIn: {
      email: { enabled: true, passwordRequired: true }
    }
  };

  const options = {
    method: 'PATCH',
    hostname: 'identitytoolkit.googleapis.com',
    path: `/admin/v2/projects/${PROJECT_ID}/config?updateMask=signIn.email.enabled,signIn.email.passwordRequired`,
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${accessToken}`,
    },
  };

  const result = await makeRequest(options, body);
  return result;
}

async function main() {
  const accessToken = process.argv[2];

  if (!accessToken) {
    console.log('Usage: node scripts/enable_email_auth.js <ACCESS_TOKEN>');
    console.log('');
    console.log('To get your access token, run:');
    console.log('  firebase login:print-token');
    console.log('');
    console.log('Or you can enable Email/Password auth manually:');
    console.log(`  1. Go to: https://console.firebase.google.com/project/${PROJECT_ID}/authentication/providers`);
    console.log('  2. Click "Email/Password"');
    console.log('  3. Toggle "Enable" to ON');
    console.log('  4. Click "Save"');
    process.exit(1);
  }

  console.log('🔐 Enabling Firebase Email/Password Authentication...');
  const result = await enableEmailAuth(accessToken);

  if (result.status === 200) {
    console.log('✅ Email/Password authentication enabled successfully!');
    console.log('Now run: node scripts/setup_firebase.js');
  } else {
    console.log('❌ Failed to enable:', JSON.stringify(result.data, null, 2));
    console.log('');
    console.log('Please enable manually at:');
    console.log(`  https://console.firebase.google.com/project/${PROJECT_ID}/authentication/providers`);
  }
}

main().catch(console.error);
