import '../../../models/product.dart';
import '../../ai_analysis/domain/ai_safety_guard.dart';
import '../domain/ai_assistant_response.dart';
import '../domain/ai_assistant_service.dart';

class MockAiAssistantService implements AiAssistantService {
  const MockAiAssistantService({
    this.delay = const Duration(milliseconds: 450),
  });

  final Duration delay;

  @override
  Future<AiAssistantResponse> ask({
    required String question,
    required List<Product> products,
    Product? selectedProduct,
  }) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    final cleanQuestion = question.trim();
    if (cleanQuestion.isEmpty) {
      return const AiAssistantResponse(
        answer: 'Lütfen incelemek istediğiniz ürünle ilgili bir soru yazın.',
        disclaimer: AiSafetyGuard.medicineDisclaimer,
        suggestedQuestions: [],
        wasBlocked: true,
      );
    }

    final decision = AiSafetyGuard.evaluateQuestion(cleanQuestion);
    final product = selectedProduct ?? _findProduct(cleanQuestion, products);
    final disclaimer = product?.isMedicine == false
        ? AiSafetyGuard.cosmeticDisclaimer
        : AiSafetyGuard.medicineDisclaimer;

    if (decision.shouldBlock) {
      return AiAssistantResponse(
        answer: decision.message,
        disclaimer: disclaimer,
        suggestedQuestions: _suggestionsFor(product),
        productId: product?.id,
        wasBlocked: true,
      );
    }

    if (product == null) {
      return AiAssistantResponse(
        answer:
            'Soruyu yalnızca mevcut ürün verileriyle yanıtlayabilirim. Lütfen listeden bir ürün seçin veya ürün adını sorunuzda belirtin.',
        disclaimer: AiSafetyGuard.medicineDisclaimer,
        suggestedQuestions: const [
          'Bu ürünün önemli içerikleri neler?',
          'Dikkat noktaları neler?',
        ],
      );
    }

    return AiAssistantResponse(
      answer: _answerFor(cleanQuestion, product),
      disclaimer: disclaimer,
      suggestedQuestions: _suggestionsFor(product),
      productId: product.id,
    );
  }

  static Product? _findProduct(String question, List<Product> products) {
    final normalizedQuestion = AiSafetyGuard.normalize(question);
    for (final product in products) {
      final name = AiSafetyGuard.normalize(product.name);
      final brand = AiSafetyGuard.normalize(product.brand);
      if ((name.isNotEmpty && normalizedQuestion.contains(name)) ||
          (brand.isNotEmpty && normalizedQuestion.contains(brand))) {
        return product;
      }
    }
    return null;
  }

  static String _answerFor(String question, Product product) {
    final normalized = AiSafetyGuard.normalize(question);
    final name = product.name.trim().isEmpty ? 'Seçilen ürün' : product.name;

    if (_containsAny(normalized, const ['icerik', 'etken madde', 'filtre'])) {
      final ingredients = product.primaryIngredients.isEmpty
          ? 'Ürün verilerinde içerik bilgisi bulunmuyor.'
          : product.primaryIngredients.join(', ');
      return '$name için mevcut veride öne çıkan içerikler: $ingredients';
    }

    if (_containsAny(normalized, const [
      'yan etki',
      'hassasiyet',
      'reaksiyon',
    ])) {
      final effects = AiSafetyGuard.safeProductText(
        product.sideEffects,
        fallback: 'Bu alanda doğrulanabilir ürün verisi bulunmuyor.',
      );
      return '$name için mevcut etki veya hassasiyet bilgisi: $effects';
    }

    if (_containsAny(normalized, const ['uyari', 'dikkat', 'kimler'])) {
      final warning = AiSafetyGuard.safeProductText(
        product.warnings.isNotEmpty
            ? product.warnings.join(' • ')
            : product.contraindications,
        fallback:
            'Bu alandaki mevcut metin kesinlik içerdiği veya eksik olduğu için güvenli bir uyarı özeti sunulamıyor.',
      );
      return '$name için dikkat noktası: $warning';
    }

    final description = AiSafetyGuard.safeProductText(
      product.description,
      fallback: 'Bu ürün için güvenli bir özet bilgisi bulunmuyor.',
    );
    return '$name için mevcut ürün özeti: $description';
  }

  static List<String> _suggestionsFor(Product? product) {
    if (product == null) {
      return const [];
    }
    return product.isMedicine
        ? const [
            'Etken maddesi nedir?',
            'Mevcut uyarılar neler?',
            'Yaygın etkiler neler?',
          ]
        : const [
            'Filtre tipi nedir?',
            'Hassasiyet notları neler?',
            'Ürünü kısaca özetler misin?',
          ];
  }

  static bool _containsAny(String text, List<String> patterns) {
    return patterns.any(text.contains);
  }
}
