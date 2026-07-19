import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/features/ai_analysis/domain/ai_analysis_result.dart';

void main() {
  group('AiAnalysisResult', () {
    test('fromJson reads valid values and toJson preserves them', () {
      final result = AiAnalysisResult.fromJson({
        'shortSummary': 'Kısa özet',
        'usagePurpose': 'Kullanım amacı',
        'importantIngredients': ['Etken madde'],
        'attentionPoints': ['Dikkat noktası'],
        'commonEffects': ['Yaygın etki'],
        'disclaimer': 'Bilgilendirme notu',
        'source': 'gemini',
      });

      expect(result.shortSummary, 'Kısa özet');
      expect(result.importantIngredients, ['Etken madde']);
      expect(result.source, AiAnalysisSource.gemini);
      expect(result.toJson()['source'], 'gemini');
      expect(result.toJson()['disclaimer'], 'Bilgilendirme notu');
    });

    test('fromJson uses safe defaults for missing and invalid fields', () {
      final result = AiAnalysisResult.fromJson({
        'shortSummary': null,
        'usagePurpose': '  ',
        'importantIngredients': null,
        'attentionPoints': [null, 12, '  ', 'Geçerli uyarı'],
        'commonEffects': 'liste değil',
        'disclaimer': '',
        'source': 'unknown',
      });

      expect(result.shortSummary, isNotEmpty);
      expect(result.usagePurpose, isNotEmpty);
      expect(result.importantIngredients, isEmpty);
      expect(result.attentionPoints, ['Geçerli uyarı']);
      expect(result.commonEffects, isEmpty);
      expect(result.disclaimer, AiAnalysisResult.defaultDisclaimer);
      expect(result.source, AiAnalysisSource.mock);
    });
  });
}
