import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../../core/services/storage_service.dart';
import '../../../auth/presentation/providers/firebase_auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';

import '../../../../core/theme/theme_provider.dart';

class EditProfileScreen extends ConsumerStatefulWidget {





  const EditProfileScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _bioController;
  late TextEditingController _phoneController;
  String? _completePhoneNumber;
  
  bool _isLoading = false;
  Uint8List? _newImageBytes;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(firebaseAuthNotifierProvider);
    if (authState is Authenticated) {
      final user = authState.user;
      _nameController = TextEditingController(text: user.fullName);
      _bioController = TextEditingController(text: user.bio ?? '');
      _phoneController = TextEditingController(text: user.phone ?? '');
      _completePhoneNumber = user.phone;
    } else {
      // Should not happen if guarded
      _nameController = TextEditingController();
      _bioController = TextEditingController();
      _phoneController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery, maxWidth: 800);
    
    if (pickedFile != null) {
      final bytes = await pickedFile.readAsBytes();
      setState(() {
        _newImageBytes = bytes;
      });
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final authState = ref.read(firebaseAuthNotifierProvider);
      if (authState is! Authenticated) return;
      
      final user = authState.user;
      String? avatarUrl = user.avatarUrl;
      
      // 1. Upload new image if selected
      if (_newImageBytes != null) {
        print('Starting image upload...');
        final storage = ref.read(storageServiceProvider);
        avatarUrl = await storage.uploadImage(
          pathOrName: 'avatar_${user.id}.jpg',
          data: _newImageBytes!,
          folder: 'avatars',
        ).timeout(const Duration(seconds: 15), onTimeout: () {
          throw Exception('Image upload timed out. Check your internet or storage rules.');
        });
        print('Image uploaded: $avatarUrl');
      }
      
      // 2. Update Firestore
      print('Updating Firestore...');
      final updates = {
        'fullName': _nameController.text.trim(),
        'bio': _bioController.text.trim(),
        'phone': _completePhoneNumber,
        'avatarUrl': avatarUrl,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.id)
          .update(updates)
          .timeout(const Duration(seconds: 10));
      print('Firestore updated.');
      
      // 3. Refresh Local State
      await ref.read(firebaseAuthNotifierProvider.notifier).checkAuthStatus(); // Refresh provider
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Profile updated successfully!')),
        );
        Navigator.of(context).pop(); // Explicit pop
      }
    } catch (e) {
      print('Error updating profile: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(firebaseAuthNotifierProvider);
    
    if (authState is! Authenticated) {
      return const Scaffold(body: Center(child: Text('Not authenticated')));
    }
    
    final user = authState.user;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          if (_isLoading)
            const Center(child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 16.0),
              child: SizedBox(width: 20, height: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2)),
            ))
          else
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: _saveProfile,
            ),
        ],
      ),
      body: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar Picker
                    GestureDetector(
                      onTap: _isLoading ? null : _pickImage,
                      child: Stack(
                        alignment: Alignment.bottomRight,
                        children: [
                          CircleAvatar(
                            radius: 60,
                            backgroundColor: Colors.grey[200],
                            backgroundImage: _newImageBytes != null
                                ? MemoryImage(_newImageBytes!)
                                : (user.avatarUrl != null 
                                    ? NetworkImage(user.avatarUrl!) as ImageProvider
                                    : null),
                            child: (_newImageBytes == null && user.avatarUrl == null)
                                ? Text(user.fullName[0].toUpperCase(), style: const TextStyle(fontSize: 40))
                                : null,
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: const BoxDecoration(
                              color: Colors.blue,
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    
                    TextFormField(
                      controller: _nameController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Full Name',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.person),
                      ),
                      validator: (val) => val == null || val.isEmpty ? 'Name required' : null,
                    ),
                    const SizedBox(height: 16),
                    
                    IntlPhoneField(
                      controller: _phoneController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Phone',
                        border: OutlineInputBorder(),
                      ),
                      initialCountryCode: 'IN', // Default
                      onChanged: (phone) {
                        _completePhoneNumber = phone.completeNumber;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    TextFormField(
                      controller: _bioController,
                      enabled: !_isLoading,
                      decoration: const InputDecoration(
                        labelText: 'Bio',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.info_outline),
                        alignLabelWithHint: true,
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}

class _ThemeOption extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ThemeOption({
    Key? key,
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withOpacity(0.6);
    
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? theme.colorScheme.primary.withOpacity(0.1) : null,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
