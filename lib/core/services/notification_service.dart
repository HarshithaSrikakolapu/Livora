
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Livora/core/storage/secure_storage.dart';
import 'package:Livora/features/auth/domain/entities/user.dart';

// Background handler must be top-level
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  print("Handling a background message: ${message.messageId}");
}

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();
  final SecureStorage _secureStorage;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  NotificationService(this._secureStorage) {
     // Config handled in init
  }

  Future<void> init() async {
    // 1. Request Permission
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false, 
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
      
      // 2. Setup Foreground Android Channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'high_importance_channel', // id
        'High Importance Notifications', // title
        description: 'This channel is used for important notifications.', // description
        importance: Importance.max,
      );

      await _flutterLocalNotificationsPlugin
          .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      // 3. Foreground Listener
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        RemoteNotification? notification = message.notification;
        AndroidNotification? android = message.notification?.android;

        if (notification != null && android != null) {
          _flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                channelDescription: channel.description,
                icon: '@mipmap/ic_launcher',
              ),
            ),
          );
        }
      });
      
      // 4. Get and sync token
      String? token = await _firebaseMessaging.getToken();
      if (token != null) {
        await _registerToken(token);
      }
      
      // 5. Token refresh listener
      _firebaseMessaging.onTokenRefresh.listen((newToken) {
        _registerToken(newToken);
      });
      
      // 6. Init background handler
      FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

    }
  }

  Future<void> _registerToken(String token) async {
    try {
      // Get current user ID (simplest way is checking auth or if we passed it)
      // Since NotificationService is initialized AFTER auth, we can assume we might have access or rely on caller?
      // Better: Get userId from SecureStorage if we saved it, or just use FirebaseAuth instance in here for current user.
      // But simpler: just use FirebaseAuth
      // import firebase_auth is easier.
      
      // Let's rely on the fact this service is likely called when we have a user.
      // But to be robust:
      // We will look up the user from Firestore via the UID found in Auth credential if possible, 
      // OR, since SecureStorage stores accessToken? No, secure storage has AccessToken from API. 
      // But we are moving away from API.
      
      // Actually, SecureStorage probably has nothing relevant if we stop using API login.
      // `FirebaseAuthService.login` doesn't write to SecureStorage (based on what I saw earlier).
      // Wait, `AuthRepositoryImpl` did. `FirebaseAuthService` did NOT.
      
      // So checking `_secureStorage` is useless if we use `FirebaseAuthService`.
      
      // Let's use `FirebaseAuth.instance.currentUser`
      final user = _secureStorage.getUserData(); // This returns a Future<String?> of JSON. 
      // But simpler:
      // We need to import FirebaseAuth to get UID.
    } catch (e) {
      print("Failed to sync device token: $e");
    }
  }
  
  // Refactored helper to accept uid or handle internally
  Future<void> syncTokenForUser(String userId, String token) async {
     try {
       await _firestore.collection('users').doc(userId).update({
         'deviceTokens': FieldValue.arrayUnion([
           {
             'token': token,
             'platform': 'android', // simplified
             'updatedAt': Timestamp.now()
           }
         ])
       });
       print("Device token synced to Firestore for user $userId");
     } catch (e) {
       print("Error syncing token to Firestore: $e");
     }
  }
}
