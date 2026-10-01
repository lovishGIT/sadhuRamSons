class VideoGuideModel {
  final String id;
  final String youtubeId;
  final String cropId;
  final Map<String, String> title;
  final Map<String, String> description;
  final String duration;
  final String category;
  final String thumbnailUrl;

  const VideoGuideModel({
    required this.id,
    required this.youtubeId,
    required this.cropId,
    required this.title,
    required this.description,
    required this.duration,
    required this.category,
    required this.thumbnailUrl,
  });

  factory VideoGuideModel.fromJson(Map<String, dynamic> json) {
    return VideoGuideModel(
      id: json['id'] as String? ?? '',
      youtubeId: json['youtubeId'] as String? ?? '',
      cropId: json['cropId'] as String? ?? '',
      title: Map<String, String>.from(json['title'] as Map? ?? {}),
      description: Map<String, String>.from(json['description'] as Map? ?? {}),
      duration: json['duration'] as String? ?? '',
      category: json['category'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'youtubeId': youtubeId,
    'cropId': cropId,
    'title': title,
    'description': description,
    'duration': duration,
    'category': category,
    'thumbnailUrl': thumbnailUrl,
  };

  String getTitle(String langCode) => title[langCode] ?? title['en'] ?? '';
  String getDescription(String langCode) =>
      description[langCode] ?? description['en'] ?? '';
}
