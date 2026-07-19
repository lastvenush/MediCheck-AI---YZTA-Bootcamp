import '../../catalog/domain/product.dart';
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

    return switch (product.type) {
      ProductType.medicine => _analyzeMedicine(product),
      ProductType.sunscreen => _analyzeSunscreen(product),
    };
  }

  AiAnalysisResult _analyzeMedicine(Product product) {
    return AiAnalysisResult(
      shortSummary: _fallbackText(
        product.shortDescription,
        '${_productName(product)} için sadeleştirilmiş ilaç bilgisi bulunamadı.',
      ),
      usagePurpose: _fallbackText(
        product.usagePurpose,
        'Kullanım amacı ürün verilerinde belirtilmemiştir.',
      ),
      importantIngredients: _fallbackList(product.importantIngredients, const [
        'Etken madde bilgisi ürün verilerinde bulunmuyor.',
      ]),
      attentionPoints: _fallbackList(product.attentionPoints, const [
        'Kişisel sağlık durumu ve diğer ilaçlarla birlikte kullanım için doktor veya eczacıya danışılmalıdır.',
      ]),
      commonEffects: _fallbackList(product.commonEffects, const [
        'Yaygın etki bilgisi ürün verilerinde bulunmuyor.',
      ]),
      disclaimer:
          'Bu analiz yalnızca mevcut ürün verilerini sadeleştirir; tanı, tedavi veya doz önerisi değildir. İlaç kullanımına ilişkin kararlar için doktorunuza veya eczacınıza danışın.',
    );
  }

  AiAnalysisResult _analyzeSunscreen(Product product) {
    final attributes = <String>[
      if (product.spf != null) 'SPF ${product.spf}+ koruma bilgisi',
      if (_hasText(product.filterType)) product.filterType!.trim(),
      ...product.importantIngredients,
    ];

    final attentionPoints = <String>[
      if (_hasText(product.skinType))
        'Hedef cilt tipi: ${product.skinType!.trim()}.',
      if (product.containsAlcohol == true)
        'Alkol içerdiği belirtilmiştir; çok hassas ciltlerde rahatsızlık oluşturabilir.',
      if (product.containsAlcohol == false)
        'Ürün verisinde alkol bulunmadığı belirtilmiştir.',
      if (product.containsFragrance == true)
        'Parfüm içerdiği belirtilmiştir; koku hassasiyeti olan kişiler dikkat etmelidir.',
      if (product.containsFragrance == false)
        'Ürün verisinde parfüm bulunmadığı belirtilmiştir.',
      ...product.attentionPoints,
    ];

    return AiAnalysisResult(
      shortSummary: _fallbackText(
        product.shortDescription,
        '${_productName(product)} için güneş koruyucu özeti bulunamadı.',
      ),
      usagePurpose: _fallbackText(
        product.usagePurpose,
        'Ürünün kullanım amacı verilerde belirtilmemiştir.',
      ),
      importantIngredients: _fallbackList(attributes, const [
        'Filtre veya içerik bilgisi ürün verilerinde bulunmuyor.',
      ]),
      attentionPoints: _fallbackList(attentionPoints, const [
        'Cilt hassasiyeti kişiden kişiye değişebilir; rahatsızlık halinde kullanım bırakılmalıdır.',
      ]),
      commonEffects: _fallbackList(product.commonEffects, const [
        'Kişisel hassasiyete bağlı kızarıklık veya rahatsızlık oluşabilir.',
      ]),
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

  static bool _hasText(String? value) {
    return value != null && value.trim().isNotEmpty;
  }
}
