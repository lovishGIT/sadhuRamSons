/// Type-safe compile-time environment configuration loaded from `.env`
/// via Flutter's `--dart-define-from-file=.env`.
///
/// Pure Dart, zero runtime bundle size overhead, zero reflection.
class AppEnv {
  AppEnv._();

  static const String appEnv = String.fromEnvironment(
    'APP_ENV',
    defaultValue: 'production',
  );

  static const String appName = String.fromEnvironment(
    'APP_NAME',
    defaultValue: 'Kisan Mitra - Sadhu Ram & Sons',
  );

  static const String appVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: '1.0.0',
  );

  static const String imageKitEndpoint = String.fromEnvironment(
    'IMAGEKIT_URL_ENDPOINT',
    defaultValue: 'https://ik.imagekit.io/sadhuram',
  );

  static const String cloudinaryCloudName = String.fromEnvironment(
    'CLOUDINARY_CLOUD_NAME',
    defaultValue: 'sadhuramsons',
  );

  static const int defaultImageQuality = int.fromEnvironment(
    'IMAGE_OPTIMIZATION_QUALITY',
    defaultValue: 60,
  );

  static const int defaultImageWidth = int.fromEnvironment(
    'IMAGE_OPTIMIZATION_WIDTH',
    defaultValue: 500,
  );

  static const String youtubeEmbedBaseUrl = String.fromEnvironment(
    'YOUTUBE_EMBED_BASE_URL',
    defaultValue: 'https://www.youtube-nocookie.com/embed',
  );

  static const String defaultLocale = String.fromEnvironment(
    'DEFAULT_LOCALE',
    defaultValue: 'hi',
  );

  static const String farmerHelpline = String.fromEnvironment(
    'FARMER_HELPLINE',
    defaultValue: '1800-180-1551',
  );

  static const String deepLinkScheme = String.fromEnvironment(
    'DEEP_LINK_SCHEME',
    defaultValue: 'sadhuram',
  );

  static const String deepLinkHost = String.fromEnvironment(
    'DEEP_LINK_HOST',
    defaultValue: 'sadhuram.app',
  );

  static bool get isProduction => appEnv == 'production';
  static bool get isDevelopment => appEnv == 'development';
}
