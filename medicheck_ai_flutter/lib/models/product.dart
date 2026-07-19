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

  bool get isMedicine => category == 'İlaç';
  bool get isSunscreen => category == 'Güneş Kremi';

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
    );
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
}
