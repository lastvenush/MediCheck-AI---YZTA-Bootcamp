class ProductComparisonResult {
  const ProductComparisonResult({
    required this.summary,
    required this.differences,
    required this.disclaimer,
  });

  final String summary;
  final List<String> differences;
  final String disclaimer;

  factory ProductComparisonResult.fromJson(Map<String, dynamic> json) {
    return ProductComparisonResult(
      summary: _readString(
        json['summary'],
        fallback: 'Karşılaştırma özeti oluşturulamadı.',
      ),
      differences: _readStringList(json['differences']),
      disclaimer: _readString(
        json['disclaimer'],
        fallback:
            'Bu karşılaştırma yalnızca bilgilendirme amaçlıdır; kişisel uygunluk kararı vermez.',
      ),
    );
  }

  static String _readString(Object? value, {required String fallback}) {
    return value is String && value.trim().isNotEmpty ? value.trim() : fallback;
  }

  static List<String> _readStringList(Object? value) {
    if (value is! List) return const [];
    return List.unmodifiable(
      value
          .whereType<String>()
          .map((item) => item.trim())
          .where((item) => item.isNotEmpty),
    );
  }
}
