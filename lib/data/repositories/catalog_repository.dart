import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../local/hive_service.dart';
import '../models/crop_model.dart';
import '../models/video_guide_model.dart';
import '../models/advisory_model.dart';

class CatalogRepository {
  final HiveService _hiveService;

  CatalogRepository({HiveService? hiveService})
    : _hiveService = hiveService ?? HiveService();

  /// Retrieve all crops with instant local fallback
  Future<List<CropModel>> getCrops() async {
    final cached = _hiveService.getCrops();
    if (cached.isNotEmpty) {
      return cached;
    }

    // Direct bundled asset fallback
    return _loadCropsFromAsset();
  }

  /// Retrieve a specific crop by id (for deep linking e.g. /crop/wheat)
  Future<CropModel?> getCropById(String id) async {
    final crops = await getCrops();
    try {
      return crops.firstWhere((c) => c.id.toLowerCase() == id.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  /// Retrieve video guides
  Future<List<VideoGuideModel>> getVideoGuides() async {
    final cached = _hiveService.getVideoGuides();
    if (cached.isNotEmpty) {
      return cached;
    }
    return _loadVideosFromAsset();
  }

  /// Retrieve video guide by ID or Youtube ID
  Future<VideoGuideModel?> getVideoById(String id) async {
    final videos = await getVideoGuides();
    try {
      return videos.firstWhere(
        (v) =>
            v.id.toLowerCase() == id.toLowerCase() ||
            v.youtubeId.toLowerCase() == id.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  /// Retrieve advisories
  Future<List<AdvisoryModel>> getAdvisories() async {
    final cached = _hiveService.getAdvisories();
    if (cached.isNotEmpty) {
      return cached;
    }
    return _loadAdvisoriesFromAsset();
  }

  /// Retrieve advisory by ID
  Future<AdvisoryModel?> getAdvisoryById(String id) async {
    final advisories = await getAdvisories();
    try {
      return advisories.firstWhere(
        (a) => a.id.toLowerCase() == id.toLowerCase(),
      );
    } catch (_) {
      return null;
    }
  }

  Future<List<CropModel>> _loadCropsFromAsset() async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/data/seed_catalog.json',
      );
      final Map<String, dynamic> data =
          json.decode(jsonStr) as Map<String, dynamic>;
      final list = data['crops'] as List<dynamic>? ?? [];
      return list
          .map((e) => CropModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<VideoGuideModel>> _loadVideosFromAsset() async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/data/seed_catalog.json',
      );
      final Map<String, dynamic> data =
          json.decode(jsonStr) as Map<String, dynamic>;
      final list = data['videoGuides'] as List<dynamic>? ?? [];
      return list
          .map(
            (e) =>
                VideoGuideModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }

  Future<List<AdvisoryModel>> _loadAdvisoriesFromAsset() async {
    try {
      final jsonStr = await rootBundle.loadString(
        'assets/data/seed_catalog.json',
      );
      final Map<String, dynamic> data =
          json.decode(jsonStr) as Map<String, dynamic>;
      final list = data['advisories'] as List<dynamic>? ?? [];
      return list
          .map(
            (e) => AdvisoryModel.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList();
    } catch (_) {
      return [];
    }
  }
}

// ==================== RIVERPOD PROVIDERS ====================

final catalogRepositoryProvider = Provider<CatalogRepository>((ref) {
  return CatalogRepository();
});

final cropsProvider = FutureProvider<List<CropModel>>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.getCrops();
});

final cropDetailProvider = FutureProvider.family<CropModel?, String>((
  ref,
  id,
) async {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.getCropById(id);
});

final videoGuidesProvider = FutureProvider<List<VideoGuideModel>>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.getVideoGuides();
});

final videoDetailProvider = FutureProvider.family<VideoGuideModel?, String>((
  ref,
  id,
) async {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.getVideoById(id);
});

final advisoriesProvider = FutureProvider<List<AdvisoryModel>>((ref) async {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.getAdvisories();
});

final advisoryDetailProvider = FutureProvider.family<AdvisoryModel?, String>((
  ref,
  id,
) async {
  final repo = ref.watch(catalogRepositoryProvider);
  return repo.getAdvisoryById(id);
});
