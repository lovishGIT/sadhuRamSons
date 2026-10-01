import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/utils/media_url_helper.dart';
import '../../data/models/crop_model.dart';
import '../../data/repositories/catalog_repository.dart';
import '../language/language_select_sheet.dart';

class CropDetailScreen extends ConsumerWidget {
  final String cropId;

  const CropDetailScreen({super.key, required this.cropId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cropAsync = ref.watch(cropDetailProvider(cropId));
    final langCode = ref.watch(localeProvider).languageCode;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: cropAsync.when(
          data: (crop) => Text(crop?.getName(langCode) ?? l10n.crops),
          loading: () => Text(l10n.crops),
          error: (err, stack) => Text(l10n.crops),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate_rounded),
            tooltip: l10n.changeLanguage,
            onPressed: () => LanguageSelectSheet.show(context),
          ),
        ],
      ),
      body: cropAsync.when(
        data: (crop) {
          if (crop == null) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.info_outline,
                    size: 48,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 12),
                  Text(l10n.noDataFound, style: AppTypography.title),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => context.go('/'),
                    child: Text(l10n.allCrops),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Image with ImageKit WebP and strict memCache enforcement
                SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: OptimizedNetworkImage(
                    imageUrl: crop.imageUrl,
                    width: double.infinity,
                    height: 220,
                    memCacheWidth: 600,
                    memCacheHeight: 440,
                    fit: BoxFit.cover,
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header & Badges
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  crop.getName(langCode),
                                  style: AppTypography.display.copyWith(
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  crop.scientificName,
                                  style: AppTypography.subtitle.copyWith(
                                    fontStyle: FontStyle.italic,
                                    color: AppColors.textMuted,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.secondaryContainer,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppColors.secondary,
                                width: 1,
                              ),
                            ),
                            child: Text(
                              crop.season == 'Rabi'
                                  ? l10n.rabiSeason
                                  : l10n.kharifSeason,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: AppColors.onSecondaryContainer,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Market Price & Yield Highlight Box (Outdoor high contrast)
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.2,
                          ),
                        ),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.currency_rupee,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.marketPrice,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    crop.marketPriceRange,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 1,
                              height: 38,
                              color: AppColors.border,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.scale_rounded,
                                        size: 16,
                                        color: AppColors.primary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        l10n.expectedYield,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.onPrimaryContainer,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    crop.expectedYield,
                                    style: const TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Sowing & Harvest Schedule Cards
                      _buildScheduleRow(crop, langCode, l10n),
                      const SizedBox(height: 20),

                      // Soil & Climate Requirement
                      _buildSectionCard(
                        title: l10n.soil,
                        icon: Icons.terrain_rounded,
                        accentColor: AppColors.secondary,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              crop.getSoilType(langCode),
                              style: AppTypography.bodyMedium,
                            ),
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                _buildMiniBadge(
                                  Icons.thermostat_rounded,
                                  crop.temperature,
                                ),
                                const SizedBox(width: 8),
                                _buildMiniBadge(
                                  Icons.water_drop_rounded,
                                  crop.rainfall,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Irrigation Schedule
                      _buildSectionCard(
                        title: l10n.irrigation,
                        icon: Icons.water_rounded,
                        accentColor: AppColors.info,
                        child: Column(
                          children: crop.irrigationStages.map((stage) {
                            final isCritical = stage.importance
                                .toLowerCase()
                                .contains('critical');
                            return Container(
                              margin: const EdgeInsets.only(bottom: 8),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: isCritical
                                    ? AppColors.alertContainer
                                    : AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: isCritical
                                      ? AppColors.alert.withAlpha(80)
                                      : AppColors.borderSubtle,
                                ),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stage.getStage(langCode),
                                          style: TextStyle(
                                            fontSize: 13,
                                            fontWeight: FontWeight.w700,
                                            color: isCritical
                                                ? AppColors.onAlertContainer
                                                : AppColors.textPrimary,
                                          ),
                                        ),
                                        Text(
                                          stage.daysAfterSowing,
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.w500,
                                            color: isCritical
                                                ? AppColors.alert
                                                : AppColors.textMuted,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 8,
                                      vertical: 3,
                                    ),
                                    decoration: BoxDecoration(
                                      color: isCritical
                                          ? AppColors.alert
                                          : AppColors.border,
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      isCritical ? l10n.critical : l10n.medium,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: FontWeight.w700,
                                        color: isCritical
                                            ? Colors.white
                                            : AppColors.textPrimary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Fertilizer Schedule
                      _buildSectionCard(
                        title: l10n.fertilizer,
                        icon: Icons.science_rounded,
                        accentColor: AppColors.primary,
                        child: Text(
                          crop.getFertilizerSchedule(langCode),
                          style: AppTypography.body.copyWith(height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Pest & Disease Management
                      _buildSectionCard(
                        title: l10n.pestControl,
                        icon: Icons.shield_outlined,
                        accentColor: AppColors.warning,
                        child: Text(
                          crop.getPestManagement(langCode),
                          style: AppTypography.body.copyWith(height: 1.5),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Expert Field Tips
                      if (crop.getTips(langCode).isNotEmpty) ...[
                        _buildSectionCard(
                          title: l10n.expertTips,
                          icon: Icons.lightbulb_outline_rounded,
                          accentColor: AppColors.secondary,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: crop.getTips(langCode).map((tip) {
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 8.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      '• ',
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        tip,
                                        style: AppTypography.body.copyWith(
                                          height: 1.45,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // Recommended Agrochemical Medicines Section
                      _buildRecommendedProducts(
                        context,
                        ref,
                        crop.id,
                        langCode,
                        l10n,
                      ),

                      // Linked Video Guides Section
                      _buildRelatedVideos(
                        context,
                        ref,
                        crop.id,
                        langCode,
                        l10n,
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
        error: (err, stack) => Center(child: Text('Error loading crop: $err')),
      ),
    );
  }

  Widget _buildScheduleRow(
    CropModel crop,
    String langCode,
    AppLocalizations l10n,
  ) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: AppColors.primary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.sowing,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  crop.getSowingTime(langCode),
                  style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.border),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.agriculture_rounded,
                      size: 16,
                      color: AppColors.secondary,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      l10n.harvest,
                      style: AppTypography.caption.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  crop.getHarvestTime(langCode),
                  style: AppTypography.bodyMedium.copyWith(fontSize: 13),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20, color: accentColor),
              const SizedBox(width: 8),
              Text(title, style: AppTypography.title.copyWith(fontSize: 16)),
            ],
          ),
          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _buildMiniBadge(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.surfaceSubtle,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.borderSubtle),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.textSecondary),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRelatedVideos(
    BuildContext context,
    WidgetRef ref,
    String cropId,
    String langCode,
    AppLocalizations l10n,
  ) {
    final videosAsync = ref.watch(videoGuidesProvider);

    return videosAsync.when(
      data: (videos) {
        final related = videos
            .where((v) => v.cropId.toLowerCase() == cropId.toLowerCase())
            .toList();
        if (related.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.videoGuides, style: AppTypography.title),
            const SizedBox(height: 12),
            ...related.map((video) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 80,
                        height: 55,
                        child: OptimizedNetworkImage(
                          imageUrl: video.thumbnailUrl,
                          width: 80,
                          height: 55,
                          memCacheWidth: 200,
                          memCacheHeight: 140,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.black54,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          Icons.play_arrow,
                          size: 18,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                  title: Text(
                    video.getTitle(langCode),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: AppTypography.subtitle,
                  ),
                  subtitle: Text(
                    '${video.duration} • ${video.category}',
                    style: AppTypography.caption,
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                  ),
                  onTap: () {
                    context.push('/video/${video.id}');
                  },
                ),
              );
            }),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }

  Widget _buildRecommendedProducts(
    BuildContext context,
    WidgetRef ref,
    String cropId,
    String langCode,
    AppLocalizations l10n,
  ) {
    final productsAsync = ref.watch(productsForCropProvider(cropId));

    return productsAsync.when(
      data: (products) {
        if (products.isEmpty) return const SizedBox.shrink();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(
                  Icons.medication_liquid_rounded,
                  color: AppColors.primary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  l10n.recommendedMedicines,
                  style: AppTypography.title.copyWith(fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 12),
            ...products.map((product) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: SizedBox(
                      width: 58,
                      height: 58,
                      child: OptimizedNetworkImage(
                        imageUrl: product.imageUrl,
                        width: 58,
                        height: 58,
                        memCacheWidth: 150,
                        memCacheHeight: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  title: Row(
                    children: [
                      Expanded(
                        child: Text(
                          product.getName(langCode),
                          style: AppTypography.subtitle.copyWith(fontSize: 14),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 6,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          product.category,
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w700,
                            color: AppColors.onPrimaryContainer,
                          ),
                        ),
                      ),
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 3),
                      Text(
                        product.technicalName,
                        style: AppTypography.caption.copyWith(
                          color: AppColors.secondary,
                          fontWeight: FontWeight.w600,
                          fontSize: 11,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '${l10n.dosagePerAcre}: ${product.getDosagePerAcre(langCode)}',
                        style: AppTypography.caption.copyWith(fontSize: 11),
                      ),
                    ],
                  ),
                  trailing: const Icon(
                    Icons.chevron_right,
                    color: AppColors.primary,
                  ),
                  onTap: () {
                    context.push('/product/${product.id}');
                  },
                ),
              );
            }),
            const SizedBox(height: 8),
          ],
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (err, stack) => const SizedBox.shrink(),
    );
  }
}
