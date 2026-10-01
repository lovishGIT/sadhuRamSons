import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/local/hive_service.dart';

class SupportedLanguage {
  final String code;
  final String englishName;
  final String nativeName;
  final String region;

  const SupportedLanguage({
    required this.code,
    required this.englishName,
    required this.nativeName,
    required this.region,
  });
}

const List<SupportedLanguage> kSupportedLanguages = [
  SupportedLanguage(
    code: 'en',
    englishName: 'English',
    nativeName: 'English',
    region: 'India / Global',
  ),
  SupportedLanguage(
    code: 'hi',
    englishName: 'Hindi',
    nativeName: 'हिन्दी',
    region: 'North & Central India',
  ),
  SupportedLanguage(
    code: 'pa',
    englishName: 'Punjabi',
    nativeName: 'ਪੰਜਾਬੀ',
    region: 'Punjab & Haryana',
  ),
];

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() {
    final hiveService = HiveService();
    return Locale(hiveService.getLanguageCode());
  }

  Future<void> setLocale(String languageCode) async {
    if (state.languageCode == languageCode) return;
    await HiveService().setLanguageCode(languageCode);
    state = Locale(languageCode);
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  () => LocaleNotifier(),
);
