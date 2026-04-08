
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:Livora/features/social/presentation/providers/social_providers.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';
import 'package:Livora/features/social/domain/repositories/social_repository.dart';
import 'package:Livora/core/theme/color_palette.dart';

class CommentsSheet extends ConsumerStatefulWidget {
  final String postId;

  const CommentsSheet({super.key, required this.postId});

  @override
  ConsumerState<CommentsSheet> createState() => _CommentsSheetState();
}

class _CommentsSheetState extends ConsumerState<CommentsSheet> {
  final TextEditingController _controller = TextEditingController();
  bool _isPosting = false;

  void _postComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final authState = ref.read(firebaseAuthNotifierProvider);
    if (authState is! Authenticated) return;

    setState(() {
      _isPosting = true;
    });

    try {
      await ref.read(socialRepositoryProvider).addComment(
        widget.postId,
        text,
        authState.user.id,
        authState.user.fullName,
        authState.user.avatarUrl,
      );
      _controller.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) {
        setState(() {
          _isPosting = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final commentsAsync = ref.watch(commentsStreamProvider(widget.postId));
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: BoxDecoration(
        color: theme.bottomSheetTheme.backgroundColor ?? theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: theme.dividerColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          
          Text(
            'Comments', 
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          Divider(color: theme.dividerColor),

          // Comments List
          Expanded(
            child: commentsAsync.when(
              data: (comments) {
                if (comments.isEmpty) {
                  return Center(
                    child: Text(
                      'No comments yet. Start the conversation!', 
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                      ),
                    ),
                  );
                }
                return ListView.builder(
                  itemCount: comments.length,
                  padding: const EdgeInsets.all(16),
                  itemBuilder: (context, index) {
                    final comment = comments[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          CircleAvatar(
                            radius: 16,
                            backgroundColor: isDark 
                              ? theme.colorScheme.surface 
                              : ColorPalette.softGrey, 
                            backgroundImage: comment.userAvatar != null ? NetworkImage(comment.userAvatar!) : null,
                            child: comment.userAvatar == null 
                                ? Text(
                                    comment.userName[0].toUpperCase(), 
                                    style: TextStyle(
                                      fontSize: 12, 
                                      color: ColorPalette.pureWhite
                                    ),
                                  ) 
                                : null,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    Text(
                                      comment.userName,
                                      style: theme.textTheme.bodyMedium?.copyWith(
                                        fontWeight: FontWeight.bold, 
                                        fontSize: 13,
                                        color: theme.colorScheme.primary, // Keep names colored or primary
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      DateFormat.yMMMd().format(comment.createdAt),
                                      style: theme.textTheme.bodySmall?.copyWith(fontSize: 11),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  comment.text, 
                                  style: theme.textTheme.bodyMedium?.copyWith(fontSize: 14),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
              loading: () => Center(child: CircularProgressIndicator(color: theme.primaryColor)),
              error: (e, s) => Center(
                child: Text('Error: $e', style: TextStyle(color: theme.colorScheme.error)),
              ),
            ),
          ),

          // Input
          Divider(height: 1, color: theme.dividerColor),
          Padding(
            padding: EdgeInsets.only(
              bottom: MediaQuery.of(context).viewInsets.bottom + 16,
              left: 16,
              right: 16,
              top: 12,
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    style: theme.textTheme.bodyMedium,
                    decoration: InputDecoration(
                      hintText: 'Add a comment...',
                      hintStyle: theme.inputDecorationTheme.hintStyle,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                      filled: true,
                      fillColor: theme.inputDecorationTheme.fillColor,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    ),
                    minLines: 1,
                    maxLines: 4,
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _isPosting ? null : _postComment,
                  icon: _isPosting 
                      ? SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: theme.primaryColor)) 
                      : Icon(Icons.send, color: theme.primaryColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
