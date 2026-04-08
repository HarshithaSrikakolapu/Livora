import 'package:Livora/features/auth/domain/entities/user.dart';

abstract class AuthState {
  const AuthState();
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;
  const Authenticated(this.user);
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;
  final String? errorCode;
  
  const AuthError(this.message, {this.errorCode});
}

class PendingApproval extends AuthState {
  final User user;
  const PendingApproval(this.user);
}
