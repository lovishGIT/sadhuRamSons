import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_hi.dart';
import 'app_localizations_pa.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'localization/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('hi'),
    Locale('pa'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Kisan Mitra'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Sadhu Ram & Sons Farming Advisory'**
  String get appSubtitle;

  /// No description provided for @crops.
  ///
  /// In en, this message translates to:
  /// **'Crops'**
  String get crops;

  /// No description provided for @allCrops.
  ///
  /// In en, this message translates to:
  /// **'All Crops'**
  String get allCrops;

  /// No description provided for @products.
  ///
  /// In en, this message translates to:
  /// **'Products & Medicines'**
  String get products;

  /// No description provided for @allProducts.
  ///
  /// In en, this message translates to:
  /// **'All Products'**
  String get allProducts;

  /// No description provided for @insecticides.
  ///
  /// In en, this message translates to:
  /// **'Insecticides'**
  String get insecticides;

  /// No description provided for @fungicides.
  ///
  /// In en, this message translates to:
  /// **'Fungicides'**
  String get fungicides;

  /// No description provided for @herbicides.
  ///
  /// In en, this message translates to:
  /// **'Herbicides'**
  String get herbicides;

  /// No description provided for @technicalFormula.
  ///
  /// In en, this message translates to:
  /// **'Technical Formulation'**
  String get technicalFormula;

  /// No description provided for @dosagePerAcre.
  ///
  /// In en, this message translates to:
  /// **'Dosage Per Acre'**
  String get dosagePerAcre;

  /// No description provided for @targetPests.
  ///
  /// In en, this message translates to:
  /// **'Target Pests & Weeds'**
  String get targetPests;

  /// No description provided for @packSizes.
  ///
  /// In en, this message translates to:
  /// **'Available Pack Sizes'**
  String get packSizes;

  /// No description provided for @callToOrder.
  ///
  /// In en, this message translates to:
  /// **'Call / Order: 7355555441'**
  String get callToOrder;

  /// No description provided for @recommendedMedicines.
  ///
  /// In en, this message translates to:
  /// **'Recommended Agrochemicals'**
  String get recommendedMedicines;

  /// No description provided for @viewProduct.
  ///
  /// In en, this message translates to:
  /// **'View Product Details'**
  String get viewProduct;

  /// No description provided for @originalGuaranteed.
  ///
  /// In en, this message translates to:
  /// **'100% Genuine Guaranteed'**
  String get originalGuaranteed;

  /// No description provided for @videoGuides.
  ///
  /// In en, this message translates to:
  /// **'Video Guides'**
  String get videoGuides;

  /// No description provided for @advisories.
  ///
  /// In en, this message translates to:
  /// **'Advisories & Alerts'**
  String get advisories;

  /// No description provided for @changeLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get changeLanguage;

  /// No description provided for @selectLanguage.
  ///
  /// In en, this message translates to:
  /// **'Select Preferred Language'**
  String get selectLanguage;

  /// No description provided for @sowing.
  ///
  /// In en, this message translates to:
  /// **'Sowing Time'**
  String get sowing;

  /// No description provided for @harvest.
  ///
  /// In en, this message translates to:
  /// **'Harvest Time'**
  String get harvest;

  /// No description provided for @soil.
  ///
  /// In en, this message translates to:
  /// **'Soil Type'**
  String get soil;

  /// No description provided for @irrigation.
  ///
  /// In en, this message translates to:
  /// **'Irrigation Schedule'**
  String get irrigation;

  /// No description provided for @fertilizer.
  ///
  /// In en, this message translates to:
  /// **'Fertilizer Schedule'**
  String get fertilizer;

  /// No description provided for @pestControl.
  ///
  /// In en, this message translates to:
  /// **'Pest & Disease Control'**
  String get pestControl;

  /// No description provided for @expectedYield.
  ///
  /// In en, this message translates to:
  /// **'Expected Yield'**
  String get expectedYield;

  /// No description provided for @marketPrice.
  ///
  /// In en, this message translates to:
  /// **'Market Price (MSP)'**
  String get marketPrice;

  /// No description provided for @expertTips.
  ///
  /// In en, this message translates to:
  /// **'Expert Field Tips'**
  String get expertTips;

  /// No description provided for @watchVideo.
  ///
  /// In en, this message translates to:
  /// **'Watch Video Guide'**
  String get watchVideo;

  /// No description provided for @playVideo.
  ///
  /// In en, this message translates to:
  /// **'Play Video'**
  String get playVideo;

  /// No description provided for @tapToWatch.
  ///
  /// In en, this message translates to:
  /// **'Tap to stream adaptive video guide'**
  String get tapToWatch;

  /// No description provided for @cachedCatalog.
  ///
  /// In en, this message translates to:
  /// **'Loaded from local storage'**
  String get cachedCatalog;

  /// No description provided for @searchHint.
  ///
  /// In en, this message translates to:
  /// **'Search crops, insecticides, fungicides...'**
  String get searchHint;

  /// No description provided for @scientificName.
  ///
  /// In en, this message translates to:
  /// **'Botanical Name'**
  String get scientificName;

  /// No description provided for @season.
  ///
  /// In en, this message translates to:
  /// **'Crop Season'**
  String get season;

  /// No description provided for @critical.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get critical;

  /// No description provided for @medium.
  ///
  /// In en, this message translates to:
  /// **'Medium'**
  String get medium;

  /// No description provided for @high.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get high;

  /// No description provided for @daysAfterSowing.
  ///
  /// In en, this message translates to:
  /// **'Days After Sowing'**
  String get daysAfterSowing;

  /// No description provided for @stage.
  ///
  /// In en, this message translates to:
  /// **'Growth Stage'**
  String get stage;

  /// No description provided for @noDataFound.
  ///
  /// In en, this message translates to:
  /// **'No item found'**
  String get noDataFound;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @apply.
  ///
  /// In en, this message translates to:
  /// **'Apply'**
  String get apply;

  /// No description provided for @deepLinkAdvisoryTitle.
  ///
  /// In en, this message translates to:
  /// **'Field Advisory'**
  String get deepLinkAdvisoryTitle;

  /// No description provided for @rabiSeason.
  ///
  /// In en, this message translates to:
  /// **'Rabi Crop'**
  String get rabiSeason;

  /// No description provided for @kharifSeason.
  ///
  /// In en, this message translates to:
  /// **'Kharif Crop'**
  String get kharifSeason;

  /// No description provided for @farmerHelpline.
  ///
  /// In en, this message translates to:
  /// **'Sadhu Ram & Sons: 7355555441'**
  String get farmerHelpline;

  /// No description provided for @viewDetails.
  ///
  /// In en, this message translates to:
  /// **'View Crop Guide'**
  String get viewDetails;

  /// No description provided for @quickActions.
  ///
  /// In en, this message translates to:
  /// **'Quick Crop Library'**
  String get quickActions;

  /// No description provided for @outdoorVisibilityMode.
  ///
  /// In en, this message translates to:
  /// **'High Contrast Daylight Mode Active'**
  String get outdoorVisibilityMode;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'hi', 'pa'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'hi':
      return AppLocalizationsHi();
    case 'pa':
      return AppLocalizationsPa();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
