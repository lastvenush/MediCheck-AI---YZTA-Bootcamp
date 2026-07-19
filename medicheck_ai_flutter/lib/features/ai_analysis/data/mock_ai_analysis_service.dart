import '../../../models/product.dart';
import '../domain/ai_analysis_result.dart';
import '../domain/ai_analysis_service.dart';

class MockAiAnalysisService implements AiAnalysisService {
  const MockAiAnalysisService({this.delay = const Duration(milliseconds: 650)});

  final Duration delay;

  @override
  Future<AiAnalysisResult> analyzeProduct(Product product) async {
    if (delay > Duration.zero) {
      await Future<void>.delayed(delay);
    }

    return product.isMedicine
        ? _analyzeMedicine(product)
        : _analyzeSunscreen(product);
  }

  AiAnalysisResult _analyzeMedicine(Product product) {
    return AiAnalysisResult(
      shortSummary: _fallbackText(
        product.description,
        '${_productName(product)} için sadeleştirilmiş ilaç bilgisi bulunamadı.',
      ),
      usagePurpose: _fallbackText(
        product.description,
        'Kullanım amacı ürün verilerinde belirtilmemiştir.',
      ),
      importantIngredients: _fallbackList(product.ingredients, const [
        'Etken madde bilgisi ürün verilerinde bulunmuyor.',
      ]),
      attentionPoints: _fallbackList(
        _asSingleItem(product.contraindications),
        const [
          'Kişisel sağlık durumu ve diğer ilaçlarla birlikte kullanım için doktor veya eczacıya danışılmalıdır.',
        ],
      ),
      commonEffects: _fallbackList(_splitItems(product.sideEffects), const [
        'Yaygın etki bilgisi ürün verilerinde bulunmuyor.',
      ]),
      disclaimer:
          'Bu analiz yalnızca mevcut ürün verilerini sadeleştirir; tanı, tedavi veya doz önerisi değildir. İlaç kullanımına ilişkin kararlar için doktorunuza veya eczacınıza danışın.',
    );
  }

  AiAnalysisResult _analyzeSunscreen(Product product) {
    final searchableText = '${product.name} ${product.description}';
    final spf = RegExp(
      r'SPF\s*\d+\+?',
      caseSensitive: false,
    ).firstMatch(searchableText)?.group(0);

    final importantIngredients = <String>[
      if (spf != null) spf.toUpperCase(),
      ...product.ingredients,
    ];

    final attentionPoints = <String>[
      ..._splitItems(product.sideEffects),
      ..._asSingleItem(product.contraindications),
    ];

    return AiAnalysisResult(
      shortSummary: _fallbackText(
        product.description,
        '${_productName(product)} için güneş koruyucu özeti bulunamadı.',
      ),
      usagePurpose: _fallbackText(
        product.description,
        'Ürünün kullanım amacı verilerde belirtilmemiştir.',
      ),
      importantIngredients: _fallbackList(importantIngredients, const [
        'Filtre veya içerik bilgisi ürün verilerinde bulunmuyor.',
      ]),
      attentionPoints: _fallbackList(attentionPoints, const [
        'Cilt hassasiyeti kişiden kişiye değişebilir; rahatsızlık halinde kullanım bırakılmalıdır.',
      ]),
      commonEffects: const [
        'Kişisel hassasiyete bağlı kızarıklık veya rahatsızlık oluşabilir.',
      ],
      disclaimer:
          'Bu analiz genel ürün verilerine dayanır ve dermatolojik değerlendirme yerine geçmez. Cilt hassasiyeti kişiden kişiye değişebilir.',
    );
  }

  static String _productName(Product product) {
    return product.name.trim().isEmpty ? 'Bu ürün' : product.name.trim();
  }

  static String _fallbackText(String value, String fallback) {
    return value.trim().isEmpty ? fallback : value.trim();
  }

  static List<String> _asSingleItem(String value) {
    final cleanValue = value.trim();
    return cleanValue.isEmpty ? const [] : [cleanValue];
  }

  static List<String> _splitItems(String value) {
    return value
        .split(RegExp(r'\s*[•,]\s*'))
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList(growable: false);
  }

  static List<String> _fallbackList(
    List<String> values,
    List<String> fallback,
  ) {
    final cleanValues = values
        .map((value) => value.trim())
        .where((value) => value.isNotEmpty)
        .toList(growable: false);
    return cleanValues.isEmpty ? fallback : cleanValues;
  }
}
