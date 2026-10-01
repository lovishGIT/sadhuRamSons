import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_env.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/app_localizations.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/localization/locale_provider.dart';
import '../../core/utils/media_url_helper.dart';
import '../../data/repositories/catalog_repository.dart';
import '../language/language_select_sheet.dart';

class ProductDetailScreen extends ConsumerWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  Future<void> _makePhoneCall(BuildContext context) async {
    final phone = AppEnv.farmerHelpline;
    final uri = Uri(scheme: 'tel', path: phone);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Helpline: $phone'),
              backgroundColor: AppColors.primary,
            ),
          );
        }
      }
    } catch (_) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Helpline: $phone'),
            backgroundColor: AppColors.primary,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productAsync = ref.watch(productDetailProvider(productId));
    final langCode = ref.watch(localeProvider).languageCode;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: productAsync.when(
          data: (product) => Text(product?.getName(langCode) ?? l10n.products),
          loading: () => Text(l10n.products),
          error: (err, stack) => Text(l10n.products),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.translate_rounded),
            tooltip: l10n.changeLanguage,
            onPressed: () => LanguageSelectSheet.show(context),
          ),
        ],
      ),
      bottomNavigationBar: SafeArea(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.surface,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withAlpha(20),
                blurRadius: 8,
                offset: const Offset(0, -2),
              ),
            ],
          ),
          child: ElevatedButton.icon(
            onPressed: () => _makePhoneCall(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              elevation: 2,
            ),
            icon: const Icon(Icons.call, size: 22),
            label: Text(
              l10n.callToOrder,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
            ),
          ),
        ),
      ),
      body: productAsync.when(
        data: (product) {
          if (product == null) {
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
                    child: Text(l10n.allProducts),
                  ),
                ],
              ),
            );
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Hero Image with ImageKit WebP and strict memCache enforcement
                SizedBox(
                  width: double.infinity,
                  height: 220,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      OptimizedNetworkImage(
                        imageUrl: product.imageUrl,
                        width: double.infinity,
                        height: 220,
                        memCacheWidth: 600,
                        memCacheHeight: 440,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        top: 12,
                        right: 12,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 5,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black.withAlpha(190),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            _getCategoryLabel(product.category, l10n),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product Title & Guarantee Badge
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  product.getName(langCode),
                                  style: AppTypography.display.copyWith(
                                    fontSize: 22,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  product.technicalName,
                                  style: AppTypography.subtitle.copyWith(
                                    color: AppColors.secondary,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          if (product.isOriginal)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.primaryContainer,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.primaryLight,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(
                                    Icons.verified_rounded,
                                    size: 14,
                                    color: AppColors.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    l10n.originalGuaranteed,
                                    style: const TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.primaryDark,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Technical Formula Card
                      _buildSectionCard(
                        title: l10n.technicalFormula,
                        icon: Icons.biotech_rounded,
                        accentColor: AppColors.primary,
                        child: Text(
                          product.technicalName,
                          style: AppTypography.body.copyWith(
                            fontWeight: FontWeight.w700,
                            color: AppColors.primaryDark,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Dosage Per Acre Card (High contrast outdoor highlight)
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AppColors.primaryContainer,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.primary,
                            width: 1.2,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(
                                  Icons.speed_rounded,
                                  size: 18,
                                  color: AppColors.primary,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  l10n.dosagePerAcre,
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.onPrimaryContainer,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text(
                              product.getDosagePerAcre(langCode),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: AppColors.primaryDark,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Target Pests and Diseases
                      _buildSectionCard(
                        title: l10n.targetPests,
                        icon: Icons.shield_outlined,
                        accentColor: AppColors.warning,
                        child: Text(
                          product.getTargetPests(langCode),
                          style: AppTypography.bodyMedium.copyWith(
                            height: 1.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Application Instructions
                      _buildSectionCard(
                        title: langCode == 'hi'
                            ? 'छिड़काव व प्रयोग विधि'
                            : (langCode == 'pa'
                                  ? 'ਵਰਤੋਂ ਦਾ ਸਹੀ ਤਰੀਕਾ'
                                  : 'Application Instructions'),
                        icon: Icons.water_drop_outlined,
                        accentColor: AppColors.secondary,
                        child: Text(
                          product.getApplicationInstructions(langCode),
                          style: AppTypography.body.copyWith(height: 1.45),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Available Pack Sizes
                      _buildSectionCard(
                        title: l10n.packSizes,
                        icon: Icons.inventory_2_outlined,
                        accentColor: AppColors.primary,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: product.packSizes.map((size) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.surfaceSubtle,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(
                                  color: AppColors.borderSubtle,
                                ),
                              ),
                              child: Text(
                                size,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 14),

                      // Product Description / Mode of Action
                      _buildSectionCard(
                        title: langCode == 'hi'
                            ? 'उत्पाद का विवरण'
                            : (langCode == 'pa'
                                  ? 'ਉਤਪਾਦ ਦਾ ਵੇਰਵਾ'
                                  : 'Product Details'),
                        icon: Icons.info_outline_rounded,
                        accentColor: AppColors.textSecondary,
                        child: Text(
                          product.getDescription(langCode),
                          style: AppTypography.body.copyWith(height: 1.5),
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
        error: (err, stack) =>
            Center(child: Text('Error loading product: $err')),
      ),
    );
  }

  String _getCategoryLabel(String category, AppLocalizations l10n) {
    switch (category.toLowerCase()) {
      case 'insecticide':
        return l10n.insecticides;
      case 'fungicide':
        return l10n.fungicides;
      case 'herbicide':
        return l10n.herbicides;
      default:
        return category;
    }
  }

  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Color accentColor,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
              Text(title, style: AppTypography.title.copyWith(fontSize: 15)),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(height: 1),
          const SizedBox(height: 10),
          child,
        ],
      ),
    );
  }
}
