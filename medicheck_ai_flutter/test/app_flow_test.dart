import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/features/ai_analysis/data/mock_ai_analysis_service.dart';
import 'package:medicheck_ai_flutter/features/ai_analysis/domain/ai_analysis_result.dart';
import 'package:medicheck_ai_flutter/features/ai_analysis/domain/ai_analysis_service.dart';
import 'package:medicheck_ai_flutter/features/ai_analysis/presentation/widgets/ai_analysis_card.dart';
import 'package:medicheck_ai_flutter/models/product.dart';

void main() {
  testWidgets('analysis card displays successful result and disclaimer', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestHost(service: MockAiAnalysisService(delay: Duration.zero)),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-analysis-success')), findsOneWidget);
    expect(find.byKey(const Key('ai-analysis-disclaimer')), findsOneWidget);
    expect(find.text('Önemli içerikler'), findsOneWidget);
  });

  testWidgets('analysis card exposes a loading state', (tester) async {
    await tester.pumpWidget(_TestHost(service: _PendingAiAnalysisService()));
    await tester.pump();

    expect(find.byKey(const Key('ai-analysis-loading')), findsOneWidget);
  });

  testWidgets('analysis errors show retry without crashing the product UI', (
    tester,
  ) async {
    await tester.pumpWidget(
      const _TestHost(service: _FailingAiAnalysisService()),
    );
    await tester.pumpAndSettle();

    expect(find.text(_productName), findsOneWidget);
    expect(find.byKey(const Key('ai-analysis-error')), findsOneWidget);
    expect(find.byKey(const Key('ai-analysis-retry')), findsOneWidget);
  });
}

class _TestHost extends StatelessWidget {
  const _TestHost({required this.service});

  final AiAnalysisService service;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              const Text(_productName),
              const SizedBox(height: 12),
              AiAnalysisCard(product: _product, service: service),
            ],
          ),
        ),
      ),
    );
  }
}

class _PendingAiAnalysisService implements AiAnalysisService {
  final Completer<AiAnalysisResult> _completer = Completer<AiAnalysisResult>();

  @override
  Future<AiAnalysisResult> analyzeProduct(Product product) {
    return _completer.future;
  }
}

class _FailingAiAnalysisService implements AiAnalysisService {
  const _FailingAiAnalysisService();

  @override
  Future<AiAnalysisResult> analyzeProduct(Product product) {
    return Future<AiAnalysisResult>.error(
      StateError('Test için beklenen servis hatası'),
    );
  }
}

const _productName = 'Arveles 25 mg Film Tablet';

const _product = Product(
  id: 'i2',
  brand: 'Menarini',
  name: _productName,
  category: 'İlaç',
  description: 'Orta şiddetteki ağrılarda kullanılan bir ağrı kesicidir.',
  ingredients: ['Deksketoprofen Trometamol'],
  usageInstructions: 'Ürün kullanım verisi',
  sideEffects: 'Mide bulantısı',
  contraindications: 'Doktora danışılmalıdır.',
  aiAnalysis: 'Eski statik analiz',
  isSafe: false,
  imageUrl: '',
);
