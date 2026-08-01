import '../models/product.dart';

abstract final class ProductFilter {
  static bool matchesQuery(Product product, String query) {
    final normalizedQuery = query.trim().toLowerCase();
    if (normalizedQuery.isEmpty) return true;

    final searchableFields = [
      product.name,
      product.brand,
      product.manufacturer,
      product.description,
      ...product.ingredients,
      ...product.activeIngredients,
      ...product.filterTypes,
      ...product.indications,
    ].join(' ').toLowerCase();
    return searchableFields.contains(normalizedQuery);
  }

  static bool matchesSubfilter(Product product, String filter) {
    switch (filter) {
      case '☀️ SPF50+':
        return '${product.name} ${product.description}'.toLowerCase().contains(
          'spf50+',
        );
      case '🌿 Parfümsüz':
        return product.containsFragrance == false;
      case '👶 Hassas Cilt':
        return _contains(product.skinTypes, 'hassas');
      case '✨ Yağlı Cilt':
        return _contains(product.skinTypes, 'yağlı');
      case '💧 Kuru Cilt':
        return _contains(product.skinTypes, 'kuru');
      case '🧴 Mineral Filtre':
        return _contains(product.filterTypes, 'mineral');
      case '💊 Ağrı / Ateş':
        return _contains(product.indications, 'ağrı') ||
            _contains(product.indications, 'ateş');
      case '🤧 Alerji':
        return _contains(product.indications, 'alerji') ||
            _contains(product.indications, 'nezle') ||
            _contains(product.indications, 'ürtiker');
      case '🩹 Spazm':
        return _contains(product.indications, 'spazm');
      case '':
        return true;
      default:
        return false;
    }
  }

  static bool _contains(Iterable<String> values, String query) {
    return values.any((value) => value.toLowerCase().contains(query));
  }
}
