enum ProductType {
  medicine,
  sunscreen;

  String get label => switch (this) {
    ProductType.medicine => 'İlaç',
    ProductType.sunscreen => 'Güneş koruyucu',
  };
}

class Product {
  const Product({
    required this.id,
    required this.type,
    required this.name,
    required this.brand,
    required this.shortDescription,
    required this.usagePurpose,
    this.importantIngredients = const [],
    this.attentionPoints = const [],
    this.commonEffects = const [],
    this.tags = const [],
    this.spf,
    this.filterType,
    this.skinType,
    this.containsAlcohol,
    this.containsFragrance,
  });

  final String id;
  final ProductType type;
  final String name;
  final String brand;
  final String shortDescription;
  final String usagePurpose;
  final List<String> importantIngredients;
  final List<String> attentionPoints;
  final List<String> commonEffects;
  final List<String> tags;
  final int? spf;
  final String? filterType;
  final String? skinType;
  final bool? containsAlcohol;
  final bool? containsFragrance;
}
