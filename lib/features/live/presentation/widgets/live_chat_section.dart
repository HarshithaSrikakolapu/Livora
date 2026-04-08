import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:Livora/core/theme/color_palette.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';
import 'package:Livora/features/live/domain/entities/chat_message.dart';
import 'package:Livora/features/live/presentation/providers/live_providers.dart';

class LiveChatSection extends ConsumerStatefulWidget {
  final String streamId;
  const LiveChatSection({super.key, required this.streamId});

  @override
  ConsumerState<LiveChatSection> createState() => _LiveChatSectionState();
}

class _LiveChatSectionState extends ConsumerState<LiveChatSection> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    if (_messageController.text.trim().isEmpty) return;

    final authState = ref.read(firebaseAuthNotifierProvider);
    if (authState is! Authenticated) return;

    final message = ChatMessage(
      id: '', // Firestore will assign
      senderId: authState.user.id,
      senderName: authState.user.fullName,
      message: _messageController.text.trim(),
      timestamp: DateTime.now(),
    );

    ref.read(liveStreamServiceProvider).sendChatMessage(widget.streamId, message);
    _messageController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final chatAsync = ref.watch(chatMessagesProvider(widget.streamId));

    return Column(
      children: [
        Expanded(
          child: chatAsync.when(
            data: (messages) => ListView.builder(
              controller: _scrollController,
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              itemCount: messages.length,
              itemBuilder: (context, index) {
                final msg = messages[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            msg.senderName,
                            style: const TextStyle(
                              color: ColorPalette.livoraRed,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            DateFormat('HH:mm').format(msg.timestamp),
                            style: const TextStyle(
                              color: ColorPalette.softGrey,
                              fontSize: 10,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 2),
                      Text(
                        msg.message,
                        style: const TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ],
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => Center(child: Text('Error: $e')),
          ),
        ),
        
        // Input Area
        Container(
          padding: const EdgeInsets.all(8.0),
          decoration: const BoxDecoration(
            color: ColorPalette.darkSurface,
            border: Border(top: BorderSide(color: ColorPalette.darkSurfaceVariant)),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Say something...',
                    hintStyle: const TextStyle(color: ColorPalette.softGrey),
                    filled: true,
                    fillColor: ColorPalette.darkSurfaceVariant,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(24),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.send, color: ColorPalette.livoraRed),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
