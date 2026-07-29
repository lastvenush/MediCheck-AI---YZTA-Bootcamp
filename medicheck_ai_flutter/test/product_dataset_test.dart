import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/services/product_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'medicine demo dataset has five reviewed and sourced products',
    () async {
      final products = await ProductService.loadProducts();
      final medicines = products
          .where((product) => product.isMedicine)
          .toList();

      expect(medicines, hasLength(5));
      expect(medicines.map((product) => product.id).toSet(), hasLength(5));
      for (final medicine in medicines) {
        expect(medicine.activeIngredients, isNotEmpty);
        expect(medicine.indications, isNotEmpty);
        expect(medicine.warnings, isNotEmpty);
        expect(medicine.hasReviewedSources, isTrue);
        expect(
          medicine.usageInstructions.toLowerCase(),
          isNot(contains('günde')),
        );
      }
    },
  );

  test('sunscreen dataset has structured comparison fields', () async {
    final products = await ProductService.loadProducts();
    final sunscreens = products
        .where((product) => product.isSunscreen)
        .toList();

    expect(sunscreens, hasLength(5));
    for (final sunscreen in sunscreens) {
      expect(sunscreen.filterTypes, isNotEmpty);
      expect(sunscreen.skinTypes, isNotEmpty);
      expect(sunscreen.containsAlcohol, isNotNull);
      expect(sunscreen.containsFragrance, isNotNull);
    }
  });
}
