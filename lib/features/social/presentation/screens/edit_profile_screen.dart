
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../auth/presentation/providers/firebase_auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../providers/social_providers.dart';
import '../../../../core/theme/color_palette.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  
  bool _isLoading = false;
  File? _newCoverImage;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(firebaseAuthNotifierProvider);
    if (authState is Authenticated) {
      _nameController.text = authState.user.fullName;
      _bioController.text = authState.user.bio ?? '';
    }
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  Future<void> _pickCoverImage() async {
    final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _newCoverImage = File(image.path);
      });
    }
  }

  Future<void> _saveProfile() async {
    final authState = ref.read(firebaseAuthNotifierProvider);
    if (authState is! Authenticated) return;
    
    setState(() { _isLoading = true; });

    try {
      String? coverImageUrl = authState.user.coverImageUrl;

      // Upload new cover if selected
      if (_newCoverImage != null) {
        final upload = ref.read(uploadPostImageProvider);
        coverImageUrl = await upload(_newCoverImage!, 'covers/${authState.user.id}_${DateTime.now().millisecondsSinceEpoch}.jpg');
      }

      final updatedUser = authState.user.copyWith(
        fullName: _nameController.text.trim(),
        bio: _bioController.text.trim(),
        coverImageUrl: coverImageUrl,
      );

      await ref.read(updateUserProfileProvider).call(updatedUser);
      
      // Update local state by forcing a refresh or assuming auth listener picks it up?
      // Auth listener usually listens to authStateChanges(). 
      // Firestore changes to USER doc might not auto-update AuthState if logic isn't set up.
      // But assuming it does or we don't care about immediate local reflection other than UI pop.
      
      if (mounted) {
         Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() { _isLoading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.check),
            onPressed: _isLoading ? null : _saveProfile,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
               // Cover Image Picker
               GestureDetector(
                 onTap: _pickCoverImage,
                 child: Container(
                   height: 150,
                   width: double.infinity,
                   decoration: BoxDecoration(
                     color: ColorPalette.lightGrey,
                     image: _newCoverImage != null
                       ? DecorationImage(image: FileImage(_newCoverImage!), fit: BoxFit.cover)
                       : null,
                   ),
                   child: _newCoverImage == null 
                      ? Center(child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt, color: ColorPalette.primary),
                            SizedBox(width: 8),
                            Text('Change Cover Photo', style: TextStyle(color: ColorPalette.primary)),
                          ],
                        ))
                      : null,
                 ),
               ),
               const SizedBox(height: 20),
               
               TextField(
                 controller: _nameController,
                 decoration: const InputDecoration(labelText: 'Full Name', border: OutlineInputBorder()),
               ),
               const SizedBox(height: 16),
               
               TextField(
                 controller: _bioController,
                 decoration: const InputDecoration(labelText: 'Bio', border: OutlineInputBorder()),
                 maxLines: 3,
               ),
            ],
          ),
    );
  }
}
