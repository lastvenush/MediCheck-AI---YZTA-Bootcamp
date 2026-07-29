import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/features/product_comparison/data/mock_product_comparison_service.dart';
import 'package:medicheck_ai_flutter/models/product.dart';

void main() {
  const service = MockProductComparisonService(delay: Duration.zero);

  test(
    'compares two different sunscreens without declaring a winner',
    () async {
      final result = await service.compare(_first, _second);

      expect(result.differences, hasLength(4));
      expect(result.summary, contains(_first.name));
      expect(result.summary, contains(_second.name));
      expect(result.summary, isNot(contains('daha iyi')));
      expect(result.disclaimer, contains('kişiden kişiye'));
    },
  );

  test('requires two different products', () async {
    final result = await service.compare(_first, _first);

    expect(result.differences, isEmpty);
    expect(result.summary, contains('iki farklı ürün'));
  });
}

const _first = Product(
  id: 'g1',
  brand: 'Marka A',
  name: 'Ürün A SPF50+',
  category: 'Güneş Kremi',
  description: 'Güneş koruyucu ürün.',
  ingredients: ['Kimyasal Filtre'],
  usageInstructions: 'Yağlı cilt bilgisi.',
  sideEffects: 'Parfüm içermez.',
  contraindications: 'Hassasiyet değişebilir.',
  aiAnalysis: '',
  isSafe: true,
  imageUrl: '',
);

const _second = Product(
  id: 'g2',
  brand: 'Marka B',
  name: 'Ürün B SPF50+',
  category: 'Güneş Kremi',
  description: 'Güneş koruyucu ürün.',
  ingredients: ['Mineral Filtre'],
  usageInstructions: 'Hassas cilt bilgisi.',
  sideEffects: 'Parfüm bilgisi yok.',
  contraindications: 'Yama testi düşünülebilir.',
  aiAnalysis: '',
  isSafe: true,
  imageUrl: '',
);
