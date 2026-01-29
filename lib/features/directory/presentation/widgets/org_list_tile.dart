import 'package:flutter/material.dart';
import '../../../../features/organizations/domain/entities/organization.dart';
import '../../../../core/widgets/animated_widgets.dart';
import '../../../../core/theme/color_palette.dart';

class OrgListTile extends StatelessWidget {
  final Organization organization;
  final VoidCallback? onTap;

  const OrgListTile({
    Key? key,
    required this.organization,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AnimatedScaleButton(
      onTap: onTap ?? () {},
      child: Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        elevation: 1, // Theme handles shadow, keeping minimal elevation here
        child: ListTile(
          contentPadding: const EdgeInsets.all(12),
          leading: CircleAvatar(
            radius: 25,
            backgroundColor: Colors.blue[100],
            backgroundImage: organization.logoUrl != null ? NetworkImage(organization.logoUrl!) : null,
            child: organization.logoUrl == null
                ? Text(
                    organization.name.substring(0, 1).toUpperCase(),
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  )
                : null,
          ),
          title: Text(
            organization.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                organization.category,
                style: TextStyle(color: Colors.grey[800], fontSize: 13, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  const Icon(Icons.location_on, size: 14, color: Colors.grey),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      organization.address,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ),
                ],
              ),
              if (organization.isLive)
                Padding(
                  padding: const EdgeInsets.only(top: 6.0),
                  child: PulsingBadge(
                    glowColor: ColorPalette.deepRed,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Theme.of(context).brightness == Brightness.light ? ColorPalette.primary : ColorPalette.deepRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: const Text(
                        'LIVE NOW',
                        style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
