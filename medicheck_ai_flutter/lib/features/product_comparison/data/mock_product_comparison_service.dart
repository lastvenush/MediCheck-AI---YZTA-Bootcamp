import '../../../models/product.dart';
import '../../ai_analysis/domain/ai_safety_guard.dart';
import '../domain/product_comparison_result.dart';
import '../domain/product_comparison_service.dart';

class MockProductComparisonService implements ProductComparisonService {
  const MockProductComparisonService({
    this.delay = const Duration(milliseconds: 400),
  });

  final Duration delay;

  @override
  Future<ProductComparisonResult> compare(Product first, Product second) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    if (!first.isSunscreen || !second.isSunscreen) {
      return const ProductComparisonResult(
        summary:
            'Bu demo karşılaştırması yalnızca iki güneş koruyucu ürün için hazırlanmıştır.',
        differences: [],
        disclaimer: AiSafetyGuard.cosmeticDisclaimer,
      );
    }

    if (first.id == second.id) {
      return const ProductComparisonResult(
        summary: 'Karşılaştırma için iki farklı ürün seçilmelidir.',
        differences: [],
        disclaimer: AiSafetyGuard.cosmeticDisclaimer,
      );
    }

    return ProductComparisonResult(
      summary:
          '${first.name} ve ${second.name}, yalnızca mevcut ürün alanlarına göre karşılaştırılmıştır. Bu karşılaştırma kişisel uygunluk veya kesin güvenlik kararı vermez.',
      differences: [
        _difference(
          'Filtre/içerik',
          first.primaryIngredients.join(', '),
          second.primaryIngredients.join(', '),
        ),
        _difference(
          'Cilt tipi bilgisi',
          first.skinTypes.isEmpty
              ? first.usageInstructions
              : first.skinTypes.join(', '),
          second.skinTypes.isEmpty
              ? second.usageInstructions
              : second.skinTypes.join(', '),
        ),
        _difference('Formül notu', first.sideEffects, second.sideEffects),
        _difference(
          'Dikkat noktası',
          first.contraindications,
          second.contraindications,
        ),
      ],
      disclaimer: AiSafetyGuard.cosmeticDisclaimer,
    );
  }

  static String _difference(String label, String first, String second) {
    final safeFirst = AiSafetyGuard.safeProductText(
      first,
      fallback: 'bilgi bulunmuyor',
    );
    final safeSecond = AiSafetyGuard.safeProductText(
      second,
      fallback: 'bilgi bulunmuyor',
    );
    return '$label: İlk ürün "$safeFirst"; ikinci ürün "$safeSecond" olarak belirtiliyor.';
  }
}
