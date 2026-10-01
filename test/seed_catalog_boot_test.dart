import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive/hive.dart';
import 'package:sadhuramsons/data/local/hive_service.dart';
import 'package:sadhuramsons/data/repositories/catalog_repository.dart';

/// Custom HttpOverrides to verify that NO network calls are made during boot.
/// If any network connection is attempted, it throws an error immediately.
class StrictNoNetworkHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    throw UnsupportedError(
      'NETWORK CALL BLOCKED: App attempted network access during offline boot!',
    );
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempDir;
  late HiveService hiveService;

  setUpAll(() {
    // Enforce strict zero-network policy for the entire boot test suite
    HttpOverrides.global = StrictNoNetworkHttpOverrides();
  });

  tearDownAll(() {
    HttpOverrides.global = null;
  });

  setUp(() async {
    // Create a pristine, isolated temp directory for Hive on each test run
    tempDir = await Directory.systemTemp.createTemp('sadhuram_boot_test_');
    Hive.init(tempDir.path);

    hiveService = HiveService();
    // Open isolated test boxes and inject into service
    final catalogBox = await Hive.openBox(HiveService.catalogBoxName);
    final settingsBox = await Hive.openBox(HiveService.settingsBoxName);
    await hiveService.init(catalogBox: catalogBox, settingsBox: settingsBox);
  });

  tearDown(() async {
    await Hive.close();
    if (tempDir.existsSync()) {
      tempDir.deleteSync(recursive: true);
    }
  });

  group('Seed Catalog Boot Verification', () {
    test('1. First Boot: Hive starts empty, then seeds synchronously from bundled asset', () async {
      final catalogBox = Hive.box(HiveService.catalogBoxName);

      // Verify Hive is completely empty on first clean launch
      expect(
        catalogBox.get(HiveService.keyIsInitialized, defaultValue: false),
        isFalse,
      );
      expect(hiveService.getCrops(), isEmpty);
      expect(hiveService.getVideoGuides(), isEmpty);
      expect(hiveService.getAdvisories(), isEmpty);

      // Execute boot seeding (same method executed in main.dart before runApp)
      await hiveService.seedCatalogIfEmpty();

      // Verify flag is marked initialized in Hive
      expect(
        catalogBox.get(HiveService.keyIsInitialized, defaultValue: false),
        isTrue,
      );

      // Verify all 3 crops are immediately available in Hive synchronously
      final crops = hiveService.getCrops();
      expect(crops.length, equals(3));
      expect(
        crops.map((c) => c.id).toList(),
        containsAll(['wheat', 'paddy', 'mustard']),
      );

      // Verify video guides are immediately available in Hive synchronously
      final videos = hiveService.getVideoGuides();
      expect(videos.length, equals(2));
      expect(
        videos.map((v) => v.id).toList(),
        containsAll([
          'wheat_high_yield_masterclass',
          'pest_protection_organic_chemical',
        ]),
      );

      // Verify advisories are populated
      final advisories = hiveService.getAdvisories();
      expect(advisories, isNotEmpty);
    });

    test('2. Zero Network Guarantee: CatalogRepository retrieves data entirely from Hive cache', () async {
      // Seed the database
      await hiveService.seedCatalogIfEmpty();

      final repository = CatalogRepository(hiveService: hiveService);

      // Must succeed without throwing UnsupportedError from StrictNoNetworkHttpOverrides
      final crops = await repository.getCrops();
      expect(crops.length, equals(3));

      final wheat = await repository.getCropById('wheat');
      expect(wheat, isNotNull);
      expect(wheat!.getName('en'), contains('Wheat'));
      expect(wheat.getName('hi'), contains('गेहूं'));
      expect(wheat.getName('pa'), contains('ਕਣਕ'));

      final video = await repository.getVideoById(
        'wheat_high_yield_masterclass',
      );
      expect(video, isNotNull);
      expect(video!.youtubeId, equals('g20VYGsmWbU'));
    });

    test('3. Subsequent Boots: seedCatalogIfEmpty is idempotent and does not re-read asset', () async {
      final catalogBox = Hive.box(HiveService.catalogBoxName);

      // Initial seed
      await hiveService.seedCatalogIfEmpty();
      expect(hiveService.getCrops().length, equals(3));

      // Modify a value in Hive to verify that subsequent boot preserves cached state
      await catalogBox.put(
        HiveService.keyCrops,
        '[{"id":"custom_crop","name":{"en":"Custom"},"scientificName":"C","category":"C","season":"R","imageUrl":"","sowingTime":{},"harvestTime":{},"soilType":{},"temperature":"","rainfall":"","expectedYield":"","marketPriceRange":"","irrigationStages":[],"fertilizerSchedule":{},"pestManagement":{},"expertTips":[]}]',
      );

      // Second boot invocation
      await hiveService.seedCatalogIfEmpty();

      // State is preserved and not overwritten
      final crops = hiveService.getCrops();
      expect(crops.length, equals(1));
      expect(crops.first.id, equals('custom_crop'));
    });
  });
}
