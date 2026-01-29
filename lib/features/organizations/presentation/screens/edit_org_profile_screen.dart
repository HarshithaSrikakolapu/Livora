import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../auth/presentation/providers/firebase_auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import '../../domain/entities/organization.dart';
import '../providers/organization_providers.dart';

class EditOrgProfileScreen extends ConsumerStatefulWidget {
  final Organization organization;
  
  const EditOrgProfileScreen({Key? key, required this.organization}) : super(key: key);

  @override
  ConsumerState<EditOrgProfileScreen> createState() => _EditOrgProfileScreenState();
}

class _EditOrgProfileScreenState extends ConsumerState<EditOrgProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _contactPersonController;
  late TextEditingController _youtubeController;
  late TextEditingController _facebookController;
  String _completePhoneNumber = '';
  
  bool _isLoading = false;
  bool _isLive = false;

  @override
  void initState() {
    super.initState();
    final org = widget.organization;
    _nameController = TextEditingController(text: org.name);
    _addressController = TextEditingController(text: org.address);
    
    // Fix: IntPhoneField adds country code automatically. Strip it to avoid duplication.
    String phoneText = org.phone;
    if (phoneText.startsWith('+91')) { // Assuming default is IN
      phoneText = phoneText.substring(3).trim();
    }
    _phoneController = TextEditingController(text: phoneText);
    _completePhoneNumber = org.phone;
    _contactPersonController = TextEditingController(text: org.contactPerson);
    _youtubeController = TextEditingController(text: org.youtubeLiveUrl ?? '');
    _facebookController = TextEditingController(text: org.facebookLiveUrl ?? '');
    _isLive = org.isLive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _contactPersonController.dispose();
    _youtubeController.dispose();
    _facebookController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    
    try {
      final updates = {
        'name': _nameController.text.trim(),
        'address': _addressController.text.trim(),
        'phone': _completePhoneNumber,
        'contactPerson': _contactPersonController.text.trim(),
        'youtubeLiveUrl': _youtubeController.text.trim().isEmpty ? null : _youtubeController.text.trim(),
        'facebookLiveUrl': _facebookController.text.trim().isEmpty ? null : _facebookController.text.trim(),
        'isLive': _isLive,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      await FirebaseFirestore.instance
          .collection('organizations')
          .doc(widget.organization.id)
          .set(updates, SetOptions(merge: true));
      
      // Refresh logic 
      ref.invalidate(currentOrganizationProvider);
      ref.invalidate(liveOrganizationsProvider);
      ref.invalidate(allOrganizationsProvider); // Updates Directory Screen
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organization updated successfully!')),
        );
        context.pop(); 
      }
    } catch (e) {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Organization'),
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
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSectionTitle(context, 'Basic Info'),
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: 'Organization Name', prefixIcon: Icon(Icons.business)),
                validator: (val) => val!.isEmpty ? 'Name required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on)),
                validator: (val) => val!.isEmpty ? 'Address required' : null,
              ),
              const SizedBox(height: 12),
              IntlPhoneField(
                controller: _phoneController,
                decoration: const InputDecoration(labelText: 'Phone', border: OutlineInputBorder()),
                initialCountryCode: 'IN',
                onChanged: (phone) {
                  _completePhoneNumber = phone.completeNumber;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _contactPersonController,
                decoration: const InputDecoration(labelText: 'Contact Person', prefixIcon: Icon(Icons.person)),
                validator: (val) => val!.isEmpty ? 'Contact person required' : null,
              ),
              
              const SizedBox(height: 24),
              _buildSectionTitle(context, 'Live Streaming'),
              
              SwitchListTile(
                title: const Text('Currently Live'),
                subtitle: const Text('Toggle this when you start/stop streaming'),
                value: _isLive,
                onChanged: (val) => setState(() => _isLive = val),
                activeColor: Colors.red,
              ),
              
              const SizedBox(height: 12),
              TextFormField(
                controller: _youtubeController,
                decoration: const InputDecoration(
                  labelText: 'YouTube Live URL', 
                  prefixIcon: Icon(Icons.video_library),
                  hintText: 'https://youtube.com/watch?v=...'
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return null;
                  final youtubeRegex = RegExp(r'^(https?:\/\/)?(www\.)?(youtube\.com|youtu\.?be)\/.+$');
                  if (!youtubeRegex.hasMatch(val)) {
                    return 'Enter a valid YouTube URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _facebookController,
                decoration: const InputDecoration(
                  labelText: 'Facebook Live URL', 
                  prefixIcon: Icon(Icons.facebook),
                  hintText: 'https://facebook.com/...'
                ),
                validator: (val) {
                  if (val == null || val.isEmpty) return null;
                  final facebookRegex = RegExp(r'^(https?:\/\/)?(www\.)?(facebook\.com|fb\.watch)\/.+$');
                  if (!facebookRegex.hasMatch(val)) {
                    return 'Enter a valid Facebook URL';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0, top: 8.0),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontWeight: FontWeight.bold,
          color: Colors.blue[800],
        ),
      ),
    );
  }
}
