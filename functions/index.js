const functions = require('firebase-functions');
const admin = require('firebase-admin');

admin.initializeApp();

/**
 * Creates an admin user without automatically signing them in
 * This function uses Firebase Admin SDK to create users without affecting the current session
 */
exports.createAdmin = functions.https.onCall(async (data, context) => {
  // Verify that the caller is authenticated and is an admin
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to create admin users'
    );
  }

  // Verify the caller is an admin
  const callerUserDoc = await admin.firestore()
    .collection('users')
    .doc(context.auth.uid)
    .get();

  if (!callerUserDoc.exists) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'User document not found'
    );
  }

  const callerRole = callerUserDoc.data().role;
  if (callerRole !== 'admin') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can create admin users'
    );
  }

  // Extract data from request
  const { email, password, name, accessLevel } = data;

  if (!email || !password || !name || !accessLevel) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields: email, password, name, accessLevel'
    );
  }

  try {
    // Split name into firstName and lastName
    const nameParts = name.trim().split(' ');
    const firstName = nameParts.length > 0 ? nameParts[0] : '';
    const lastName = nameParts.length > 1 ? nameParts.slice(1).join(' ') : '';

    // Create user in Firebase Authentication using Admin SDK
    // This does NOT sign in the user automatically
    const userRecord = await admin.auth().createUser({
      email: email,
      password: password,
      emailVerified: false,
    });

    const userId = userRecord.uid;

    // Create user document in Firestore with admin role
    await admin.firestore().collection('users').doc(userId).set({
      email: email,
      role: 'admin',
      profileId: null, // Will be updated after profile creation
      createdAt: admin.firestore.FieldValue.serverTimestamp(),
    });

    // Create admin profile
    const profileRef = await admin.firestore()
      .collection('adminProfiles')
      .add({
        userId: userId,
        firstName: firstName,
        lastName: lastName,
        accessLevel: accessLevel,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    const profileId = profileRef.id;

    // Update user with profileId
    await admin.firestore().collection('users').doc(userId).update({
      profileId: profileId,
    });

    // Return the created admin profile data
    return {
      profileId: profileId,
      userId: userId,
      name: name,
      accessLevel: accessLevel,
      email: email,
    };
  } catch (error) {
    console.error('Error creating admin user:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Failed to create admin user: ${error.message}`
    );
  }
});

/**
 * Deletes a user from both Firebase Authentication and Firestore
 * This function uses Firebase Admin SDK to delete any user
 */
exports.deleteUser = functions.https.onCall(async (data, context) => {
  // Verify that the caller is authenticated and is an admin
  if (!context.auth) {
    throw new functions.https.HttpsError(
      'unauthenticated',
      'User must be authenticated to delete users'
    );
  }

  // Verify the caller is an admin
  const callerUserDoc = await admin.firestore()
    .collection('users')
    .doc(context.auth.uid)
    .get();

  if (!callerUserDoc.exists) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'User document not found'
    );
  }

  const callerRole = callerUserDoc.data().role;
  if (callerRole !== 'admin') {
    throw new functions.https.HttpsError(
      'permission-denied',
      'Only admins can delete users'
    );
  }

  // Prevent deleting own account
  if (context.auth.uid === data.userId) {
    throw new functions.https.HttpsError(
      'permission-denied',
      'You cannot delete your own account'
    );
  }

  // Extract data from request
  const { userId, profileId } = data;

  if (!userId || !profileId) {
    throw new functions.https.HttpsError(
      'invalid-argument',
      'Missing required fields: userId, profileId'
    );
  }

  try {
    // Delete admin profile from Firestore
    await admin.firestore()
      .collection('adminProfiles')
      .doc(profileId)
      .delete();

    // Delete user document from Firestore
    await admin.firestore()
      .collection('users')
      .doc(userId)
      .delete();

    // Delete user from Firebase Authentication using Admin SDK
    await admin.auth().deleteUser(userId);

    return { success: true };
  } catch (error) {
    console.error('Error deleting user:', error);
    throw new functions.https.HttpsError(
      'internal',
      `Failed to delete user: ${error.message}`
    );
  }
});

