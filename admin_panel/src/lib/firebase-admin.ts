import * as admin from 'firebase-admin';
import path from 'path';
import fs from 'fs';

const initializeAdmin = () => {
  if (admin.apps.length > 0) {
    return admin;
  }

  try {
    const fileName = 'service-account.json';
    // Try multiple possible locations for the service account
    const pathsToTry = [
      path.join(process.cwd(), fileName),
      path.join(process.cwd(), 'admin_panel', fileName),
      path.join(process.cwd(), '..', fileName),
      path.join(process.cwd(), '..', 'admin_panel', fileName),
    ];

    let serviceAccount;
    let foundPath = '';

    for (const p of pathsToTry) {
      console.log(`🔍 [Admin Init] Checking: ${p}`);
      if (fs.existsSync(p)) {
        foundPath = p;
        break;
      }
    }

    if (foundPath) {
      console.log(`✅ [Admin Init] Found service account at: ${foundPath}`);
      serviceAccount = JSON.parse(fs.readFileSync(foundPath, 'utf-8'));
      
      admin.initializeApp({
        credential: admin.credential.cert(serviceAccount)
      });
      console.log('🚀 [Admin Init] Firebase Admin initialized successfully!');
    } else {
      console.error('❌ [Admin Init] Error: service-account.json not found in any of the expected locations!');
    }
  } catch (error) {
    console.error('❌ [Admin Init] Initialization Error:', error);
  }

  return admin;
};

const adminAuth = initializeAdmin().auth();
const adminDb = initializeAdmin().firestore();
const adminMessaging = initializeAdmin().messaging();

export { admin, adminAuth, adminDb, adminMessaging };
