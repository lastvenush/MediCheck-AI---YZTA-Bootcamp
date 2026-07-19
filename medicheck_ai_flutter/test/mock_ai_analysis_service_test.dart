import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/features/ai_analysis/data/mock_ai_analysis_service.dart';
import 'package:medicheck_ai_flutter/models/product.dart';

void main() {
  const service = MockAiAnalysisService(delay: Duration.zero);

  group('MockAiAnalysisService', () {
    test('returns a meaningful and safe medicine analysis', () async {
      final result = await service.analyzeProduct(_medicine);

      expect(result.shortSummary, contains('ağrı'));
      expect(result.importantIngredients, ['Deksketoprofen Trometamol']);
      expect(result.attentionPoints, isNotEmpty);
      expect(result.commonEffects, contains('Mide bulantısı'));
      expect(result.disclaimer, contains('doz önerisi değildir'));
      expect(result.usagePurpose, isNot(contains('8 saatte bir')));
    });

    test('returns sunscreen-specific analysis fields', () async {
      final result = await service.analyzeProduct(_sunscreen);

      expect(result.importantIngredients, contains('SPF50+'));
      expect(
        result.attentionPoints.any((item) => item.contains('Alkol')),
        isTrue,
      );
      expect(result.disclaimer, contains('dermatolojik değerlendirme'));
    });

    test('returns safe fallback values when product data is missing', () async {
      const unknownProduct = Product(
        id: 'unknown',
        brand: '',
        name: '',
        category: 'İlaç',
        description: '',
        ingredients: [],
        usageInstructions: '',
        sideEffects: '',
        contraindications: '',
        aiAnalysis: '',
        isSafe: false,
        imageUrl: '',
      );

      final result = await service.analyzeProduct(unknownProduct);

      expect(result.shortSummary, isNotEmpty);
      expect(result.usagePurpose, isNotEmpty);
      expect(result.importantIngredients, isNotEmpty);
      expect(result.attentionPoints, isNotEmpty);
      expect(result.commonEffects, isNotEmpty);
      expect(result.disclaimer, isNotEmpty);
    });
  });
}

const _medicine = Product(
  id: 'i2',
  brand: 'Menarini',
  name: 'Arveles 25 mg Film Tablet',
  category: 'İlaç',
  description: 'Orta şiddetteki ağrılarda kullanılan bir ağrı kesicidir.',
  ingredients: ['Deksketoprofen Trometamol'],
  usageInstructions: '8 saatte bir 1 tablet alınır.',
  sideEffects: 'Mide bulantısı, baş ağrısı, karın ağrısı.',
  contraindications: 'Mide rahatsızlığı olan kişiler doktora danışmalıdır.',
  aiAnalysis: 'Eski statik analiz',
  isSafe: false,
  imageUrl: '',
);

const _sunscreen = Product(
  id: 'g1',
  brand: 'La Roche-Posay',
  name: 'Anthelios SPF50+',
  category: 'Güneş Kremi',
  description: 'SPF50+ yüksek koruma faktörlü güneş koruyucudur.',
  ingredients: ['Kimyasal Filtre'],
  usageInstructions: 'Hassas ciltler için formüle edilmiştir.',
  sideEffects: 'Alkol İçermez • Parfüm İçermez',
  contraindications: 'Cilt hassasiyeti kişiden kişiye değişebilir.',
  aiAnalysis: 'Eski statik analiz',
  isSafe: true,
  imageUrl: '',
);
