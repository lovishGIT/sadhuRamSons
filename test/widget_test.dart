import 'package:flutter_test/flutter_test.dart';
import 'package:sadhuramsons/core/utils/media_url_helper.dart';
import 'package:sadhuramsons/data/models/crop_model.dart';
import 'package:sadhuramsons/data/models/video_guide_model.dart';

void main() {
  group('MediaUrlHelper Tests', () {
    test('ImageKit URL transformation generates WebP with q=60 and w=500', () {
      const raw = 'https://ik.imagekit.io/sadhuram/wheat.jpg';
      final transformed = MediaUrlHelper.getOptimizedImageUrl(
        raw,
        width: 500,
        quality: 60,
      );
      expect(transformed, contains('tr=w-500,q-60,f-webp'));
    });

    test(
      'Cloudinary URL transformation replaces /upload/ with w_500,q_60,f_webp',
      () {
        const raw = 'https://res.cloudinary.com/demo/image/upload/sample.jpg';
        final transformed = MediaUrlHelper.getOptimizedImageUrl(
          raw,
          width: 500,
          quality: 60,
        );
        expect(transformed, contains('/upload/w_500,q_60,f_webp/sample.jpg'));
      },
    );

    test('Unsplash URL parameters are updated with w, q, and format', () {
      const raw =
          'https://images.unsplash.com/photo-1574323347407-f5e1ad6d020b';
      final transformed = MediaUrlHelper.getOptimizedImageUrl(
        raw,
        width: 400,
        quality: 60,
      );
      expect(transformed, contains('w=400'));
      expect(transformed, contains('q=60'));
      expect(transformed, contains('auto=format'));
    });
  });

  group('Data Models Tests', () {
    test('CropModel multilingual getters return appropriate translations', () {
      final crop = CropModel.fromJson({
        'id': 'wheat',
        'name': {'en': 'Wheat', 'hi': 'गेहूं', 'pa': 'ਕਣਕ'},
        'scientificName': 'Triticum aestivum',
        'category': 'Cereal',
        'season': 'Rabi',
        'imageUrl': 'https://example.com/wheat.jpg',
        'sowingTime': {'en': 'November', 'hi': 'नवंबर', 'pa': 'ਨਵੰਬਰ'},
        'harvestTime': {'en': 'April'},
        'soilType': {'en': 'Loamy'},
        'temperature': '15-25 C',
        'rainfall': '75-100 cm',
        'expectedYield': '20 q/acre',
        'marketPriceRange': '2275',
        'irrigationStages': [
          {
            'stage': {'en': 'CRI', 'hi': 'ताज जड़', 'pa': 'ਤਾਜ ਜੜ੍ਹ'},
            'daysAfterSowing': '21 DAS',
            'importance': 'Critical',
          },
        ],
        'fertilizerSchedule': {'en': 'Urea 110kg'},
        'pestManagement': {'en': 'Spray Propiconazole'},
        'expertTips': [
          {'en': 'Treat seeds with Trichoderma'},
        ],
      });

      expect(crop.getName('en'), equals('Wheat'));
      expect(crop.getName('hi'), equals('गेहूं'));
      expect(crop.getName('pa'), equals('ਕਣਕ'));
      expect(crop.irrigationStages.first.getStage('hi'), equals('ताज जड़'));
      expect(crop.getTips('en').first, contains('Trichoderma'));
    });

    test('VideoGuideModel parses YouTube ID and titles', () {
      final video = VideoGuideModel.fromJson({
        'id': 'wheat_guide',
        'youtubeId': 'g20VYGsmWbU',
        'cropId': 'wheat',
        'title': {'en': 'Wheat Sowing Guide'},
        'description': {'en': 'Learn sowing methods'},
        'duration': '10:00',
        'category': 'Sowing',
        'thumbnailUrl': 'https://img.youtube.com/vi/g20VYGsmWbU/hqdefault.jpg',
      });

      expect(video.youtubeId, equals('g20VYGsmWbU'));
      expect(video.getTitle('en'), equals('Wheat Sowing Guide'));
    });
  });
}
