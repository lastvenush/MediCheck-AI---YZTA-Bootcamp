import 'package:dio/dio.dart';

import '../../../models/product.dart';
import '../../../services/ai_api_client.dart';
import '../domain/product_comparison_result.dart';
import '../domain/product_comparison_service.dart';
import 'mock_product_comparison_service.dart';

class RemoteProductComparisonService implements ProductComparisonService {
  RemoteProductComparisonService({Dio? dio, ProductComparisonService? fallback})
    : _dio = dio ?? createAiDio(),
      _fallback =
          fallback ?? const MockProductComparisonService(delay: Duration.zero);

  final Dio _dio;
  final ProductComparisonService _fallback;

  @override
  Future<ProductComparisonResult> compare(Product first, Product second) async {
    try {
      final response = await _dio.post<Object?>(
        '/ai/compare-products',
        data: {
          'firstProduct': first.toAiContextJson(),
          'secondProduct': second.toAiContextJson(),
        },
      );
      return ProductComparisonResult.fromJson(readJsonObject(response.data));
    } on Object {
      return _fallback.compare(first, second);
    }
  }
}
