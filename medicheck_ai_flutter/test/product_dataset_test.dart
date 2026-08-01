import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/services/product_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'medicine demo dataset has five reviewed and sourced products',
    () async {
      final products = await ProductService.loadProducts(useRemote: false);
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

  test(
    'sunscreen dataset has ten reviewed products and comparison fields',
    () async {
      final products = await ProductService.loadProducts(useRemote: false);
      final sunscreens = products
          .where((product) => product.isSunscreen)
          .toList();

      expect(products, hasLength(15));
      expect(sunscreens, hasLength(10));
      expect(sunscreens.map((product) => product.id).toSet(), hasLength(10));
      for (final sunscreen in sunscreens) {
        expect(sunscreen.filterTypes, isNotEmpty);
        expect(sunscreen.skinTypes, isNotEmpty);
        expect(sunscreen.hasReviewedSources, isTrue);
        for (final source in sunscreen.sources) {
          expect(Uri.parse(source.url).scheme, 'https');
        }
        final visibleText = [
          sunscreen.description,
          sunscreen.usageInstructions,
          sunscreen.contraindications,
          sunscreen.aiAnalysis,
        ].join(' ').toLowerCase();
        expect(visibleText, isNot(contains('tam koruma')));
        expect(visibleText, isNot(contains('kesin güvenli')));
        expect(visibleText, isNot(contains('risksiz')));
      }
    },
  );
}
