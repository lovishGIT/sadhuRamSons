import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_colors.dart';
import 'core/localization/app_localizations.dart';
import 'core/localization/locale_provider.dart';
import 'core/router/app_router.dart';
import 'data/local/hive_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Set system UI overlay style for daylight visibility
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.surface,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  // 1. Initialize Hive local key-value and catalog boxes
  final hiveService = HiveService();
  await hiveService.init();

  // 2. Load bundled fallback seed_catalog.json if Hive is empty
  //    Guarantees instant first-frame load with zero network wait time
  await hiveService.seedCatalogIfEmpty();

  runApp(const ProviderScope(child: KisanMitraApp()));
}

class KisanMitraApp extends ConsumerWidget {
  const KisanMitraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(appRouterProvider);
    final currentLocale = ref.watch(localeProvider);

    return MaterialApp.router(
      title: 'Sadhu Ram & Sons - Kisan Mitra',
      debugShowCheckedModeBanner: false,

      // High-contrast, light-mode only theme for outdoor visibility
      theme: AppColors.lightTheme,
      themeMode: ThemeMode.light,

      // Declarative router supporting deep links (/crop/:id, /advisory/:id, /video/:id)
      routerConfig: router,

      // Multilingual localization delegates (English, Hindi, Punjabi)
      locale: currentLocale,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
    );
  }
}
