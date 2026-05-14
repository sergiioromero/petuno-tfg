const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

exports.sendPushNotification = functions.firestore
  .document('notifications/{userId}/items/{itemId}')
  .onCreate(async (snap, context) => {
    const { userId } = context.params;
    const data = snap.data();

    const userDoc = await admin.firestore().collection('users').doc(userId).get();
    const fcmToken = userDoc.data()?.fcmToken;

    if (!fcmToken) {
      functions.logger.info(`No FCM token for user ${userId}`);
      return null;
    }

    const title = data.fromName || 'Petuno';
    const body = data.message || '';

    const message = {
      token: fcmToken,
      notification: { title, body },
      data: {
        type: data.type || '',
        userId,
      },
    };

    try {
      await admin.messaging().send(message);
      functions.logger.info(`Push sent to ${userId}: ${title} - ${body}`);
    } catch (err) {
      functions.logger.error('Error sending push:', err);
    }

    return null;
  });
