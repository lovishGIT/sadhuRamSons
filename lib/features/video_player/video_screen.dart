import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/localization/locale_provider.dart';
import '../../data/repositories/catalog_repository.dart';

class VideoScreen extends ConsumerStatefulWidget {
  final String videoId;

  const VideoScreen({super.key, required this.videoId});

  @override
  ConsumerState<VideoScreen> createState() => _VideoScreenState();
}

class _VideoScreenState extends ConsumerState<VideoScreen> {
  late YoutubePlayerController _controller;
  String _actualYoutubeId = '';

  @override
  void initState() {
    super.initState();
    _actualYoutubeId = widget.videoId;

    // Initialize YouTube controller with adaptive bitrate
    _controller = YoutubePlayerController.fromVideoId(
      videoId: _actualYoutubeId,
      autoPlay: true,
      params: const YoutubePlayerParams(
        showControls: true,
        showFullscreenButton: true,
        mute: false,
        loop: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void deactivate() {
    _controller.pauseVideo();
    super.deactivate();
  }

  @override
  void dispose() {
    // Strictly close controller to prevent any native memory leak on 2GB RAM devices
    _controller.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final videoAsync = ref.watch(videoDetailProvider(widget.videoId));
    final langCode = ref.watch(localeProvider).languageCode;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.watchVideo),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (Navigator.of(context).canPop()) {
              Navigator.of(context).pop();
            } else {
              context.go('/');
            }
          },
        ),
      ),
      body: videoAsync.when(
        data: (video) {
          final title = video?.getTitle(langCode) ?? l10n.videoGuides;
          final desc = video?.getDescription(langCode) ?? '';
          final duration = video?.duration ?? '';
          final category = video?.category ?? '';
          final cropId = video?.cropId;

          // If the parameter was a catalog id (e.g. wheat_high_yield_masterclass)
          // instead of the raw YouTube ID, update controller with the resolved youtubeId
          if (video != null &&
              video.youtubeId != _actualYoutubeId &&
              _actualYoutubeId == widget.videoId) {
            _actualYoutubeId = video.youtubeId;
            _controller.loadVideoById(videoId: video.youtubeId);
          }

          return SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Adaptive YouTube Player (HLS auto-adaptive for rural 2G/3G)
                Container(
                  color: Colors.black,
                  child: YoutubePlayer(
                    controller: _controller,
                    aspectRatio: 16 / 9,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category and Duration Badges
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.primaryContainer,
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              category.isNotEmpty ? category : 'Advisory',
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onPrimaryContainer,
                              ),
                            ),
                          ),
                          if (duration.isNotEmpty) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.timer_outlined,
                                    size: 14,
                                    color: AppColors.textMuted,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    duration,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.textSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Video Title
                      Text(
                        title,
                        style: AppTypography.headline.copyWith(
                          fontSize: 19,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Network Bandwidth Optimization Notice
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.infoContainer,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Row(
                          children: [
                            Icon(
                              Icons.network_check_rounded,
                              size: 16,
                              color: AppColors.info,
                            ),
                            SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                'Adaptive 2G/3G streaming enabled • Low data usage',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.onInfoContainer,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Video Description
                      if (desc.isNotEmpty) ...[
                        Text(
                          desc,
                          style: AppTypography.body.copyWith(
                            color: AppColors.textSecondary,
                            height: 1.5,
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Deep link to Crop Details if linked
                      if (cropId != null && cropId.isNotEmpty)
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            icon: const Icon(Icons.eco_rounded, size: 20),
                            label: Text(l10n.viewDetails),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primary,
                              foregroundColor: AppColors.onPrimary,
                              padding: const EdgeInsets.symmetric(vertical: 13),
                            ),
                            onPressed: () {
                              context.push('/crop/$cropId');
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(
          child: Text('Error loading video details', style: AppTypography.body),
        ),
      ),
    );
  }
}
