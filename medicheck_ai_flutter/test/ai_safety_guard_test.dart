import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/features/ai_analysis/domain/ai_safety_guard.dart';

void main() {
  group('AiSafetyGuard', () {
    test('blocks dosage and diagnosis requests', () {
      expect(
        AiSafetyGuard.evaluateQuestion('Günde kaç tablet almalıyım?').risk,
        AiSafetyRisk.dosage,
      );
      expect(
        AiSafetyGuard.evaluateQuestion('Belirtilerime göre tanı koy').risk,
        AiSafetyRisk.diagnosis,
      );
    });

    test('allows grounded product information questions', () {
      final decision = AiSafetyGuard.evaluateQuestion(
        'Bu ürünün etken maddesi nedir?',
      );

      expect(decision.shouldBlock, isFalse);
    });

    test('rejects definitive safety language from product data', () {
      expect(
        AiSafetyGuard.containsDefinitiveClaim('Bu ürün tam koruma sağlar.'),
        isTrue,
      );
      expect(
        AiSafetyGuard.safeProductText(
          'Kesinlikle güvenlidir.',
          fallback: 'Güvenli fallback',
        ),
        'Güvenli fallback',
      );
    });
  });
}
