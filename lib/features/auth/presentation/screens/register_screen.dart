
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Livora/core/widgets/custom_text_field.dart';
import 'package:Livora/core/widgets/app_button.dart';
import 'package:Livora/core/widgets/custom_dialog.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';
import 'package:Livora/core/animations/page_transition_wrapper.dart';
import 'package:Livora/core/widgets/background_paths.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _fullNameController = TextEditingController();
  final _phoneController = TextEditingController();
  String _completePhoneNumber = '';
  bool _obscurePassword = true;
  String _accountType = 'user';
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullNameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _handleRegister() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      try {
        await ref.read(firebaseAuthNotifierProvider.notifier).register(
              email: _emailController.text.trim(),
              password: _passwordController.text,
              fullName: _fullNameController.text.trim(),
              phone: _completePhoneNumber.isNotEmpty ? _completePhoneNumber : null,
              accountType: _accountType,
            );
         // Success handled by listener
      } catch (e) {
         if (mounted) {
           CustomDialog.show(
            context,
            title: 'Registration Error',
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

    ref.listen<AuthState>(firebaseAuthNotifierProvider, (previous, next) {
      if (next is AuthError) {
        CustomDialog.show(
          context,
          title: 'Registration Failed',
          message: (next).message,
          type: DialogType.error,
        );
      } else if (next is PendingApproval) {
        CustomDialog.show(
          context,
          title: 'Registration Successful',
          message: 'Your account has been created and is awaiting approval.',
          type: DialogType.success,
          primaryButtonText: 'OK',
          onPrimaryPressed: () => context.go('/login'),
        );
      } else if (next is Authenticated) {
        context.go('/home');
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
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                     // --- Header ---
                    Text(
                      'Create Account',
                      style: theme.textTheme.displaySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Join the community today',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.textTheme.bodySmall?.color,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),

                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Full Name
                          CustomTextField(
                            label: 'Full Name',
                            controller: _fullNameController,
                            prefixIcon: Icons.person_outline_rounded,
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (value.length < 2) return 'Too short';
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          
                          // Email
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
                          const SizedBox(height: 16),
                          
                          // Phone (using Theme)
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text('Phone Number (Optional)', 
                              style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600)),
                          ),
                          IntlPhoneField(
                            controller: _phoneController,
                            decoration: InputDecoration(
                              hintText: 'Phone Number',
                              counterText: '',
                              contentPadding: const EdgeInsets.all(16),
                            ),
                            initialCountryCode: 'IN',
                            onChanged: (phone) {
                              _completePhoneNumber = phone.completeNumber;
                            },
                            style: theme.textTheme.bodyLarge,
                            dropdownTextStyle: theme.textTheme.bodyLarge,
                            dropdownIcon: Icon(Icons.arrow_drop_down, color: theme.iconTheme.color),
                          ),
                          const SizedBox(height: 16),
                          
                          // Password
                          CustomTextField(
                            label: 'Password',
                            controller: _passwordController,
                            prefixIcon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                                size: 20,
                              ),
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (value) {
                              if (value == null || value.isEmpty) return 'Required';
                              if (value.length < 6) return 'Min 6 chars';
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),
                          
                          // Account Type
                          Padding(
                            padding: const EdgeInsets.only(left: 4, bottom: 8),
                            child: Text(
                              'I want to join as:',
                              style: theme.textTheme.labelMedium?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                            ),
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: _AccountTypeCard(
                                  title: 'User',
                                  icon: Icons.person_rounded,
                                  isSelected: _accountType == 'user',
                                  onTap: () => setState(() => _accountType = 'user'),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _AccountTypeCard(
                                  title: 'Organization',
                                  icon: Icons.business_rounded,
                                  isSelected: _accountType == 'organization',
                                  onTap: () => setState(() => _accountType = 'organization'),
                                ),
                              ),
                            ],
                          ),
                          
                          const SizedBox(height: 32),
                          
                          AppButton(
                            text: 'Create Account',
                            isLoading: _isLoading,
                            onPressed: _handleRegister,
                            fullWidth: true,
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Footer
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Already have an account?',
                          style: theme.textTheme.bodyMedium,
                        ),
                        TextButton(
                          onPressed: () {
                             if (context.canPop()) {
                                context.pop();
                             } else {
                                context.go('/login');
                             }
                          },
                          child: const Text('Sign In'),
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
    );
  }
}

class _AccountTypeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _AccountTypeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: isSelected ? primaryColor.withOpacity(0.1) : theme.cardTheme.color,
            border: Border.all(
              color: isSelected ? primaryColor : theme.dividerColor,
              width: isSelected ? 2 : 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Icon(
                icon, 
                color: isSelected ? primaryColor : theme.iconTheme.color?.withOpacity(0.7),
                size: 28,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                style: theme.textTheme.labelLarge?.copyWith(
                  color: isSelected ? primaryColor : theme.textTheme.bodyMedium?.color,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


