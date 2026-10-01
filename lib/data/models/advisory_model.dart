class AdvisoryModel {
  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final String level; // warning, info, alert
  final String date;

  const AdvisoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.level,
    required this.date,
  });

  factory AdvisoryModel.fromJson(Map<String, dynamic> json) {
    return AdvisoryModel(
      id: json['id'] as String? ?? '',
      title: Map<String, String>.from(json['title'] as Map? ?? {}),
      description: Map<String, String>.from(json['description'] as Map? ?? {}),
      level: json['level'] as String? ?? 'info',
      date: json['date'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'description': description,
    'level': level,
    'date': date,
  };

  String getTitle(String langCode) => title[langCode] ?? title['en'] ?? '';
  String getDescription(String langCode) =>
      description[langCode] ?? description['en'] ?? '';
}
