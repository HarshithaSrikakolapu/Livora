import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:Livora/features/social/domain/entities/post.dart';
import 'package:Livora/features/social/presentation/providers/social_providers.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';

class CreatePostScreen extends ConsumerStatefulWidget {
  const CreatePostScreen({super.key});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  final TextEditingController _captionController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  Uint8List? _imageBytes;
  String? _fileName;
  bool _isLoading = false;

  @override
  void dispose() {
    _captionController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        final bytes = await image.readAsBytes();
        
        setState(() {
          _imageBytes = bytes;
          _fileName = image.name;
        });
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  Future<void> _sharePost() async {
    if (_imageBytes == null && _captionController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please add an image or text')),
      );
      return;
    }

    final authState = ref.read(firebaseAuthNotifierProvider);
    if (authState is! Authenticated) return;

    setState(() {
      _isLoading = true;
    });

    try {
      String imageUrl = '';
      
      if (_imageBytes != null) {
         final uploadImage = ref.read(uploadPostImageProvider);
         imageUrl = await uploadImage(_imageBytes!, _fileName ?? 'post.jpg');
      }
      
      final createPost = ref.read(createPostProvider);
      
      final newPost = Post(
        id: '', 
        userId: authState.user.id,
        userName: authState.user.fullName,
        userAvatar: authState.user.avatarUrl,
        type: imageUrl.isNotEmpty ? PostType.image : PostType.image, 
        mediaUrl: imageUrl,
        caption: _captionController.text.trim(),
        createdAt: DateTime.now(),
      );

      await createPost(newPost);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post Shared!')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Create Post'),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _sharePost,
            child: _isLoading 
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Share', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Consumer(builder: (context, ref, _) {
              final authState = ref.watch(firebaseAuthNotifierProvider);
              if (authState is Authenticated) {
                 return Row(
                   children: [
                     CircleAvatar(
                       radius: 20,
                       backgroundImage: (authState.user.avatarUrl != null) ? NetworkImage(authState.user.avatarUrl!) : null,
                     ),
                     const SizedBox(width: 10),
                     Text(authState.user.fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
                   ],
                 );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 16),
          
            TextField(
              controller: _captionController,
              decoration: const InputDecoration(
                hintText: 'What\'s on your mind?',
                border: InputBorder.none,
              ),
              maxLines: null,
              minLines: 3,
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 16),
            
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                width: double.infinity,
                constraints: const BoxConstraints(maxHeight: 300),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: _imageBytes != null 
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.memory(_imageBytes!, fit: BoxFit.cover),
                    )
                  : const Padding(
                      padding: EdgeInsets.all(32.0),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.add_photo_alternate_outlined, size: 40, color: Colors.grey),
                          SizedBox(height: 8),
                          Text('Add Photo', style: TextStyle(color: Colors.grey)),
                        ],
                      ),
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

