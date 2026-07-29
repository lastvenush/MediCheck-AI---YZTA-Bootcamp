import 'package:dio/dio.dart';

abstract final class AiApiConfig {
  static const baseUrl = String.fromEnvironment(
    'MEDICHECK_API_BASE_URL',
    defaultValue: 'http://127.0.0.1:8000',
  );
}

Dio createAiDio() {
  return Dio(
    BaseOptions(
      baseUrl: AiApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 2),
      sendTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 20),
      contentType: Headers.jsonContentType,
      responseType: ResponseType.json,
    ),
  );
}

Map<String, dynamic> readJsonObject(Object? data) {
  if (data is Map<String, dynamic>) return data;
  if (data is Map) return Map<String, dynamic>.from(data);
  throw const FormatException('AI API response is not a JSON object');
}
