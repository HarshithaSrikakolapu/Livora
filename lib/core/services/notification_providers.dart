
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';
import 'notification_service.dart';
import 'package:Livora/core/storage/secure_storage.dart';

final notificationServiceProvider = Provider<NotificationService>((ref) {
  final secureStorage = ref.watch(secureStorageProvider);
  return NotificationService(secureStorage);
});

// Logic to Initialize Notifications when Authenticated
final notificationInitializerProvider = Provider<void>((ref) {
  final authState = ref.watch(firebaseAuthNotifierProvider);
  
  if (authState is Authenticated) {
    print("User authenticated, initializing notification service...");
    ref.read(notificationServiceProvider).init();
  }
});
