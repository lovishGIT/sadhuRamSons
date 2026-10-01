import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_typography.dart';
import '../../core/localization/localization_extension.dart';
import '../../core/localization/locale_provider.dart';
import '../../data/repositories/catalog_repository.dart';

class AdvisoryDetailScreen extends ConsumerWidget {
  final String advisoryId;

  const AdvisoryDetailScreen({super.key, required this.advisoryId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final advisoryAsync = ref.watch(advisoryDetailProvider(advisoryId));
    final langCode = ref.watch(localeProvider).languageCode;
    final l10n = context.l10n;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(l10n.deepLinkAdvisoryTitle),
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
      body: advisoryAsync.when(
        data: (advisory) {
          if (advisory == null) {
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

          final isWarning = advisory.level.toLowerCase() == 'warning';

          return Padding(
            padding: const EdgeInsets.all(20.0),
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isWarning
                    ? AppColors.warningContainer
                    : AppColors.surface,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isWarning ? AppColors.warning : AppColors.border,
                  width: 1.5,
                ),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isWarning
                            ? Icons.warning_amber_rounded
                            : Icons.info_rounded,
                        color: isWarning ? AppColors.warning : AppColors.info,
                        size: 28,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          advisory.date.toUpperCase(),
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: isWarning
                                ? AppColors.onWarningContainer
                                : AppColors.textMuted,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    advisory.getTitle(langCode),
                    style: AppTypography.headline.copyWith(
                      color: isWarning
                          ? AppColors.onWarningContainer
                          : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 12),
                  Text(
                    advisory.getDescription(langCode),
                    style: AppTypography.body.copyWith(
                      fontSize: 15,
                      height: 1.6,
                      color: isWarning
                          ? AppColors.onWarningContainer
                          : AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/'),
                      child: Text(l10n.allCrops),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, stack) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
