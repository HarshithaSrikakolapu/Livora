
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/social_providers.dart';
import '../../domain/entities/relationship.dart';
import '../../../auth/presentation/providers/firebase_auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../../../core/theme/color_palette.dart';
import '../../../../core/widgets/animated_widgets.dart';

class ActivityScreen extends ConsumerWidget {
  const ActivityScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingRequestsAsync = ref.watch(pendingRequestsStreamProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Activity'),
      ),
      body: pendingRequestsAsync.when(
        data: (requests) {
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   Icon(Icons.favorite_border, size: 60, color: ColorPalette.primary.withOpacity(0.5)),
                  const SizedBox(height: 16),
                   Text('No pending requests', style: TextStyle(color: ColorPalette.primary.withOpacity(0.5))),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final req = requests[index];
              return ScaleFadeIn(
                delay: Duration(milliseconds: 50 * index),
                child: _RequestTile(request: req),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator(color: ColorPalette.primary)),
        error: (e, s) => Center(child: Text('Error: $e', style: const TextStyle(color: ColorPalette.primary))),
      ),
    );
  }
}

class _RequestTile extends ConsumerStatefulWidget {
  final Relationship request;
  const _RequestTile({Key? key, required this.request}) : super(key: key);

  @override
  ConsumerState<_RequestTile> createState() => _RequestTileState();
}

class _RequestTileState extends ConsumerState<_RequestTile> {
  bool _isLoading = false;

  void _respond(bool accept) async {
    setState(() => _isLoading = true);
    try {
      final authState = ref.read(firebaseAuthNotifierProvider);
      if (authState is Authenticated) {
        if (accept) {
          await ref.read(acceptConnectionRequestProvider)(
            authState.user.id,
            widget.request.followerId, // The person who requested
          );
        } else {
          // Reject logic
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    // We need to fetch user details (avatar, name) if not fully populated in Relationship
    // But Relationship entity usually has denormalized data
    final displayName = widget.request.memberName ?? 'Unknown User';
    final displayAvatar = widget.request.memberAvatar;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: ColorPalette.lightGrey,
              backgroundImage: displayAvatar != null ? NetworkImage(displayAvatar) : null,
              child: displayAvatar == null ? Text(displayName[0], style: const TextStyle(color: ColorPalette.primary)) : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    displayName,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: ColorPalette.primary),
                  ),
                  const Text('Sent a connection request', style: TextStyle(fontSize: 12, color: ColorPalette.textSecondary)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            _isLoading
                ? const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2, color: ColorPalette.primary))
                : Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ElevatedButton(
                        onPressed: () => _respond(true),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: ColorPalette.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          minimumSize: const Size(0, 36),
                        ),
                        child: const Text('Accept'),
                      ),
                      const SizedBox(width: 8),
                      OutlinedButton(
                        onPressed: () => _respond(false),
                        style: OutlinedButton.styleFrom(
                           padding: const EdgeInsets.symmetric(horizontal: 16),
                           minimumSize: const Size(0, 36),
                           side: const BorderSide(color: ColorPalette.primary),
                        ),
                         child: const Text('Delete'),
                      ),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
