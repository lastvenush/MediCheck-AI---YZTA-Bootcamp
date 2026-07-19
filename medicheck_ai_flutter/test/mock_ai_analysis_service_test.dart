import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/features/ai_analysis/data/mock_ai_analysis_service.dart';
import 'package:medicheck_ai_flutter/features/catalog/data/mock_products.dart';
import 'package:medicheck_ai_flutter/features/catalog/domain/product.dart';

void main() {
  const service = MockAiAnalysisService(delay: Duration.zero);

  group('MockAiAnalysisService', () {
    test('returns a meaningful and safe medicine analysis', () async {
      final medicine = MockProducts.all.firstWhere(
        (product) => product.type == ProductType.medicine,
      );

      final result = await service.analyzeProduct(medicine);

      expect(result.shortSummary, contains('Deksketoprofen'));
      expect(result.importantIngredients, isNotEmpty);
      expect(result.attentionPoints, isNotEmpty);
      expect(result.disclaimer, contains('doz önerisi değildir'));
    });

    test('returns sunscreen-specific analysis fields', () async {
      final sunscreen = MockProducts.all.firstWhere(
        (product) => product.type == ProductType.sunscreen,
      );

      final result = await service.analyzeProduct(sunscreen);

      expect(result.importantIngredients, contains('SPF 50+ koruma bilgisi'));
      expect(
        result.attentionPoints.any((item) => item.contains('Alkol')),
        isTrue,
      );
      expect(result.disclaimer, contains('dermatolojik değerlendirme'));
    });

    test('returns safe fallback values when product data is missing', () async {
      const unknownProduct = Product(
        id: 'unknown_medicine',
        type: ProductType.medicine,
        name: '',
        brand: '',
        shortDescription: '',
        usagePurpose: '',
      );

      final result = await service.analyzeProduct(unknownProduct);

      expect(result.shortSummary, isNotEmpty);
      expect(result.usagePurpose, isNotEmpty);
      expect(result.importantIngredients, isNotEmpty);
      expect(result.attentionPoints, isNotEmpty);
      expect(result.commonEffects, isNotEmpty);
      expect(result.disclaimer, isNotEmpty);
    });
  });
}
