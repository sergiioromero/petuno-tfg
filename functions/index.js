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

exports.generateResetLink = functions.https.onRequest(async (req, res) => {
  res.set('Access-Control-Allow-Origin', '*');

  if (req.method === 'OPTIONS') {
    res.status(204).send('');
    return;
  }

  if (req.method !== 'POST') {
    res.status(405).send('Method Not Allowed');
    return;
  }

  const { email } = req.body;

  if (!email) {
    res.status(400).json({ error: 'Email es requerido' });
    return;
  }

  try {
    const link = await admin.auth().generatePasswordResetLink(email, {
      url: `https://${process.env.GCLOUD_PROJECT}.firebaseapp.com/__/auth/action`,
      handleCodeInApp: false,
    });
    res.json({ link });
  } catch (error) {
    functions.logger.error('Error generating reset link:', error);
    const message =
      error.code === 'auth/user-not-found'
        ? 'Este email no está registrado'
        : 'Error al generar el enlace. Intenta de nuevo.';
    res.status(500).json({ error: message });
  }
});
