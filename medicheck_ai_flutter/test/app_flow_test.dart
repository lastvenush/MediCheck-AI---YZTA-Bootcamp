import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/app.dart';
import 'package:medicheck_ai_flutter/features/ai_analysis/data/mock_ai_analysis_service.dart';
import 'package:medicheck_ai_flutter/features/ai_analysis/domain/ai_analysis_result.dart';
import 'package:medicheck_ai_flutter/features/ai_analysis/domain/ai_analysis_service.dart';
import 'package:medicheck_ai_flutter/features/catalog/data/mock_products.dart';
import 'package:medicheck_ai_flutter/features/catalog/domain/product.dart';
import 'package:medicheck_ai_flutter/features/catalog/presentation/pages/product_detail_page.dart';

void main() {
  testWidgets('user opens a product and sees the AI analysis disclaimer', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MediCheckApp(
        aiAnalysisService: MockAiAnalysisService(delay: Duration.zero),
      ),
    );

    expect(find.text('MediCheck AI'), findsOneWidget);
    expect(find.byKey(const Key('product-search-field')), findsOneWidget);

    await tester.tap(find.byKey(const Key('product-card-arveles_25_mg')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('ai-analysis-card')),
      300,
    );
    await tester.pumpAndSettle();

    expect(find.text('MediCheck AI Analizi'), findsOneWidget);
    expect(find.byKey(const Key('ai-analysis-success')), findsOneWidget);
    expect(find.byKey(const Key('ai-analysis-disclaimer')), findsOneWidget);
  });

  testWidgets('AI analysis exposes a loading state', (tester) async {
    await tester.pumpWidget(
      MaterialApp(
        home: ProductDetailPage(
          product: MockProducts.all.first,
          aiAnalysisService: _PendingAiAnalysisService(),
        ),
      ),
    );

    await tester.scrollUntilVisible(
      find.byKey(const Key('ai-analysis-card')),
      300,
    );
    await tester.pump();

    expect(find.byKey(const Key('ai-analysis-loading')), findsOneWidget);
  });

  testWidgets('AI errors keep the page stable and show retry', (tester) async {
    await tester.pumpWidget(
      const MediCheckApp(aiAnalysisService: _FailingAiAnalysisService()),
    );

    await tester.tap(find.byKey(const Key('product-card-arveles_25_mg')));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byKey(const Key('ai-analysis-card')),
      300,
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('ai-analysis-error')), findsOneWidget);
    expect(find.byKey(const Key('ai-analysis-retry')), findsOneWidget);
    expect(find.text('Ürün detayı'), findsOneWidget);
  });
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
