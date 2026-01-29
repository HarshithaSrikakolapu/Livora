import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pending_approvals_screen.dart';
import 'manage_users_screen.dart';
import 'manage_organizations_screen.dart';
import 'admin_settings_screen.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../../core/widgets/custom_card.dart';
import '../../../../core/theme/color_palette.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Admin Dashboard'),
      ),
      body: GridView.count(
        crossAxisCount: 2,
        padding: const EdgeInsets.all(16),
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
        children: [
          FadeInUp(
            delay: const Duration(milliseconds: 0),
            child: _buildDashboardCard(
              context,
              icon: Icons.people_outline,
              title: 'Pending Approvals',
              color: const Color(0xFFF59E0B), // Amber
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const PendingApprovalsScreen()),
                );
              },
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: _buildDashboardCard(
              context,
              icon: Icons.business,
              title: 'Manage Organizations',
              color: const Color(0xFF3B82F6), // Blue
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ManageOrganizationsScreen()),
                );
              },
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 200),
            child: _buildDashboardCard(
              context,
              icon: Icons.person,
              title: 'Manage Users',
              color: const Color(0xFF10B981), // Emerald
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const ManageUsersScreen()),
                );
              },
            ),
          ),
          FadeInUp(
            delay: const Duration(milliseconds: 300),
            child: _buildDashboardCard(
              context,
              icon: Icons.settings,
              title: 'Settings',
              color: ColorPalette.primary.withOpacity(0.7),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => const AdminSettingsScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDashboardCard(BuildContext context, {required IconData icon, required String title, required Color color, required VoidCallback onTap}) {
    return AnimatedScaleButton(
      onTap: onTap,
      child: CustomCard(
        padding: EdgeInsets.zero,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withOpacity(0.15),
                ),
                child: Icon(icon, size: 32, color: color),
              ),
              const SizedBox(height: 16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
