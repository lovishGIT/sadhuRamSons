class ProductModel {
  final String id;
  final Map<String, String> name;
  final String category; // Insecticide, Fungicide, Herbicide
  final String technicalName;
  final Map<String, String> targetPests;
  final List<String> targetCrops;
  final Map<String, String> dosagePerAcre;
  final List<String> packSizes;
  final Map<String, String> description;
  final Map<String, String> applicationInstructions;
  final String imageUrl;
  final String priceRange;
  final bool isOriginal;

  const ProductModel({
    required this.id,
    required this.name,
    required this.category,
    required this.technicalName,
    required this.targetPests,
    required this.targetCrops,
    required this.dosagePerAcre,
    required this.packSizes,
    required this.description,
    required this.applicationInstructions,
    required this.imageUrl,
    this.priceRange = 'Contact for Best Rate',
    this.isOriginal = true,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final packRaw = json['packSizes'] as List<dynamic>? ?? [];
    final cropsRaw = json['targetCrops'] as List<dynamic>? ?? [];

    return ProductModel(
      id: json['id'] as String? ?? '',
      name: Map<String, String>.from(json['name'] as Map? ?? {}),
      category: json['category'] as String? ?? 'Insecticide',
      technicalName: json['technicalName'] as String? ?? '',
      targetPests: Map<String, String>.from(json['targetPests'] as Map? ?? {}),
      targetCrops: cropsRaw.map((e) => e.toString()).toList(),
      dosagePerAcre: Map<String, String>.from(
        json['dosagePerAcre'] as Map? ?? {},
      ),
      packSizes: packRaw.map((e) => e.toString()).toList(),
      description: Map<String, String>.from(json['description'] as Map? ?? {}),
      applicationInstructions: Map<String, String>.from(
        json['applicationInstructions'] as Map? ?? {},
      ),
      imageUrl: json['imageUrl'] as String? ?? '',
      priceRange: json['priceRange'] as String? ?? 'Contact for Best Rate',
      isOriginal: json['isOriginal'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'category': category,
    'technicalName': technicalName,
    'targetPests': targetPests,
    'targetCrops': targetCrops,
    'dosagePerAcre': dosagePerAcre,
    'packSizes': packSizes,
    'description': description,
    'applicationInstructions': applicationInstructions,
    'imageUrl': imageUrl,
    'priceRange': priceRange,
    'isOriginal': isOriginal,
  };

  String getName(String langCode) => name[langCode] ?? name['en'] ?? id;

  String getTargetPests(String langCode) =>
      targetPests[langCode] ?? targetPests['en'] ?? '';

  String getDosagePerAcre(String langCode) =>
      dosagePerAcre[langCode] ?? dosagePerAcre['en'] ?? '';

  String getDescription(String langCode) =>
      description[langCode] ?? description['en'] ?? '';

  String getApplicationInstructions(String langCode) =>
      applicationInstructions[langCode] ?? applicationInstructions['en'] ?? '';
}
