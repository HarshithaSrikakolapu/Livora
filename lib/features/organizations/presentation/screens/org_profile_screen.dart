import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../providers/organization_providers.dart';
import '../../domain/entities/organization.dart';
import '../../../auth/presentation/providers/firebase_auth_notifier.dart';
import '../../../auth/presentation/providers/auth_state.dart';
import 'edit_org_profile_screen.dart';
import '../../../profile/presentation/providers/profile_providers.dart';
import '../../../../core/widgets/animated_widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/services.dart'; // for Clipboard
import '../../../../core/theme/color_palette.dart';

class OrgProfileScreen extends ConsumerStatefulWidget {
  final Organization organization;

  const OrgProfileScreen({Key? key, required this.organization}) : super(key: key);

  @override
  ConsumerState<OrgProfileScreen> createState() => _OrgProfileScreenState();
}

class _OrgProfileScreenState extends ConsumerState<OrgProfileScreen> {
  late Organization _organization;

  @override
  void initState() {
    super.initState();
    _organization = widget.organization;
  }

  Future<void> _launchURL(BuildContext context, String urlString) async {
    final Uri url = Uri.parse(urlString);
    
    // Web-specific handling for mailto -> Gmail
    if (kIsWeb && urlString.startsWith('mailto:')) {
       final email = urlString.replaceFirst('mailto:', '');
       final gmailUrl = Uri.parse('https://mail.google.com/mail/?view=cm&fs=1&to=$email');
       try {
         if (await launchUrl(gmailUrl, mode: LaunchMode.externalApplication)) {
            return;
         }
       } catch (_) {
         // Fallback to default handler
       }
    }

    try {
      if (!await launchUrl(url, mode: LaunchMode.externalApplication)) { 
         // Try platform default if external fails
         if (!await launchUrl(url, mode: LaunchMode.platformDefault)) {
            throw 'Could not launch $urlString';
         }
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not launch action')),
        );
       }
    }
  }

  // Refetches data to ensure UI is consistent
  Future<void> _refreshOrganization() async {
    try {
      // Invalidate to force fresh fetch if using any caching provider (future proofing)
      // ref.invalidate(organizationProvider(_organization.id)); 
      
      final freshOrg = await ref.read(organizationRepositoryProvider).getOrganizationById(_organization.id);
      
      if (freshOrg != null && mounted) {
        setState(() {
          _organization = freshOrg;
        });
        
        // Also invalidate the global provider to keep other screens in sync
        // (Like MyOrganizationScreen or Lists)
        final auth = ref.read(firebaseAuthNotifierProvider);
        if (auth is Authenticated && auth.user.id == _organization.id) {
           ref.invalidate(currentOrganizationProvider); 
           // Also invalidate the live list so Home Screen updates
           ref.invalidate(liveOrganizationsProvider);
        }
      }
    } catch (e) {
      debugPrint('Failed to refresh organization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(firebaseAuthNotifierProvider);
    bool canEdit = false;

    if (authState is Authenticated) {
      if (authState.user.id == _organization.id || authState.user.role == 'admin') {
        canEdit = true;
      }
    }

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            actions: [
              if (canEdit)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () async {
                    await Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => EditOrgProfileScreen(organization: _organization),
                      ),
                    );
                    // Refresh local data immediately
                    await _refreshOrganization();
                  },
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                _organization.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [Shadow(color: Colors.black45, blurRadius: 4)],
                ),
              ),
              background: Container(
                color: Colors.blue[800],
                child: const Center(
                  child: Icon(Icons.business, size: 80, color: Colors.white30),
                ),
              ),
            ),
          ),
          
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Info
                    FadeInUp(
                      delay: const Duration(milliseconds: 100),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                            child: Text(
                              _organization.name.substring(0, 1).toUpperCase(),
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.onPrimaryContainer),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _organization.name,
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_organization.subscribers.length} followers',
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                          Consumer(
                            builder: (context, ref, child) {
                              final authState = ref.watch(firebaseAuthNotifierProvider);
                              if (authState is! Authenticated) return const SizedBox.shrink();
                              
                              final isFollowing = _organization.subscribers.contains(authState.user.id);
                              
                              return AnimatedScaleButton(
                                onTap: () async {
                                  final repo = ref.read(profileRepositoryProvider);
                                  final userId = authState.user.id;
                                  final orgId = _organization.id;
                                  
                                  try {
                                    if (isFollowing) {
                                      await repo.removeFavoriteOrganization(userId, orgId);
                                    } else {
                                      if (authState.user.favoriteOrgs.length >= 10) {
                                        if (context.mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                            const SnackBar(
                                              content: Text('You can only follow up to 10 organizations.'),
                                              backgroundColor: Colors.red,
                                            ),
                                          );
                                        }
                                        return;
                                      }
                                      await repo.addFavoriteOrganization(userId, orgId);
                                    }
                                    await _refreshOrganization();
                                    
                                    await ref.read(firebaseAuthNotifierProvider.notifier).refreshUser();
                                  } catch (e) {
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(content: Text('Error: $e')),
                                      );
                                    }
                                  }
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: isFollowing ? Theme.of(context).disabledColor : Theme.of(context).colorScheme.primary,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    isFollowing ? 'Following' : 'Follow',
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    if (_organization.isLive) ...[
                      FadeInUp(
                        delay: const Duration(milliseconds: 200),
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [ColorPalette.primary, ColorPalette.secondary],
                            ),
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                                BoxShadow(color: ColorPalette.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                            ],
                          ),
                          child: Column(
                            children: [
                               const Row(
                                 mainAxisAlignment: MainAxisAlignment.center,
                                 children: [
                                   PulsingDot(color: Colors.white, size: 12),
                                   SizedBox(width: 8),
                                   Text(
                                     'LIVE NOW',
                                     style: TextStyle(
                                       color: Colors.white, 
                                       fontWeight: FontWeight.bold,
                                       fontSize: 18,
                                     ),
                                   ),
                                 ],
                               ),
                              const SizedBox(height: 16),
                              if (_organization.youtubeLiveUrl != null && _organization.youtubeLiveUrl!.isNotEmpty)
                                AnimatedScaleButton(
                                  onTap: () => _launchURL(context, _organization.youtubeLiveUrl!),
                                  child: Container(
                                    width: double.infinity,
                                    padding: const EdgeInsets.symmetric(vertical: 12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        const Icon(Icons.play_arrow, color: Colors.red),
                                        const SizedBox(width: 8),
                                        Text('Watch on YouTube', style: TextStyle(color: Colors.red[700], fontWeight: FontWeight.bold)),
                                      ],
                                    ),
                                  ),
                                ),
                              if (_organization.facebookLiveUrl != null && _organization.facebookLiveUrl!.isNotEmpty) ...[
                                 const SizedBox(height: 8),
                                 AnimatedScaleButton(
                                   onTap: () => _launchURL(context, _organization.facebookLiveUrl!),
                                   child: Container(
                                     width: double.infinity,
                                     padding: const EdgeInsets.symmetric(vertical: 12),
                                     decoration: BoxDecoration(
                                       color: Colors.white,
                                       borderRadius: BorderRadius.circular(8),
                                     ),
                                     child: Row(
                                       mainAxisAlignment: MainAxisAlignment.center,
                                       children: [
                                         const Icon(Icons.facebook, color: Color(0xFF1877F2)), // FB Blue
                                         const SizedBox(width: 8),
                                         const Text('Watch on Facebook', style: TextStyle(color: Color(0xFF1877F2), fontWeight: FontWeight.bold)),
                                       ],
                                     ),
                                   ),
                                 ),
                              ]
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],

                    // Actions
                    FadeInUp(
                      delay: const Duration(milliseconds: 300),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          _buildActionButton(
                            context, 
                            Icons.call, 
                            'Call',
                            () => _launchURL(context, 'tel:${_organization.phone}'),
                          ),
                          _buildActionButton(
                            context, 
                            Icons.email, 
                            'Email',
                            () => _launchURL(context, 'mailto:${_organization.email}'),
                          ),
                          _buildActionButton(
                            context, 
                            Icons.share, 
                            'Share',
                            () async {
                              final shareText = 'Check out ${_organization.name} on Livora! https://livora.app/organizations/${_organization.id}';
                              try {
                                // Using share_plus
                                await Share.share(shareText);
                              } catch (e) {
                                // Fallback for unsupported platforms (like some desktops/browsers)
                                await Clipboard.setData(ClipboardData(text: shareText));
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Link copied to clipboard!')),
                                  );
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 24),
                    const Divider(),
                    const SizedBox(height: 16),
                    
                    // About
                    FadeInUp(
                      delay: const Duration(milliseconds: 400),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'About',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          _buildInfoRow(context, Icons.location_on, _organization.address),
                          const SizedBox(height: 8),
                          _buildInfoRow(context, Icons.person, 'Contact: ${_organization.contactPerson}'),
                          const SizedBox(height: 8),
                          _buildInfoRow(context, Icons.phone, _organization.phone),
                          const SizedBox(height: 8),
                          _buildInfoRow(context, Icons.email, _organization.email),
                        ],
                      ),
                    ),
                    
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
          ],
        ),
      );
  }

  Widget _buildActionButton(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return AnimatedScaleButton(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Theme.of(context).colorScheme.surfaceVariant,
            ),
            child: Icon(icon, color: Theme.of(context).colorScheme.primary),
          ),
          const SizedBox(height: 4),
          Text(label, style: const TextStyle(fontSize: 12)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: Theme.of(context).colorScheme.secondary),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}    
