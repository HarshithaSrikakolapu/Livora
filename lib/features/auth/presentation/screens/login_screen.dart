import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Livora/core/widgets/app_button.dart';
import 'package:Livora/core/widgets/custom_text_field.dart';
import 'package:Livora/core/widgets/custom_dialog.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';
import 'package:Livora/core/animations/page_transition_wrapper.dart';
import 'package:Livora/core/widgets/background_paths.dart';


class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      // Logic handled by provider
      try {
        await ref.read(firebaseAuthNotifierProvider.notifier).login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );
      } catch (e) {
        // Error handling in listener
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(firebaseAuthNotifierProvider);

    ref.listen<AuthState>(firebaseAuthNotifierProvider, (previous, next) {
      if (next is AuthError) {
        CustomDialog.show(
          context,
          title: 'Authentication Failed',
          message: next.message,
          type: DialogType.error,
        );
      } else if (next is Authenticated) {
        context.go('/home');
      } else if (next is PendingApproval) {
        context.go('/pending-approval');
      }
    });

    return BackgroundPaths(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: PageTransitionWrapper(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 450),
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // --- Header ---
                      Icon(
                        Icons.supervised_user_circle_rounded,
                        size: 80,
                        color: theme.primaryColor,
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Welcome Back',
                        style: theme.textTheme.displaySmall,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Sign in to continue',
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.6),
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 48),

                      // --- Form Fields ---
                      CustomTextField(
                        label: 'Email',
                        hintText: 'user@example.com',
                        controller: _emailController,
                        prefixIcon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email';
                          }
                          if (!value.contains('@')) {
                            return 'Please enter a valid email';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20),
                      CustomTextField(
                        label: 'Password',
                        hintText: '••••••••',
                        controller: _passwordController,
                        prefixIcon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            color: theme.colorScheme.onSurface.withOpacity(0.5),
                          ),
                          onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          return null;
                        },
                      ),
                      
                      // --- Forgot Password ---
                      Align(
                        alignment: Alignment.centerRight,
                        child: AppButton(
                          text: 'Forgot Password?',
                          onPressed: () => context.push('/forgot-password'),
                          type: AppButtonType.text,
                          height: 40,
                        ),
                      ),
                      const SizedBox(height: 24),
                      
                      // --- Action Button ---
                      AppButton(
                        text: 'Sign In',
                        isLoading: authState is AuthLoading,
                        onPressed: _handleLogin,
                        type: AppButtonType.primary,
                        fullWidth: true,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // --- Register Link ---
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: <Widget>[
                          Text(
                            "Don't have an account?",
                            style: TextStyle(
                              color: theme.colorScheme.onSurface.withOpacity(0.6),
                            ),
                          ),
                          AppButton(
                            text: 'Sign Up',
                            onPressed: () => context.push('/register'),
                            type: AppButtonType.text,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
