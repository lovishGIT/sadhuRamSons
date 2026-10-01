class IrrigationStage {
  final Map<String, String> stage;
  final String daysAfterSowing;
  final String importance;

  const IrrigationStage({
    required this.stage,
    required this.daysAfterSowing,
    required this.importance,
  });

  factory IrrigationStage.fromJson(Map<String, dynamic> json) {
    return IrrigationStage(
      stage: Map<String, String>.from(json['stage'] as Map? ?? {}),
      daysAfterSowing: json['daysAfterSowing'] as String? ?? '',
      importance: json['importance'] as String? ?? 'Normal',
    );
  }

  Map<String, dynamic> toJson() => {
    'stage': stage,
    'daysAfterSowing': daysAfterSowing,
    'importance': importance,
  };

  String getStage(String langCode) {
    return stage[langCode] ?? stage['en'] ?? '';
  }
}

class CropModel {
  final String id;
  final Map<String, String> name;
  final String scientificName;
  final String category;
  final String season;
  final String imageUrl;
  final Map<String, String> sowingTime;
  final Map<String, String> harvestTime;
  final Map<String, String> soilType;
  final String temperature;
  final String rainfall;
  final String expectedYield;
  final String marketPriceRange;
  final List<IrrigationStage> irrigationStages;
  final Map<String, String> fertilizerSchedule;
  final Map<String, String> pestManagement;
  final List<Map<String, String>> expertTips;

  const CropModel({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.category,
    required this.season,
    required this.imageUrl,
    required this.sowingTime,
    required this.harvestTime,
    required this.soilType,
    required this.temperature,
    required this.rainfall,
    required this.expectedYield,
    required this.marketPriceRange,
    required this.irrigationStages,
    required this.fertilizerSchedule,
    required this.pestManagement,
    required this.expertTips,
  });

  factory CropModel.fromJson(Map<String, dynamic> json) {
    final stagesRaw = json['irrigationStages'] as List<dynamic>? ?? [];
    final tipsRaw = json['expertTips'] as List<dynamic>? ?? [];

    return CropModel(
      id: json['id'] as String? ?? '',
      name: Map<String, String>.from(json['name'] as Map? ?? {}),
      scientificName: json['scientificName'] as String? ?? '',
      category: json['category'] as String? ?? '',
      season: json['season'] as String? ?? '',
      imageUrl: json['imageUrl'] as String? ?? '',
      sowingTime: Map<String, String>.from(json['sowingTime'] as Map? ?? {}),
      harvestTime: Map<String, String>.from(json['harvestTime'] as Map? ?? {}),
      soilType: Map<String, String>.from(json['soilType'] as Map? ?? {}),
      temperature: json['temperature'] as String? ?? '',
      rainfall: json['rainfall'] as String? ?? '',
      expectedYield: json['expectedYield'] as String? ?? '',
      marketPriceRange: json['marketPriceRange'] as String? ?? '',
      irrigationStages: stagesRaw
          .map(
            (e) =>
                IrrigationStage.fromJson(Map<String, dynamic>.from(e as Map)),
          )
          .toList(),
      fertilizerSchedule: Map<String, String>.from(
        json['fertilizerSchedule'] as Map? ?? {},
      ),
      pestManagement: Map<String, String>.from(
        json['pestManagement'] as Map? ?? {},
      ),
      expertTips: tipsRaw
          .map((e) => Map<String, String>.from(e as Map))
          .toList(),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'scientificName': scientificName,
    'category': category,
    'season': season,
    'imageUrl': imageUrl,
    'sowingTime': sowingTime,
    'harvestTime': harvestTime,
    'soilType': soilType,
    'temperature': temperature,
    'rainfall': rainfall,
    'expectedYield': expectedYield,
    'marketPriceRange': marketPriceRange,
    'irrigationStages': irrigationStages.map((e) => e.toJson()).toList(),
    'fertilizerSchedule': fertilizerSchedule,
    'pestManagement': pestManagement,
    'expertTips': expertTips,
  };

  String getName(String langCode) => name[langCode] ?? name['en'] ?? id;
  String getSowingTime(String langCode) =>
      sowingTime[langCode] ?? sowingTime['en'] ?? '';
  String getHarvestTime(String langCode) =>
      harvestTime[langCode] ?? harvestTime['en'] ?? '';
  String getSoilType(String langCode) =>
      soilType[langCode] ?? soilType['en'] ?? '';
  String getFertilizerSchedule(String langCode) =>
      fertilizerSchedule[langCode] ?? fertilizerSchedule['en'] ?? '';
  String getPestManagement(String langCode) =>
      pestManagement[langCode] ?? pestManagement['en'] ?? '';
  List<String> getTips(String langCode) {
    return expertTips
        .map((tipMap) => tipMap[langCode] ?? tipMap['en'] ?? '')
        .where((t) => t.isNotEmpty)
        .toList();
  }
}
