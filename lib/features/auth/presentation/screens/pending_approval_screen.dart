
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/core/widgets/app_button.dart';
import 'package:Livora/core/animations/page_transition_wrapper.dart';

class PendingApprovalScreen extends ConsumerWidget {
  const PendingApprovalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: PageTransitionWrapper(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(32.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 400),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.schedule_rounded,
                      size: 64,
                      color: Colors.orange,
                    ),
                  ),
                  const SizedBox(height: 32),
                  
                  Text(
                    'Pending Approval',
                    style: theme.textTheme.headlineMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  
                  Text(
                    'Your account is currently awaiting approval from a Super Admin. You will be notified once your account has been approved.',
                    style: theme.textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 48),
                  
                  AppButton(
                    text: 'Back to Login',
                    onPressed: () async {
                      await ref.read(firebaseAuthNotifierProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    },
                    type: AppButtonType.outline,
                    fullWidth: true,
                    icon: Icons.logout_rounded,
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
