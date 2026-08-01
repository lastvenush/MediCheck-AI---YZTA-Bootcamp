import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/services/product_filter.dart';
import 'package:medicheck_ai_flutter/services/product_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('search covers brand and active ingredient', () async {
    final products = await ProductService.loadProducts(useRemote: false);

    expect(
      products.where((item) => ProductFilter.matchesQuery(item, 'Bayer')),
      isNotEmpty,
    );
    expect(
      products.where((item) => ProductFilter.matchesQuery(item, 'setirizin')),
      hasLength(1),
    );
  });

  test('every visible subfilter matches at least one catalog item', () async {
    final products = await ProductService.loadProducts(useRemote: false);
    const filters = [
      '☀️ SPF50+',
      '🌿 Parfümsüz',
      '👶 Hassas Cilt',
      '✨ Yağlı Cilt',
      '💧 Kuru Cilt',
      '🧴 Mineral Filtre',
      '💊 Ağrı / Ateş',
      '🤧 Alerji',
      '🩹 Spazm',
    ];

    for (final filter in filters) {
      expect(
        products.where((item) => ProductFilter.matchesSubfilter(item, filter)),
        isNotEmpty,
        reason: '$filter should match the Sprint 3 dataset',
      );
    }
  });
}
