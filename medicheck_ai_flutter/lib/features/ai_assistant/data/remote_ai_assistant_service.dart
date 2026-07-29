import 'package:dio/dio.dart';

import '../../../models/product.dart';
import '../../../services/ai_api_client.dart';
import '../domain/ai_assistant_response.dart';
import '../domain/ai_assistant_service.dart';
import 'mock_ai_assistant_service.dart';

class RemoteAiAssistantService implements AiAssistantService {
  RemoteAiAssistantService({Dio? dio, AiAssistantService? fallback})
    : _dio = dio ?? createAiDio(),
      _fallback =
          fallback ?? const MockAiAssistantService(delay: Duration.zero);

  final Dio _dio;
  final AiAssistantService _fallback;

  @override
  Future<AiAssistantResponse> ask({
    required String question,
    required List<Product> products,
    Product? selectedProduct,
  }) async {
    final product = selectedProduct ?? _findProduct(question, products);
    if (product == null) {
      return _fallback.ask(
        question: question,
        products: products,
        selectedProduct: selectedProduct,
      );
    }
    try {
      final response = await _dio.post<Object?>(
        '/ai/ask',
        data: {'question': question, 'product': product.toAiContextJson()},
      );
      return AiAssistantResponse.fromJson(readJsonObject(response.data));
    } on Object {
      return _fallback.ask(
        question: question,
        products: products,
        selectedProduct: product,
      );
    }
  }

  static Product? _findProduct(String question, List<Product> products) {
    final normalized = question.toLowerCase();
    for (final product in products) {
      if (normalized.contains(product.name.toLowerCase()) ||
          normalized.contains(product.brand.toLowerCase())) {
        return product;
      }
    }
    return null;
  }
}
