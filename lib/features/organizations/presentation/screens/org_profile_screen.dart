
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:Livora/features/organizations/presentation/providers/organization_providers.dart';
import 'package:Livora/features/organizations/domain/entities/organization.dart';
import 'package:Livora/features/auth/presentation/providers/firebase_auth_notifier.dart';
import 'package:Livora/features/auth/presentation/providers/auth_state.dart';
import 'edit_org_profile_screen.dart';
import 'package:Livora/features/profile/presentation/providers/profile_providers.dart';
import 'package:Livora/core/widgets/animated_widgets.dart';
import 'package:share_plus/share_plus.dart';
import 'package:flutter/foundation.dart'; // for kIsWeb
import 'package:flutter/services.dart'; // for Clipboard
import 'package:Livora/core/theme/color_palette.dart';
import 'package:Livora/core/widgets/app_button.dart';
import 'package:Livora/core/widgets/custom_card.dart';
import 'package:Livora/features/live/presentation/screens/organization_live_management_screen.dart';

class OrgProfileScreen extends ConsumerStatefulWidget {
  final Organization organization;

  const OrgProfileScreen({super.key, required this.organization});

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
      final freshOrg = await ref.read(organizationRepositoryProvider).getOrganizationById(_organization.id);
      
      if (freshOrg != null && mounted) {
        setState(() {
          _organization = freshOrg;
        });
        
        final auth = ref.read(firebaseAuthNotifierProvider);
        if (auth is Authenticated && auth.user.id == _organization.id) {
           ref.invalidate(currentOrganizationProvider); 
           ref.invalidate(liveOrganizationsProvider);
        }
      }
    } catch (e) {
      debugPrint('Failed to refresh organization: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(firebaseAuthNotifierProvider);
    bool canEdit = false;

    if (authState is Authenticated) {
      final isOwner = authState.user.id == _organization.id;
      final isAdmin = authState.user.role == 'superAdmin';
      canEdit = isOwner || isAdmin;
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // Glass App Bar with Cover
          SliverAppBar(
            expandedHeight: 220.0,
            floating: false,
            pinned: true,
            backgroundColor: theme.scaffoldBackgroundColor.withOpacity(0.9),
            iconTheme: IconThemeData(color: theme.iconTheme.color),
            actions: [
              if (canEdit)
                Container(
                  margin: const EdgeInsets.only(right: 16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surface.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.edit_rounded, size: 20),
                    onPressed: () async {
                      await Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => EditOrgProfileScreen(organization: _organization),
                        ),
                      );
                      await _refreshOrganization();
                    },
                  ),
                ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: EdgeInsets.zero,
              centerTitle: true,
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF000000), Color(0xFF0a0a0a)], 
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: const Center(
                      child: Icon(Icons.business_rounded, size: 80, color: Colors.white12),
                    ),
                  ),
                  // Gradient Overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.transparent,
                          theme.scaffoldBackgroundColor.withOpacity(0.5),
                          theme.scaffoldBackgroundColor,
                        ],
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: const [0.4, 0.8, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Logo & Name Row (Negative margin to overlap cover if desired, but here simpler)
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: FadeInUp(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          // Logo
                          Hero(
                            tag: 'org_logo_${_organization.id}',
                            child: Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface,
                                shape: BoxShape.circle,
                                border: Border.all(color: theme.scaffoldBackgroundColor, width: 4),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2), 
                                    blurRadius: 15, 
                                    offset: const Offset(0, 8)
                                  ),
                                ],
                                image: _organization.logoUrl != null
                                    ? DecorationImage(
                                        image: NetworkImage(_organization.logoUrl!),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                              child: _organization.logoUrl == null
                                  ? Center(
                                      child: Text(
                                        _organization.name.substring(0, 1).toUpperCase(), 
                                        style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)
                                      )
                                    )
                                  : null,
                            ),
                          ),
                          const SizedBox(width: 16),
                          // Name & Followers
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _organization.name,
                                  style: theme.textTheme.displaySmall?.copyWith(
                                    fontWeight: FontWeight.w900,
                                    color: ColorPalette.pureWhite,
                                    height: 1.1,
                                    letterSpacing: -1.0,
                                  ),
                                  softWrap: true,
                                ),
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: ColorPalette.livoraRed.withOpacity(0.15),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: ColorPalette.livoraRed.withOpacity(0.3), width: 1),
                                      ),
                                      child: Text(
                                        _organization.category,
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: ColorPalette.livoraRed,
                                          fontWeight: FontWeight.bold,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: ColorPalette.darkSurfaceVariant,
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(color: ColorPalette.borderSubtle, width: 1),
                                      ),
                                      child: Text(
                                        '${_organization.subscribers.length} followers',
                                        style: theme.textTheme.bodySmall?.copyWith(
                                          color: ColorPalette.softGrey,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // Follow Button (Full width or prominent)
                  FadeInUp(
                    delay: const Duration(milliseconds: 100),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: Consumer(
                        builder: (context, ref, child) {
                          final authState = ref.watch(firebaseAuthNotifierProvider);
                          if (authState is! Authenticated) return const SizedBox.shrink();
                          
                          final isFollowing = _organization.subscribers.contains(authState.user.id);
                          
                          return AppButton(
                            text: isFollowing ? 'Following' : 'Follow',
                            type: isFollowing ? AppButtonType.secondary : AppButtonType.primary,
                            icon: isFollowing ? Icons.check : Icons.add,
                            fullWidth: true,
                            onPressed: () async {
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
                                        const SnackBar(content: Text('You can only follow up to 10 organizations.'), backgroundColor: Colors.red),
                                      );
                                    }
                                    return;
                                  }
                                  await repo.addFavoriteOrganization(userId, orgId);
                                }
                                await _refreshOrganization();
                                await ref.read(firebaseAuthNotifierProvider.notifier).refreshUser();
                              } catch (e) {
                                if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
                              }
                            },
                          );
                        },
                      ),
                    ),
                  ),
                  
                  // Live Management Button for Owners
                  if (canEdit)
                    FadeInUp(
                      delay: const Duration(milliseconds: 150),
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: AppButton(
                          text: 'Manage Live Streams',
                          type: AppButtonType.secondary,
                          icon: Icons.settings_remote_rounded,
                          fullWidth: true,
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => OrganizationLiveManagementScreen(organizationId: _organization.id),
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 24),

                  // Actions Grid
                  FadeInUp(
                    delay: const Duration(milliseconds: 300),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildActionCircle(context, Icons.call_rounded, 'Call', () => _launchURL(context, 'tel:${_organization.phone}')),
                        _buildActionCircle(context, Icons.email_rounded, 'Email', () => _launchURL(context, 'mailto:${_organization.email}')),
                        _buildActionCircle(context, Icons.share_rounded, 'Share', () async {
                              final shareText = 'Check out ${_organization.name} on Livora! https://livora.app/organizations/${_organization.id}';
                              await Share.share(shareText);
                        }),
                        _buildActionCircle(context, Icons.map_rounded, 'Map', () {}), // Placeholder
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  Divider(color: theme.dividerColor.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  
                  // About Section
                  FadeInUp(
                    delay: const Duration(milliseconds: 400),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('About', style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        if (_organization.description != null && _organization.description!.isNotEmpty) ...[
                          Text(
                            _organization.description!,
                            style: theme.textTheme.bodyMedium?.copyWith(height: 1.5),
                          ),
                          const SizedBox(height: 16),
                        ],
                        CustomCard(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            children: [
                              _buildInfoRow(context, Icons.location_on_outlined, _organization.address),
                              Divider(height: 24, color: theme.dividerColor.withOpacity(0.5)),
                              _buildInfoRow(context, Icons.person_outline_rounded, 'Contact: ${_organization.contactPerson}'),
                              Divider(height: 24, color: theme.dividerColor.withOpacity(0.5)),
                              _buildInfoRow(context, Icons.phone_outlined, _organization.phone),
                              Divider(height: 24, color: theme.dividerColor.withOpacity(0.5)),
                              _buildInfoRow(context, Icons.email_outlined, _organization.email),
                            ],
                          ),
                        ),
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

  Widget _buildActionCircle(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    final theme = Theme.of(context);
    return AnimatedScaleButton(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2)),
              ],
              border: Border.all(color: theme.dividerColor.withOpacity(0.5)),
            ),
            child: Icon(icon, color: theme.primaryColor, size: 22),
          ),
          const SizedBox(height: 8),
          Text(label, style: theme.textTheme.bodySmall?.copyWith(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildInfoRow(BuildContext context, IconData icon, String text) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Theme.of(context).colorScheme.primary.withOpacity(0.7)),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: Theme.of(context).textTheme.bodyMedium)),
      ],
    );
  }
}
