import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/features/ai_analysis/data/remote_ai_analysis_service.dart';
import 'package:medicheck_ai_flutter/features/ai_assistant/data/remote_ai_assistant_service.dart';
import 'package:medicheck_ai_flutter/features/product_comparison/data/remote_product_comparison_service.dart';
import 'package:medicheck_ai_flutter/models/product.dart';

void main() {
  test('remote analysis maps the API response', () async {
    final dio = _dioWithResponse({
      'shortSummary': 'Uzak özet',
      'usagePurpose': 'Genel amaç',
      'importantIngredients': ['Etken madde'],
      'attentionPoints': ['Dikkat notu'],
      'commonEffects': ['Etki bilgisi'],
      'disclaimer': 'Bilgilendirme amaçlıdır.',
      'source': 'gemini',
    });

    final result = await RemoteAiAnalysisService(
      dio: dio,
    ).analyzeProduct(firstProduct);

    expect(result.shortSummary, 'Uzak özet');
    expect(result.source.name, 'gemini');
  });

  test('remote assistant maps the API response', () async {
    final dio = _dioWithResponse({
      'answer': 'Uzak yanıt',
      'suggestedQuestions': ['Uyarılar neler?'],
      'disclaimer': 'Bilgilendirme amaçlıdır.',
      'productId': 'g1',
      'wasBlocked': false,
    });

    final result = await RemoteAiAssistantService(dio: dio).ask(
      question: 'İçerikleri neler?',
      products: [firstProduct],
      selectedProduct: firstProduct,
    );

    expect(result.answer, 'Uzak yanıt');
    expect(result.productId, 'g1');
  });

  test('remote comparison maps the API response', () async {
    final dio = _dioWithResponse({
      'summary': 'Uzak karşılaştırma',
      'differences': ['Filtreler farklıdır.'],
      'disclaimer': 'Kişisel uygunluk kararı değildir.',
    });

    final result = await RemoteProductComparisonService(
      dio: dio,
    ).compare(firstProduct, secondProduct);

    expect(result.summary, 'Uzak karşılaştırma');
    expect(result.differences, ['Filtreler farklıdır.']);
  });
}

Dio _dioWithResponse(Map<String, dynamic> payload) {
  final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
  dio.httpClientAdapter = _StubAdapter(payload);
  return dio;
}

class _StubAdapter implements HttpClientAdapter {
  _StubAdapter(this.payload);

  final Map<String, dynamic> payload;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString(
      jsonEncode(payload),
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

const firstProduct = Product(
  id: 'g1',
  brand: 'Marka A',
  name: 'Ürün A',
  category: 'Güneş Kremi',
  description: 'Açıklama',
  ingredients: ['Kimyasal filtre'],
  usageInstructions: 'Yağlı cilt',
  sideEffects: 'Parfüm içermez',
  contraindications: 'Hassasiyet değişebilir',
  aiAnalysis: '',
  isSafe: false,
  imageUrl: '',
);

const secondProduct = Product(
  id: 'g2',
  brand: 'Marka B',
  name: 'Ürün B',
  category: 'Güneş Kremi',
  description: 'Açıklama',
  ingredients: ['Mineral filtre'],
  usageInstructions: 'Hassas cilt',
  sideEffects: 'Parfüm bilgisi yok',
  contraindications: 'Hassasiyet değişebilir',
  aiAnalysis: '',
  isSafe: false,
  imageUrl: '',
);
