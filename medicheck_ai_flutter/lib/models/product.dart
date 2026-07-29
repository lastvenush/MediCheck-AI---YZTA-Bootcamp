class ProductSource {
  const ProductSource({required this.title, required this.url});

  final String title;
  final String url;

  factory ProductSource.fromJson(Map<String, dynamic> json) {
    return ProductSource(
      title: Product._readString(json['title']),
      url: Product._readString(json['url']),
    );
  }
}

class Product {
  const Product({
    required this.id,
    required this.brand,
    required this.name,
    required this.category,
    required this.description,
    required this.ingredients,
    required this.usageInstructions,
    required this.sideEffects,
    required this.contraindications,
    required this.aiAnalysis,
    required this.isSafe,
    required this.imageUrl,
    this.manufacturer = '',
    this.indications = const [],
    this.warnings = const [],
    this.activeIngredients = const [],
    this.filterTypes = const [],
    this.skinTypes = const [],
    this.containsAlcohol,
    this.containsFragrance,
    this.sources = const [],
    this.lastReviewedAt = '',
  });

  final String id;
  final String brand;
  final String name;
  final String category;
  final String description;
  final List<String> ingredients;
  final String usageInstructions;
  final String sideEffects;
  final String contraindications;
  final String aiAnalysis;
  final bool isSafe;
  final String imageUrl;
  final String manufacturer;
  final List<String> indications;
  final List<String> warnings;
  final List<String> activeIngredients;
  final List<String> filterTypes;
  final List<String> skinTypes;
  final bool? containsAlcohol;
  final bool? containsFragrance;
  final List<ProductSource> sources;
  final String lastReviewedAt;

  bool get isMedicine => category == 'İlaç';
  bool get isSunscreen => category == 'Güneş Kremi';
  bool get hasReviewedSources =>
      sources.isNotEmpty && lastReviewedAt.isNotEmpty;
  String get displayManufacturer => manufacturer.isEmpty ? brand : manufacturer;
  List<String> get primaryIngredients {
    if (isMedicine && activeIngredients.isNotEmpty) return activeIngredients;
    if (isSunscreen && filterTypes.isNotEmpty) return filterTypes;
    return ingredients;
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: _readString(json['id']),
      brand: _readString(json['brand']),
      name: _readString(json['name']),
      category: _readString(json['category']),
      description: _readString(json['description']),
      ingredients: _readStringList(json['ingredients']),
      usageInstructions: _readString(json['usageInstructions']),
      sideEffects: _readString(json['sideEffects']),
      contraindications: _readString(json['contraindications']),
      aiAnalysis: _readString(json['aiAnalysis']),
      isSafe: json['isSafe'] is bool ? json['isSafe'] as bool : false,
      imageUrl: _readString(json['imageUrl']),
      manufacturer: _readString(json['manufacturer']),
      indications: _readStringList(json['indications']),
      warnings: _readStringList(json['warnings']),
      activeIngredients: _readStringList(json['activeIngredients']),
      filterTypes: _readStringList(json['filterTypes']),
      skinTypes: _readStringList(json['skinTypes']),
      containsAlcohol: _readNullableBool(json['containsAlcohol']),
      containsFragrance: _readNullableBool(json['containsFragrance']),
      sources: _readSources(json['sources']),
      lastReviewedAt: _readString(json['lastReviewedAt']),
    );
  }

  Map<String, dynamic> toAiContextJson() {
    return {
      'id': id,
      'brand': brand,
      'name': name,
      'category': category,
      'description': description,
      'ingredients': ingredients,
      'usageInstructions': usageInstructions,
      'sideEffects': sideEffects,
      'contraindications': contraindications,
      'manufacturer': manufacturer,
      'activeIngredients': activeIngredients,
      'indications': indications,
      'warnings': warnings,
      'filterTypes': filterTypes,
      'skinTypes': skinTypes,
      'containsAlcohol': containsAlcohol,
      'containsFragrance': containsFragrance,
    };
  }

  static String _readString(Object? value) {
    return value is String ? value.trim() : '';
  }

  static List<String> _readStringList(Object? value) {
    if (value is! List) {
      return const [];
    }
    return List.unmodifiable(
      value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty),
    );
  }

  static bool? _readNullableBool(Object? value) {
    return value is bool ? value : null;
  }

  static List<ProductSource> _readSources(Object? value) {
    if (value is! List) return const [];
    return List.unmodifiable(
      value
          .whereType<Map>()
          .map(
            (item) => ProductSource.fromJson(Map<String, dynamic>.from(item)),
          )
          .where((source) => source.title.isNotEmpty && source.url.isNotEmpty),
    );
  }
}
