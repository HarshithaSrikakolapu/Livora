
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:Livora/core/theme/theme_provider.dart';
import 'package:Livora/core/theme/color_palette.dart';
import 'package:Livora/core/widgets/custom_card.dart';
import 'edit_profile_screen.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final themeMode = ref.watch(themeModeProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          _buildSectionHeader(context, 'Appearance'),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text('Dark Mode', style: TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: const Text('Enable dark theme'),
                  value: isDark,
                  activeThumbColor: theme.primaryColor,
                  onChanged: (value) {
                    ref.read(themeModeProvider.notifier).toggleTheme();
                  },
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isDark ? Colors.purple.withOpacity(0.1) : Colors.orange.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                      color: isDark ? Colors.purple : Colors.orange,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          _buildSectionHeader(context, 'Account'),
          CustomCard(
            padding: EdgeInsets.zero,
            child: Column(
              children: [
                _buildSettingsTile(
                  context,
                  icon: Icons.person_rounded,
                  title: 'Edit Profile',
                  subtitle: 'Update name, bio, and photo',
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(builder: (context) => const EditProfileScreen()),
                    );
                  },
                ),
                Divider(height: 1, indent: 56, color: theme.dividerColor.withOpacity(0.5)),
                _buildSettingsTile(
                  context,
                  icon: Icons.info_outline_rounded,
                  title: 'About App',
                  subtitle: 'Version 1.0.0',
                  onTap: () {}, // TODO: Show About Dialog
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
           _buildSectionHeader(context, 'Support'),
           CustomCard(
             padding: EdgeInsets.zero,
             child: Column(
               children: [
                 _buildSettingsTile(
                   context,
                   icon: Icons.help_outline_rounded,
                   title: 'Help Center',
                   onTap: () {},
                 ),
                 Divider(height: 1, indent: 56, color: theme.dividerColor.withOpacity(0.5)),
                  _buildSettingsTile(
                   context,
                   icon: Icons.privacy_tip_outlined,
                   title: 'Privacy Policy',
                   onTap: () {},
                 ),
               ],
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall?.copyWith(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).primaryColor,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSettingsTile(BuildContext context, {
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    Color? iconColor,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          shape: BoxShape.circle,
        ),
        child: Icon(icon, size: 20, color: iconColor ?? theme.iconTheme.color),
      ),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: subtitle != null ? Text(subtitle, style: theme.textTheme.bodySmall) : null,
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }
}
