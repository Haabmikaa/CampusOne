import { NextResponse } from 'next/server';
import { admin, adminAuth, adminDb } from '@/lib/firebase-admin';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { name, email, password, department, role, lecturerCategory, staffCatalog } = body;

    if (admin.apps.length === 0) {
      return NextResponse.json(
        { error: 'Firebase Admin SDK is not initialized. Please configure service-account.json.' },
        { status: 503 }
      );
    }

    // Create user in Firebase Auth
    const userRecord = await adminAuth.createUser({
      email,
      password,
      displayName: name,
    });

    // Build Firestore document — fields differ per role
    const firestoreData: Record<string, any> = {
      name,
      email,
      role: role || 'staff',
      department: department || '',
      isBlocked: false,
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    };

    if (role === 'lecturer') {
      firestoreData.lecturerCategory = lecturerCategory || '';
    } else if (role === 'staff') {
      firestoreData.staffCatalog = staffCatalog || department || '';
    }

    await adminDb.collection('users').doc(userRecord.uid).set(firestoreData);

    return NextResponse.json({ success: true, uid: userRecord.uid });

  } catch (error: any) {
    console.error('Error creating user:', error);
    return NextResponse.json({ error: error.message || 'Internal Server Error' }, { status: 500 });
  }
}
