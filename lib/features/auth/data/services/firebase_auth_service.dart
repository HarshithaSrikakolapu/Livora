import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:Livora/features/auth/domain/entities/user.dart' as app_user;

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get current user
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();
  
  firebase_auth.User? get currentUser => _auth.currentUser;
  
  // Register with email and password
  Future<app_user.User> register({
    required String email,
    required String password,
    required String fullName,
    String? phone,
    required String accountType,
  }) async {
    try {
      // Create Firebase Auth user
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Create user document in Firestore
      final user = app_user.User(
        id: credential.user!.uid,
        email: email,
        fullName: fullName,
        phone: phone,
        role: accountType, // Use selected account type
        avatarUrl: null,
        bio: null,
        isApproved: false, // Requires Super Admin approval
        isActive: true,
        createdAt: DateTime.now(),
      );
      
      await _firestore.collection('users').doc(user.id).set({
        'email': user.email,
        'fullName': user.fullName,
        'phone': user.phone,
        'role': user.role,
        'avatarUrl': user.avatarUrl,
        'bio': user.bio,
        'isApproved': user.isApproved,
        'isActive': user.isActive,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'favorite_orgs': []
      });
      
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      print('FirebaseAuthException: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      print('Generic Exception during registration: $e');
      throw AuthException('Registration failed: ${e.toString()}', 'UNKNOWN_ERROR');
    }
  }
  
  // Login with email and password
  Future<app_user.User> login({
    required String email,
    required String password,
  }) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      // Get user data from Firestore
      final doc = await _firestore
          .collection('users')
          .doc(credential.user!.uid)
          .get();
      
      if (!doc.exists) {
        throw Exception('User data not found');
      }
      
      final user = app_user.User.fromFirestore(doc.data()!, doc.id);
      
      // Check if user is approved
      if (!user.isApproved) {
        throw UnapprovedUserException('Your account is awaiting admin approval');
      }
      
      // Check if user is active
      if (!user.isActive) {
        throw InactiveUserException('Your account has been suspended');
      }
      
      // Update last login
      await _firestore.collection('users').doc(user.id).update({
        'lastLoginAt': FieldValue.serverTimestamp(),
      });
      
      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }
  
  // Logout
  Future<void> logout() async {
    await _auth.signOut();
  }
  
  // Get current user data
  Future<app_user.User?> getCurrentUserData() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    
    print('DEBUG: Fetching user data for UID: ${user.uid}');
    final doc = await _firestore.collection('users').doc(user.uid).get();
    if (!doc.exists) {
      print('DEBUG: User doc does not exist for UID: ${user.uid}');
      return null;
    }
    
    final data = doc.data()!;
    print('DEBUG: Data fetched: $data');
    return app_user.User.fromFirestore(data, doc.id);
  }
  
  // Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    debugPrint('DEBUG: Attempting to send password reset email to: $email');
    try {
      await _auth.sendPasswordResetEmail(email: email);
      debugPrint('DEBUG: Firebase reported success for password reset email to: $email');
    } on firebase_auth.FirebaseAuthException catch (e) {
      debugPrint('DEBUG: Firebase Auth Exception during password reset: ${e.code} - ${e.message}');
      throw _handleAuthException(e);
    } catch (e) {
      debugPrint('DEBUG: Unexpected error during password reset: $e');
      rethrow;
    }
  }
  
  // Handle Firebase Auth exceptions
  AuthException _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return AuthException('No user found with this email', 'USER_NOT_FOUND');
      case 'wrong-password':
        return AuthException('Incorrect password', 'WRONG_PASSWORD');
      case 'email-already-in-use':
        return AuthException('An account already exists with this email', 'EMAIL_EXISTS');
      case 'weak-password':
        return AuthException('Password is too weak', 'WEAK_PASSWORD');
      case 'invalid-email':
        return AuthException('Invalid email address', 'INVALID_EMAIL');
      case 'user-disabled':
        return AuthException('This account has been disabled', 'USER_DISABLED');
      case 'too-many-requests':
        return AuthException('Too many attempts. Please try again later', 'TOO_MANY_REQUESTS');
      default:
        return AuthException(e.message ?? 'Authentication failed', e.code);
    }
  }
}

// Custom exceptions
class AuthException implements Exception {
  final String message;
  final String code;
  
  AuthException(this.message, this.code);
  
  @override
  String toString() => message;
}

class UnapprovedUserException extends AuthException {
  UnapprovedUserException(String message) : super(message, 'AWAITING_APPROVAL');
}

class InactiveUserException extends AuthException {
  InactiveUserException(String message) : super(message, 'ACCOUNT_SUSPENDED');
}
