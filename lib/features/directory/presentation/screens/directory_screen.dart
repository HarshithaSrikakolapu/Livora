
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:ui';
import 'package:Livora/features/directory/presentation/providers/directory_providers.dart';
import 'package:Livora/features/directory/presentation/widgets/org_list_tile.dart';
import 'package:Livora/features/directory/presentation/widgets/search_bar_widget.dart';
import 'package:Livora/features/organizations/presentation/screens/org_profile_screen.dart';
import 'package:Livora/core/theme/color_palette.dart';
import 'package:Livora/core/widgets/animated_widgets.dart';

class DirectoryScreen extends ConsumerWidget {
  const DirectoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredOrgsAsync = ref.watch(filteredOrganizationsProvider);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: Colors.transparent,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: theme.colorScheme.surface.withOpacity(0.8)),
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(
          'Directory',
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(height: 100), // App bar space
          
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: const FadeInUp(child: SearchBarWidget()),
          ),
          
          const SizedBox(height: 16),

          // Category Filter Header
          FadeInUp(
            delay: const Duration(milliseconds: 100),
            child: SizedBox(
              height: 40,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  'All',
                  'Church',
                  'Worship',
                  'Teaching',
                  'Music',
                  'Event',
                  'Organization'
                ].map((category) {
                  final selectedCategory = ref.watch(selectedCategoryProvider);
                  final isSelected = selectedCategory == category;
                  
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(category),
                      selected: isSelected,
                      onSelected: (selected) {
                        if (selected) {
                          ref.read(selectedCategoryProvider.notifier).state = category;
                        }
                      },
                      backgroundColor: Colors.white.withOpacity(0.05),
                      selectedColor: ColorPalette.livoraRed.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: isSelected ? ColorPalette.livoraRed : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 13,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(
                          color: isSelected ? ColorPalette.livoraRed.withOpacity(0.5) : Colors.white10,
                          width: 1,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          
          const SizedBox(height: 16),
          
          Expanded(
            child: filteredOrgsAsync.when(
              data: (orgs) {
                if (orgs.isEmpty) {
                  return Center(
                    child: FadeInUp(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.search_off_rounded, size: 80, color: theme.disabledColor),
                          const SizedBox(height: 16),
                          Text(
                            'No organizations found',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.disabledColor,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }
                
                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 120), // Bottom padding for nav
                  itemCount: orgs.length,
                  separatorBuilder: (ctx, i) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final org = orgs[index];
                    return FadeInUp(
                      delay: Duration(milliseconds: 50 * (index % 6)),
                      child: OrgListTile(
                        organization: org,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (context) => OrgProfileScreen(organization: org),
                            ),
                          );
                        },
                      ),
                    );
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            ),
          ),
        ],
      ),
    );
  }
}
