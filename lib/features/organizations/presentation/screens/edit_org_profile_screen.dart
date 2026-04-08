
import 'package:flutter/material.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';
import 'package:Livora/features/organizations/domain/entities/organization.dart';
import 'package:Livora/features/organizations/presentation/providers/organization_providers.dart';
import 'package:Livora/core/theme/color_palette.dart';
import 'package:Livora/core/widgets/custom_text_field.dart';
import 'package:Livora/core/widgets/app_button.dart';
import 'package:Livora/core/animations/page_transition_wrapper.dart';
import 'package:Livora/core/widgets/custom_card.dart';

class EditOrgProfileScreen extends ConsumerStatefulWidget {
  final Organization organization;
  
  const EditOrgProfileScreen({super.key, required this.organization});

  @override
  ConsumerState<EditOrgProfileScreen> createState() => _EditOrgProfileScreenState();
}

class _EditOrgProfileScreenState extends ConsumerState<EditOrgProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _addressController;
  late TextEditingController _phoneController;
  late TextEditingController _contactPersonController;
  late TextEditingController _descriptionController;
  String _completePhoneNumber = '';
  late String _selectedCategory;
  
  final List<String> _categories = [
    'Church',
    'Worship',
    'Teaching',
    'Music',
    'Event',
    'Organization'
  ];
  
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final authState = ref.read(firebaseAuthNotifierProvider);
    
    // Security Guard: Check if authorized
    bool canEdit = false;
    if (authState is Authenticated) {
      if (authState.user.id == widget.organization.id || authState.user.role == 'superAdmin') {
        canEdit = true;
      }
    }

    if (!canEdit) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pop(context);
      });
      return;
    }

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
    _descriptionController = TextEditingController(text: org.description ?? '');
    _selectedCategory = _categories.contains(org.category) ? org.category : 'Church';
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    _contactPersonController.dispose();
    _descriptionController.dispose();
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
        'category': _selectedCategory,
        'contactPerson': _contactPersonController.text.trim(),
        'description': _descriptionController.text.trim().isEmpty ? null : _descriptionController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };
      
      debugPrint('DEBUG: Saving organization profile for ID: ${widget.organization.id}');
      
      await FirebaseFirestore.instance
          .collection('organizations')
          .doc(widget.organization.id)
          .set(updates, SetOptions(merge: true));
      
      // Refresh logic 
      ref.invalidate(currentOrganizationProvider);
      ref.invalidate(liveOrganizationsProvider);
      ref.invalidate(allOrganizationsProvider); // Updates Directory Screen
      ref.invalidate(organizationByIdProvider(widget.organization.id)); // Force refresh of detail screen
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Organization updated successfully!')),
        );
        Navigator.of(context).pop(); 
      }
    } catch (e) {
      debugPrint('ERROR: Failed to save organization: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Organization'),
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: PageTransitionWrapper(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSectionTitle(context, 'Basic Info'),
                CustomTextField(
                  label: 'Organization Name',
                  controller: _nameController,
                  prefixIcon: Icons.business_rounded,
                  validator: (val) => val!.isEmpty ? 'Name required' : null,
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Address',
                  controller: _addressController,
                  prefixIcon: Icons.location_on_rounded,
                  validator: (val) => val!.isEmpty ? 'Address required' : null,
                ),
                const SizedBox(height: 16),

                _buildSectionTitle(context, 'Organization Category'),
                DropdownButtonFormField<String>(
                  initialValue: _selectedCategory,
                  dropdownColor: theme.colorScheme.surfaceContainerHighest,
                  style: theme.textTheme.bodyLarge,
                  decoration: InputDecoration(
                    labelText: 'Category',
                    prefixIcon: Icon(Icons.category_rounded, color: theme.primaryColor),
                    filled: true,
                    fillColor: theme.colorScheme.surfaceContainerHighest,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  items: _categories.map((c) {
                    return DropdownMenuItem(
                      value: c,
                      child: Text(c, style: theme.textTheme.bodyMedium),
                    );
                  }).toList(),
                  onChanged: (v) => setState(() => _selectedCategory = v!),
                ),
                const SizedBox(height: 24),
                
                _buildSectionTitle(context, 'Contact Details'),
                Container(
                   decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.transparent),
                  ),
                  child: IntlPhoneField(
                    controller: _phoneController,
                    decoration: const InputDecoration(
                      labelText: 'Phone', 
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                      counterText: '',
                    ),
                    initialCountryCode: 'IN',
                    onChanged: (phone) {
                      _completePhoneNumber = phone.completeNumber;
                    },
                    style: theme.textTheme.bodyMedium,
                    dropdownTextStyle: theme.textTheme.bodyMedium,
                  ),
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'Contact Person',
                  controller: _contactPersonController,
                  prefixIcon: Icons.person_rounded,
                  validator: (val) => val!.isEmpty ? 'Contact person required' : null,
                ),
                const SizedBox(height: 16),
                
                CustomTextField(
                  label: 'About / Description',
                  controller: _descriptionController,
                  prefixIcon: Icons.info_outline_rounded,
                  maxLines: 5,
                  hintText: 'Tell us more about your organization...',
                ),
                
                const SizedBox(height: 40),
                
                AppButton(
                  text: 'Save Changes',
                  isLoading: _isLoading,
                  onPressed: _saveProfile,
                  fullWidth: true,
                ),
                 const SizedBox(height: 20),
              ],
            ),
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
          color: Theme.of(context).primaryColor,
        ),
      ),
    );
  }
}
