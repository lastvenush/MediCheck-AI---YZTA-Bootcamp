enum AiAnalysisSource {
  mock,
  gemini;

  static AiAnalysisSource fromJson(Object? value) {
    return value == 'gemini' ? AiAnalysisSource.gemini : AiAnalysisSource.mock;
  }
}

class AiAnalysisResult {
  const AiAnalysisResult({
    required this.shortSummary,
    required this.usagePurpose,
    required this.importantIngredients,
    required this.attentionPoints,
    required this.commonEffects,
    required this.disclaimer,
    this.source = AiAnalysisSource.mock,
  });

  static const String defaultDisclaimer =
      'Bu içerik yalnızca bilgilendirme amaçlıdır ve sağlık profesyoneli değerlendirmesinin yerine geçmez.';

  final String shortSummary;
  final String usagePurpose;
  final List<String> importantIngredients;
  final List<String> attentionPoints;
  final List<String> commonEffects;
  final String disclaimer;
  final AiAnalysisSource source;

  factory AiAnalysisResult.fromJson(Map<String, dynamic> json) {
    return AiAnalysisResult(
      shortSummary: _readString(
        json['shortSummary'],
        fallback: 'Bu ürün için özet bilgi bulunamadı.',
      ),
      usagePurpose: _readString(
        json['usagePurpose'],
        fallback: 'Kullanım amacı verisi bulunamadı.',
      ),
      importantIngredients: _readStringList(json['importantIngredients']),
      attentionPoints: _readStringList(json['attentionPoints']),
      commonEffects: _readStringList(json['commonEffects']),
      disclaimer: _readString(json['disclaimer'], fallback: defaultDisclaimer),
      source: AiAnalysisSource.fromJson(json['source']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'shortSummary': shortSummary,
      'usagePurpose': usagePurpose,
      'importantIngredients': importantIngredients,
      'attentionPoints': attentionPoints,
      'commonEffects': commonEffects,
      'disclaimer': disclaimer,
      'source': source.name,
    };
  }

  static String _readString(Object? value, {required String fallback}) {
    if (value is! String || value.trim().isEmpty) {
      return fallback;
    }
    return value.trim();
  }

  static List<String> _readStringList(Object? value) {
    if (value is! List) {
      return const [];
    }

    return List.unmodifiable(
      value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty),
    );
  }
}
