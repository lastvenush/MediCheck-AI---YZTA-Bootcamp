enum AiSafetyRisk { none, dosage, diagnosis, treatment, emergency }

class AiSafetyDecision {
  const AiSafetyDecision({required this.risk, required this.message});

  final AiSafetyRisk risk;
  final String message;

  bool get shouldBlock => risk != AiSafetyRisk.none;
}

abstract final class AiSafetyGuard {
  static const String medicineDisclaimer =
      'Bu yanıt yalnızca mevcut ürün verilerini açıklar; tanı, tedavi, reçete veya doz önerisi değildir. İlaçla ilgili kararlar için doktorunuza veya eczacınıza danışın.';

  static const String cosmeticDisclaimer =
      'Bu yanıt genel ürün verilerine dayanır ve dermatolojik değerlendirme yerine geçmez. Cilt hassasiyeti kişiden kişiye değişebilir.';

  static AiSafetyDecision evaluateQuestion(String question) {
    final normalized = normalize(question);

    if (_containsAny(normalized, const [
      'nefes alamiyorum',
      'nefes darligi',
      'bayildim',
      'bilinc kaybi',
      'siddetli alerji',
      'gogus agrisi',
    ])) {
      return const AiSafetyDecision(
        risk: AiSafetyRisk.emergency,
        message:
            'Bu soru acil değerlendirme gerektirebilecek bir durum içeriyor. Uygulama üzerinden yanıt beklemek yerine gecikmeden profesyonel acil yardım alın.',
      );
    }

    if (_containsAny(normalized, const [
      'kac tablet',
      'gunde kac',
      'doz',
      'dozaj',
      'ne kadar kullanmaliyim',
      'kac kere kullanmaliyim',
    ])) {
      return const AiSafetyDecision(
        risk: AiSafetyRisk.dosage,
        message:
            'Kişiye özel doz veya kullanım sıklığı öneremem. Ürünün resmi kullanım bilgilerini kontrol edin ve doktorunuza ya da eczacınıza danışın.',
      );
    }

    if (_containsAny(normalized, const [
      'tani koy',
      'hastaligim ne',
      'neyim var',
      'hangi hastalik',
    ])) {
      return const AiSafetyDecision(
        risk: AiSafetyRisk.diagnosis,
        message:
            'Belirtilerden tanı koyamam. Sağlık durumunuzun değerlendirilmesi için bir sağlık profesyoneline başvurun.',
      );
    }

    if (_containsAny(normalized, const [
      'hangi ilaci',
      'ne kullanmaliyim',
      'tedavi et',
      'recete yaz',
      'bana uygun mu',
    ])) {
      return const AiSafetyDecision(
        risk: AiSafetyRisk.treatment,
        message:
            'Tedavi, reçete veya kişiye özel ürün uygunluğu öneremem. Yalnızca seçilen ürünün mevcut bilgilerini açıklayabilirim.',
      );
    }

    return const AiSafetyDecision(risk: AiSafetyRisk.none, message: '');
  }

  static bool containsDefinitiveClaim(String text) {
    final normalized = normalize(text);
    return _containsAny(normalized, const [
      'kesinlikle',
      'kesinlikle guvenli',
      'tam koruma',
      'risksiz',
      'en dusuk alerji',
      'sana uygundur',
      'mutlaka kullan',
      'garanti eder',
      'yuzde 100 guvenli',
    ]);
  }

  static String safeProductText(String value, {required String fallback}) {
    final cleanValue = value.trim();
    if (cleanValue.isEmpty || containsDefinitiveClaim(cleanValue)) {
      return fallback;
    }
    return cleanValue;
  }

  static String normalize(String value) {
    return value
        .toLowerCase()
        .replaceAll('ı', 'i')
        .replaceAll('ğ', 'g')
        .replaceAll('ü', 'u')
        .replaceAll('ş', 's')
        .replaceAll('ö', 'o')
        .replaceAll('ç', 'c')
        .replaceAll('İ', 'i');
  }

  static bool _containsAny(String text, List<String> patterns) {
    return patterns.any(text.contains);
  }
}
