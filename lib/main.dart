import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/config/firebase_config.dart';
import 'features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'features/auth/presentation/providers/auth_state.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/pending_approval_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/home/presentation/screens/home_screen.dart';
import 'core/services/notification_providers.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/theme_provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: FirebaseOptions(
      apiKey: FirebaseConfig.apiKey,
      appId: FirebaseConfig.appId,
      messagingSenderId: FirebaseConfig.messagingSenderId,
      projectId: FirebaseConfig.projectId,
      storageBucket: FirebaseConfig.storageBucket,
      authDomain: FirebaseConfig.authDomain,
    ),
  );
  
  runApp(const ProviderScope(child: MyApp()));
}

class MyApp extends ConsumerWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Initialize notifications when auth state changes
    ref.watch(notificationInitializerProvider);

    // Watch theme mode
    final themeMode = ref.watch(themeModeProvider);

    final router = GoRouter(
      initialLocation: '/',
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const AuthChecker(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/register',
          builder: (context, state) => const RegisterScreen(),
        ),
        GoRoute(
          path: '/pending-approval',
          builder: (context, state) => const PendingApprovalScreen(),
        ),
        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const HomeScreen(),
        ),
      ],
    );

    return MaterialApp.router(
      title: 'Livora',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme, // Premium Dark Theme
      themeMode: themeMode, // Controlled by provider
      routerConfig: router,
    );
  }
}

class AuthChecker extends ConsumerWidget {
  const AuthChecker({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(firebaseAuthNotifierProvider);

    // Handle navigation based on auth state
    WidgetsBinding.instance.addPostFrameCallback((_) {
      authState.when(
        initial: () {},
        loading: () {},
        authenticated: (user) => context.go('/home'),
        unauthenticated: () => context.go('/login'),
        error: (message, errorCode) => context.go('/login'),
        pendingApproval: (user) => context.go('/pending-approval'),
      );
    });

    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}

// Extension for state pattern matching
extension AuthStateExtension on AuthState {
  T when<T>({
    required T Function() initial,
    required T Function() loading,
    required T Function(dynamic user) authenticated,
    required T Function() unauthenticated,
    required T Function(String message, String? errorCode) error,
    required T Function(dynamic user) pendingApproval,
  }) {
    if (this is AuthInitial) return initial();
    if (this is AuthLoading) return loading();
    if (this is Authenticated) return authenticated((this as Authenticated).user);
    if (this is Unauthenticated) return unauthenticated();
    if (this is AuthError) {
      final state = this as AuthError;
      return error(state.message, state.errorCode);
    }
    if (this is PendingApproval) {
      return pendingApproval((this as PendingApproval).user);
    }
    throw Exception('Unknown auth state');
  }
}
