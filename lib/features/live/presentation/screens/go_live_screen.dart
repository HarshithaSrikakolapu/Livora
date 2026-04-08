import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/core/theme/color_palette.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';
import 'package:Livora/features/live/presentation/providers/live_providers.dart';
import 'package:Livora/features/live/domain/entities/stream.dart';
import 'package:Livora/features/organizations/presentation/providers/organization_providers.dart';

class GoLiveScreen extends ConsumerStatefulWidget {
  const GoLiveScreen({super.key});

  @override
  ConsumerState<GoLiveScreen> createState() => _GoLiveScreenState();
}

class _GoLiveScreenState extends ConsumerState<GoLiveScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _urlController = TextEditingController();
  PlatformType _selectedPlatform = PlatformType.livora;
  String _selectedCategory = 'Church';
  bool _isScheduled = false;
  DateTime? _scheduledDate;
  bool _chatEnabled = true;

  @override
  void dispose() {
    _titleController.dispose();
    _urlController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Fetch category from organization profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orgAsync = ref.read(currentOrganizationProvider);
      orgAsync.whenData((org) {
        if (org != null) {
          setState(() {
            _selectedCategory = org.category;
          });
        }
      });
    });
  }

  Future<void> _handleGoLive() async {
    if (_formKey.currentState!.validate()) {
      final authState = ref.read(firebaseAuthNotifierProvider);
      if (authState is! Authenticated) return;

      final creatorId = authState.user.id;

      await ref.read(goLiveNotifierProvider.notifier).startStream(
            creatorId: creatorId,
            title: _titleController.text,
            platform: _selectedPlatform,
            url: _urlController.text,
            category: _selectedCategory,
            scheduledAt: _isScheduled ? _scheduledDate : null,
            chatEnabled: _chatEnabled,
          );

      if (mounted) {
        final state = ref.read(goLiveNotifierProvider);
        if (!state.hasError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_isScheduled ? 'Stream scheduled!' : 'You are now LIVE!'),
              backgroundColor: ColorPalette.success,
            ),
          );
          Navigator.pop(context);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final actionState = ref.watch(goLiveNotifierProvider);
    final authState = ref.watch(firebaseAuthNotifierProvider);
    final bool isOrg = authState is Authenticated && authState.user.role == 'organization';

    if (!isOrg) {
      return Scaffold(
        backgroundColor: ColorPalette.pureBlack,
        appBar: AppBar(backgroundColor: ColorPalette.darkSurface),
        body: const Center(
          child: Text(
            'Only organizations can create live streams.',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: ColorPalette.pureBlack,
      appBar: AppBar(
        title: const Text('Go Live'),
        backgroundColor: ColorPalette.darkSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Prepare your stream',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: ColorPalette.pureWhite,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 24),
              
              // Title Field
              TextFormField(
                controller: _titleController,
                style: const TextStyle(color: ColorPalette.pureWhite),
                decoration: _inputDecoration('Stream Title', Icons.title),
                validator: (v) => v!.isEmpty ? 'Enter a title' : null,
              ),
              const SizedBox(height: 16),
              
              const SizedBox(height: 16),

              // Platform Dropdown
              DropdownButtonFormField<PlatformType>(
                initialValue: _selectedPlatform,
                dropdownColor: ColorPalette.darkSurfaceVariant,
                style: const TextStyle(color: ColorPalette.pureWhite),
                decoration: _inputDecoration('Platform', Icons.cast),

                items: PlatformType.values.map((p) {
                  return DropdownMenuItem(
                    value: p,
                    child: Text(p.name.toUpperCase()),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedPlatform = v!),
              ),
              const SizedBox(height: 16),

              // URL Field
              TextFormField(
                controller: _urlController,
                style: const TextStyle(color: ColorPalette.pureWhite),
                decoration: _inputDecoration('Stream URL / Key', Icons.link),
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Enter stream URL';
                  
                  if (_selectedPlatform == PlatformType.youtube) {
                    String? id = YoutubePlayer.convertUrlToId(v);
                    
                    // Manual fallback for /live/ URLs
                    if (id == null && v.contains('/live/')) {
                      final RegExp regExp = RegExp(r'/live/([^/?#]+)');
                      final match = regExp.firstMatch(v);
                      if (match != null && match.groupCount >= 1) {
                        id = match.group(1);
                      }
                    }
                    
                    if (id == null) return 'Invalid YouTube URL';
                  }
                  
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Schedule Switch
              SwitchListTile(
                title: const Text('Schedule for later', style: TextStyle(color: ColorPalette.pureWhite)),
                value: _isScheduled,
                activeThumbColor: ColorPalette.livoraRed,
                onChanged: (v) => setState(() => _isScheduled = v),
              ),

              // Chat Switch
              SwitchListTile(
                title: const Text('Enable Live Chat', style: TextStyle(color: ColorPalette.pureWhite)),
                value: _chatEnabled,
                activeThumbColor: ColorPalette.livoraRed,
                onChanged: (v) => setState(() => _chatEnabled = v),
              ),
              
              if (_isScheduled) ...[
                const SizedBox(height: 8),
                ListTile(
                  title: Text(
                    _scheduledDate == null
                        ? 'Select Date & Time'
                        : 'Scheduled: ${_scheduledDate.toString()}',
                    style: const TextStyle(color: ColorPalette.softGrey),
                  ),
                  trailing: const Icon(Icons.calendar_today, color: ColorPalette.livoraRed),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 30)),
                    );
                    if (date != null && mounted) {
                      final time = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                      );
                      if (time != null) {
                        setState(() {
                          _scheduledDate = DateTime(
                            date.year,
                            date.month,
                            date.day,
                            time.hour,
                            time.minute,
                          );
                        });
                      }
                    }
                  },
                ),
              ],

              const SizedBox(height: 40),

              // GO LIVE Button
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorPalette.livoraRed,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: actionState.isLoading ? null : _handleGoLive,
                child: actionState.isLoading
                    ? const CircularProgressIndicator(color: ColorPalette.pureWhite)
                    : Text(
                        _isScheduled ? 'SCHEDULE STREAM' : 'GO LIVE',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: ColorPalette.pureWhite,
                        ),
                      ),
              ),
              
              if (actionState.hasError)
                Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: Text(
                    'Error: ${actionState.error}',
                    style: const TextStyle(color: ColorPalette.livoraRed),
                    textAlign: TextAlign.center,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: ColorPalette.softGrey),
      prefixIcon: Icon(icon, color: ColorPalette.livoraRed),
      filled: true,
      fillColor: ColorPalette.darkSurfaceVariant,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: ColorPalette.livoraRed, width: 1),
      ),
    );
  }
}
