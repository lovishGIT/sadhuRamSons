import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';

import '../constants/app_colors.dart';

/// Helper utility configured for ImageKit, Cloudinary, and CDNs
/// to generate bandwidth-optimized WebP images (q=60, w=500 by default).
class MediaUrlHelper {
  MediaUrlHelper._();

  /// Transforms raw image URLs to use edge-optimized transforms:
  /// - Automatic WebP conversion
  /// - Quality compression (q-60)
  /// - Scaled width (default 500px, max for mobile screens)
  static String getOptimizedImageUrl(
    String rawUrl, {
    int width = 500,
    int quality = 60,
  }) {
    if (rawUrl.isEmpty) return '';

    try {
      final uri = Uri.parse(rawUrl);

      // 1. ImageKit URL transformation
      if (rawUrl.contains('imagekit.io') || rawUrl.contains('ik.imagekit.io')) {
        final transform = 'tr=w-$width,q-$quality,f-webp';
        final separator = uri.hasQuery ? '&' : '?';
        return '$rawUrl$separator$transform';
      }

      // 2. Cloudinary URL transformation
      if (rawUrl.contains('res.cloudinary.com')) {
        // e.g. .../upload/v1234/sample.jpg -> .../upload/w_500,q_60,f_webp/v1234/sample.jpg
        const uploadToken = '/upload/';
        if (rawUrl.contains(uploadToken)) {
          final transform = '/upload/w_$width,q_$quality,f_webp/';
          return rawUrl.replaceFirst(uploadToken, transform);
        }
      }

      // 3. Unsplash CDN transformation
      if (rawUrl.contains('images.unsplash.com')) {
        final params = Map<String, String>.from(uri.queryParameters);
        params['w'] = width.toString();
        params['q'] = quality.toString();
        params['auto'] = 'format';
        params['fit'] = 'crop';
        return uri.replace(queryParameters: params).toString();
      }

      // 4. YouTube Thumbnail (hqdefault to mqdefault for bandwidth optimization)
      if (rawUrl.contains('img.youtube.com')) {
        if (width <= 320) {
          return rawUrl.replaceAll('hqdefault.jpg', 'mqdefault.jpg');
        }
        return rawUrl;
      }

      // Fallback: append ImageKit query transform if applicable
      final separator = uri.hasQuery ? '&' : '?';
      return '$rawUrl${separator}tr=w-$width,q-$quality,f-webp';
    } catch (_) {
      return rawUrl;
    }
  }
}

/// Production-ready wrapper for CachedNetworkImage that strictly enforces
/// [memCacheWidth] and [memCacheHeight] to prevent OOM on 2GB RAM devices,
/// and uses lightweight shimmer placeholders for high perceived performance.
class OptimizedNetworkImage extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BorderRadius? borderRadius;
  final int memCacheWidth;
  final int memCacheHeight;

  const OptimizedNetworkImage({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.borderRadius,
    this.memCacheWidth = 500,
    this.memCacheHeight = 380,
  });

  @override
  Widget build(BuildContext context) {
    final optimizedUrl = MediaUrlHelper.getOptimizedImageUrl(
      imageUrl,
      width: memCacheWidth,
    );

    Widget image = CachedNetworkImage(
      imageUrl: optimizedUrl,
      width: width,
      height: height,
      fit: fit,
      // CRITICAL: Restricts decode buffer in native memory to prevent OOM crashes on low RAM devices
      memCacheWidth: memCacheWidth,
      memCacheHeight: memCacheHeight,
      maxWidthDiskCache: memCacheWidth + 100,
      maxHeightDiskCache: memCacheHeight + 100,
      placeholder: (context, url) => Shimmer.fromColors(
        baseColor: AppColors.shimmerBase,
        highlightColor: AppColors.shimmerHighlight,
        child: Container(
          width: width ?? double.infinity,
          height: height ?? double.infinity,
          color: AppColors.surfaceSubtle,
        ),
      ),
      errorWidget: (context, url, error) => Container(
        width: width,
        height: height,
        color: AppColors.surfaceSubtle,
        alignment: Alignment.center,
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.grass, color: AppColors.primaryLight, size: 28),
            SizedBox(height: 4),
            Text(
              'Sadhu Ram & Sons',
              style: TextStyle(
                fontSize: 10,
                color: AppColors.textMuted,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }
    return image;
  }
}
