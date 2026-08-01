import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/features/ai_assistant/data/mock_ai_assistant_service.dart';
import 'package:medicheck_ai_flutter/models/product.dart';

void main() {
  const service = MockAiAssistantService(delay: Duration.zero);

  test(
    'answers an ingredient question only from selected product data',
    () async {
      final response = await service.ask(
        question: 'Etken maddesi nedir?',
        products: const [_medicine],
        selectedProduct: _medicine,
      );

      expect(response.answer, contains('Deksketoprofen Trometamol'));
      expect(response.productId, _medicine.id);
      expect(response.wasBlocked, isFalse);
      expect(response.disclaimer, contains('doz önerisi değildir'));
    },
  );

  test('blocks dosage requests without repeating product dosage', () async {
    final response = await service.ask(
      question: 'Günde kaç tablet kullanmalıyım?',
      products: const [_medicine],
      selectedProduct: _medicine,
    );

    expect(response.wasBlocked, isTrue);
    expect(response.answer, contains('doz'));
    expect(response.answer, isNot(contains('8 saatte')));
  });

  test('asks for product context when no product can be matched', () async {
    final response = await service.ask(
      question: 'İçerikleri nelerdir?',
      products: const [_medicine],
    );

    expect(response.answer, contains('ürün seçin'));
    expect(response.productId, isNull);
  });
}

const _medicine = Product(
  id: 'i2',
  brand: 'Menarini',
  name: 'Arveles 25 mg Film Tablet',
  category: 'İlaç',
  description: 'Ağrı durumlarında kullanılan bir ilaçtır.',
  ingredients: ['Deksketoprofen Trometamol'],
  usageInstructions: '8 saatte bir 1 tablet alınır.',
  sideEffects: 'Mide bulantısı',
  contraindications: 'Doktora danışılmalıdır.',
  aiAnalysis: '',
  isSafe: false,
  imageUrl: '',
);
