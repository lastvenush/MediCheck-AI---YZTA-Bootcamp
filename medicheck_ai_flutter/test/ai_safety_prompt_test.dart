import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/features/ai_analysis/constants/ai_safety_prompt.dart';

void main() {
  test('system prompt contains the medical safety and JSON rules', () {
    expect(AiSafetyPrompt.systemPrompt, contains('Tıbbi tanı koyma'));
    expect(AiSafetyPrompt.systemPrompt, contains('İlaç dozu'));
    expect(AiSafetyPrompt.systemPrompt, contains('doktor veya eczacı'));
    expect(AiSafetyPrompt.systemPrompt, contains('"shortSummary"'));
    expect(AiSafetyPrompt.systemPrompt, contains('"disclaimer"'));
  });
}
