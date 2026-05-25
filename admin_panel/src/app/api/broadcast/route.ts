import { NextResponse } from 'next/server';
import { admin, adminMessaging } from '@/lib/firebase-admin';

export async function POST(request: Request) {
  try {
    const body = await request.json();
    const { title, body: messageBody, imageUrl, topic } = body;

    if (!title || !messageBody) {
      return NextResponse.json({ error: 'Title and body are required' }, { status: 400 });
    }

    // Construction check
    if (admin.apps.length === 0) {
      return NextResponse.json(
        { error: 'Firebase Admin SDK is not initialized. Please configure service-account.json.' },
        { status: 503 }
      );
    }

    // Construct the FCM payload
    const message: admin.messaging.Message = {
      notification: {
        title,
        body: messageBody,
        ...(imageUrl ? { imageUrl } : {})
      },
      topic: topic || 'all',
      // Ensure Android and iOS specific high-priority settings
      android: {
        priority: 'high',
        notification: {
          channelId: 'high_importance_channel',
          ...(imageUrl ? { imageUrl } : {}),
        }
      },
      apns: {
        payload: {
          aps: {
            contentAvailable: true,
            sound: 'default'
          }
        }
      }
    };

    // Send the message
    const response = await adminMessaging.send(message);

    return NextResponse.json({
      success: true,
      messageId: response,
      note: 'Broadcast sent to FCM successfully'
    });

  } catch (error: any) {
    console.error('Error sending broadcast:', error);
    return NextResponse.json(
      { error: error.message || 'Internal Server Error' },
      { status: 500 }
    );
  }
}
