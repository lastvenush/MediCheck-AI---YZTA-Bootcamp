import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/models/product.dart';

void main() {
  test('Product.fromJson handles missing and invalid values safely', () {
    final product = Product.fromJson({
      'id': 'test',
      'category': 'İlaç',
      'ingredients': [null, 3, ' Etken madde '],
      'isSafe': 'true',
    });

    expect(product.id, 'test');
    expect(product.brand, isEmpty);
    expect(product.ingredients, ['Etken madde']);
    expect(product.isSafe, isFalse);
    expect(product.isMedicine, isTrue);
    expect(product.sources, isEmpty);
    expect(product.containsAlcohol, isNull);
    expect(product.displayManufacturer, isEmpty);
  });

  test('Product.fromJson reads reviewed health data and sources', () {
    final product = Product.fromJson({
      'id': 'medicine',
      'brand': 'Marka',
      'manufacturer': 'Üretici',
      'category': 'İlaç',
      'ingredients': ['Eski alan'],
      'activeIngredients': ['Etken madde 10 mg'],
      'indications': ['Belirti tedavisi'],
      'warnings': ['Doktora danışın.'],
      'lastReviewedAt': '2026-07-29',
      'sources': [
        {'title': 'Resmî talimat', 'url': 'https://example.test/info.pdf'},
        {'title': '', 'url': 'https://example.test/invalid.pdf'},
      ],
    });

    expect(product.displayManufacturer, 'Üretici');
    expect(product.primaryIngredients, ['Etken madde 10 mg']);
    expect(product.indications, ['Belirti tedavisi']);
    expect(product.warnings, ['Doktora danışın.']);
    expect(product.sources, hasLength(1));
    expect(product.sources.single.title, 'Resmî talimat');
    expect(product.hasReviewedSources, isTrue);
  });
}
