
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Livora/core/theme/color_palette.dart';
import 'package:Livora/features/organizations/presentation/providers/organization_providers.dart';
import 'package:Livora/features/organizations/presentation/screens/org_profile_screen.dart';
import 'package:Livora/core/widgets/animated_widgets.dart';

class LiveWallWidget extends ConsumerWidget {
  const LiveWallWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveOrgsAsync = ref.watch(liveOrganizationsProvider);
    final theme = Theme.of(context);

    // Filter logic can also be in provider, assuming provider returns only live orgs
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 8.0),
          child: Row(
            children: [
               const PulsingDot(color: Colors.white, size: 8),
              const SizedBox(width: 8),
              Text(
                'Live Now',
                style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      letterSpacing: 0.5,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 130, // Adjusted height
          child: liveOrgsAsync.when(
            data: (orgs) {
              if (orgs.isEmpty) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'No live events right now',
                      style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.disabledColor,
                          ),
                    ),
                  ),
                );
              }
              return StaggeredList(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: orgs.length,
                itemBuilder: (context, index) {
                  final org = orgs[index];
                  return AnimatedScaleButton(
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => OrgProfileScreen(organization: org),
                        ),
                      );
                    },
                    child: Container(
                      width: 85,
                      margin: const EdgeInsets.symmetric(horizontal: 6),
                      child: Column(
                        children: [
                          Stack(
                            alignment: Alignment.center,
                            children: [
                              // Border Ring
                              Container(
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: ColorPalette.livoraRed.withOpacity(0.5), 
                                    width: 2.0
                                  ),
                                ),
                              ),
                              // Avatar
                              Container(
                                width: 62,
                                height: 62,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: theme.disabledColor.withOpacity(0.1),
                                  image: org.logoUrl != null 
                                      ? DecorationImage(
                                          image: NetworkImage(org.logoUrl!),
                                          fit: BoxFit.cover,
                                        )
                                      : null,
                                ),
                                child: org.logoUrl == null
                                    ? Center(
                                        child: Text(
                                          org.name.substring(0, 1).toUpperCase(),
                                          style: TextStyle(
                                            fontSize: 22, 
                                            fontWeight: FontWeight.bold,
                                            color: theme.primaryColor,
                                          ),
                                        ),
                                      )
                                    : null,
                              ),
                              // Live Label
                              Positioned(
                                bottom: -2,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(color: ColorPalette.livoraRed, width: 1.5),
                                    boxShadow: [
                                       BoxShadow(color: ColorPalette.livoraRed.withOpacity(0.4), blurRadius: 4),
                                    ],
                                  ),
                                  child: const Text(
                                    'LIVE',
                                    style: TextStyle(
                                      color: Colors.white, 
                                      fontSize: 9, 
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: 0.5,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            org.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelMedium?.copyWith(fontWeight: FontWeight.w600),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (err, stack) => Center(child: Text('Error')),
          ),
        ),
      ],
    );
  }
}
