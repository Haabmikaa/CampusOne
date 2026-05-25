import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// Hero banner for announcement / event detail and list cards.
class AnnouncementHeroImage extends StatelessWidget {
  const AnnouncementHeroImage({
    super.key,
    required this.imageUrl,
    this.height = 220,
    this.borderRadius,
  });

  final String imageUrl;
  final double height;
  final BorderRadius? borderRadius;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusLg);

    return ClipRRect(
      borderRadius: radius,
      child: SizedBox(
        width: double.infinity,
        height: height,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(
            color: AppColors.neutral100,
            child: const Center(
              child: SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          errorWidget: (_, __, ___) => Container(
            color: AppColors.neutral100,
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.broken_image_outlined, color: AppColors.neutral400, size: 40),
                SizedBox(height: 8),
                Text('Image unavailable', style: TextStyle(color: AppColors.neutral500, fontSize: 12)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Compact thumbnail used in list cards.
class AnnouncementThumbnail extends StatelessWidget {
  const AnnouncementThumbnail({super.key, required this.imageUrl, this.borderRadius});

  final String imageUrl;
  final BorderRadiusGeometry? borderRadius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: SizedBox(
        width: double.infinity,
        height: 140,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          placeholder: (_, __) => Container(color: AppColors.neutral100),
          errorWidget: (_, __, ___) => Container(
            color: AppColors.neutral100,
            child: const Icon(Icons.image_not_supported_outlined, color: AppColors.neutral400),
          ),
        ),
      ),
    );
  }
}
