
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Livora/core/widgets/custom_text_field.dart';
import 'package:Livora/core/widgets/app_button.dart';
import 'package:Livora/core/widgets/custom_dialog.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/core/animations/page_transition_wrapper.dart';

class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleResetPassword() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref
            .read(firebaseAuthNotifierProvider.notifier)
            .sendPasswordReset(_emailController.text.trim());

        if (mounted) {
          CustomDialog.show(
            context,
            title: 'Link Sent',
            message: 'A password reset link has been sent to your email address.',
            type: DialogType.success,
            primaryButtonText: 'Back to Login',
            onPrimaryPressed: () => context.pop(),
          );
          _emailController.clear();
        }
      } catch (e) {
        if (mounted) {
           CustomDialog.show(
            context,
            title: 'Error',
            message: e.toString().replaceAll('Exception: ', ''),
            type: DialogType.error,
          );
        }
      } finally {
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.iconTheme.color),
          onPressed: () => context.pop(),
        ),
      ),
      extendBodyBehindAppBar: true,
      body: PageTransitionWrapper(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 450),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: theme.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.lock_reset_rounded,
                        size: 48,
                        color: theme.primaryColor,
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    'Forgot Password?',
                    style: theme.textTheme.displaySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Enter your email address to receive reset instructions.',
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  Form(
                    key: _formKey,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        CustomTextField(
                          label: 'Email Address',
                          controller: _emailController,
                          prefixIcon: Icons.email_outlined,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return 'Required';
                            if (!value.contains('@')) return 'Invalid email';
                            return null;
                          },
                        ),
                        const SizedBox(height: 32),

                        AppButton(
                          text: 'Send Reset Link',
                          isLoading: _isLoading,
                          onPressed: _handleResetPassword,
                          fullWidth: true,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                   AppButton(
                    text: "Back to Sign In",
                    onPressed: () => context.pop(),
                    type: AppButtonType.text,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

