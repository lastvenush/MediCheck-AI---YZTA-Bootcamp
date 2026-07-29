class AiAssistantResponse {
  const AiAssistantResponse({
    required this.answer,
    required this.disclaimer,
    required this.suggestedQuestions,
    this.productId,
    this.wasBlocked = false,
  });

  final String answer;
  final String disclaimer;
  final List<String> suggestedQuestions;
  final String? productId;
  final bool wasBlocked;

  factory AiAssistantResponse.fromJson(Map<String, dynamic> json) {
    return AiAssistantResponse(
      answer: _readString(
        json['answer'],
        fallback: 'Bu soru için yanıt oluşturulamadı.',
      ),
      disclaimer: _readString(
        json['disclaimer'],
        fallback:
            'Bu içerik yalnızca bilgilendirme amaçlıdır ve sağlık profesyoneli değerlendirmesinin yerine geçmez.',
      ),
      suggestedQuestions: _readStringList(json['suggestedQuestions']),
      productId: json['productId'] is String
          ? json['productId'] as String
          : null,
      wasBlocked: json['wasBlocked'] is bool && json['wasBlocked'] as bool,
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
