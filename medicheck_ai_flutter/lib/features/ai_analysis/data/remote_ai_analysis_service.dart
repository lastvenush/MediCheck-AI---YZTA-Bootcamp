import 'package:dio/dio.dart';

import '../../../models/product.dart';
import '../../../services/ai_api_client.dart';
import '../domain/ai_analysis_result.dart';
import '../domain/ai_analysis_service.dart';
import 'mock_ai_analysis_service.dart';

class RemoteAiAnalysisService implements AiAnalysisService {
  RemoteAiAnalysisService({Dio? dio, AiAnalysisService? fallback})
    : _dio = dio ?? createAiDio(),
      _fallback = fallback ?? const MockAiAnalysisService(delay: Duration.zero);

  final Dio _dio;
  final AiAnalysisService _fallback;

  @override
  Future<AiAnalysisResult> analyzeProduct(Product product) async {
    try {
      final response = await _dio.post<Object?>(
        '/ai/analyze',
        data: {'product': product.toAiContextJson()},
      );
      return AiAnalysisResult.fromJson(readJsonObject(response.data));
    } on Object {
      return _fallback.analyzeProduct(product);
    }
  }
}
