
import 'package:flutter/material.dart';
import 'package:Livora/features/organizations/domain/entities/organization.dart';
import 'package:Livora/core/widgets/animated_widgets.dart';
import 'package:Livora/core/widgets/custom_card.dart';
import 'package:Livora/core/theme/color_palette.dart';

class OrgListTile extends StatelessWidget {
  final Organization organization;
  final VoidCallback? onTap;

  const OrgListTile({
    super.key,
    required this.organization,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return CustomCard(
      onTap: onTap,
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Logo
          Hero(
            tag: 'org_logo_${organization.id}',
            child: Container(
              width: 50,
              height: 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: theme.primaryColor.withOpacity(0.1),
                image: organization.logoUrl != null
                    ? DecorationImage(
                        image: NetworkImage(organization.logoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: organization.logoUrl == null
                  ? Center(
                      child: Text(
                        organization.name.substring(0, 1).toUpperCase(),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 20, 
                          color: theme.primaryColor
                        ),
                      ),
                    )
                  : null,
            ),
          ),
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        organization.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (organization.isLive) ...[
                      const SizedBox(width: 8),
                      PulsingBadge(
                        glowColor: Colors.white.withOpacity(0.3),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(color: ColorPalette.livoraRed, width: 1),
                            boxShadow: [
                              BoxShadow(color: ColorPalette.livoraRed.withOpacity(0.3), blurRadius: 4),
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
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  organization.category,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.primaryColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on_rounded, size: 14, color: theme.disabledColor),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        organization.address,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.disabledColor,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Optional trailing icon
          Icon(
            Icons.chevron_right_rounded,
            color: theme.disabledColor.withOpacity(0.5),
          ),
        ],
      ),
    );
  }
}
