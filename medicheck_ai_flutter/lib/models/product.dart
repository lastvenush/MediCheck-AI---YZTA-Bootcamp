class Product {
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

  Product({
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

  
  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      brand: json['brand'] ?? '',
      name: json['name'] ?? '',
      category: json['category'] ?? '',
      description: json['description'] ?? '',
      
      ingredients: json['ingredients'] != null ? List<String>.from(json['ingredients']) : [],
      usageInstructions: json['usageInstructions'] ?? '',
      sideEffects: json['sideEffects'] ?? '',
      contraindications: json['contraindications'] ?? '',
      aiAnalysis: json['aiAnalysis'] ?? '',
      isSafe: json['isSafe'] ?? true,
      imageUrl: json['imageUrl'] ?? '',
    );
  }
}