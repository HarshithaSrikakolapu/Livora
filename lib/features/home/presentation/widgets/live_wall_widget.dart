import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../organizations/presentation/providers/organization_providers.dart';
import '../../../organizations/presentation/screens/org_profile_screen.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../../core/theme/color_palette.dart';

class LiveWallWidget extends ConsumerWidget {
  const LiveWallWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final liveOrgsAsync = ref.watch(liveOrganizationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Row(
            children: [
              const PulsingDot(color: ColorPalette.primary, size: 10),
              const SizedBox(width: 8),
              Text(
                'Live Now',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: 140,
          child: liveOrgsAsync.when(
            data: (orgs) {
              if (orgs.isEmpty) {
                return Center(
                  child: Text(
                    'No live events right now',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                  ),
                );
              }
              return StaggeredList(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 12),
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
                      width: 100,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      child: Column(
                        children: [
                          PulsingBadge(
                            glowColor: ColorPalette.deepRed,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(color: ColorPalette.primary, width: 2),
                              ),
                              child: CircleAvatar(
                                radius: 35,
                                backgroundColor: const Color(0xFF2C2F36), // Darker grey
                                child: Text(
                                  org.name.isNotEmpty ? org.name.substring(0, 1).toUpperCase() : '?',
                                  style: const TextStyle(
                                    fontSize: 24, 
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            org.name,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: Colors.white70),
                            textAlign: TextAlign.center,
                          ),
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: ColorPalette.deepRed, // Using a consistent "Live" color     
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: const Text(
                              'LIVE',
                              style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
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
    );
  }
}
