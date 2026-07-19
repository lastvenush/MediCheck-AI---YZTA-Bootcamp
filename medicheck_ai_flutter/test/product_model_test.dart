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
  });
}
