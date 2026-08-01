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

Dio createCatalogDio() {
  return Dio(
    BaseOptions(
      baseUrl: AiApiConfig.baseUrl,
      connectTimeout: const Duration(seconds: 2),
      sendTimeout: const Duration(seconds: 3),
      receiveTimeout: const Duration(seconds: 5),
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

List<Map<String, dynamic>> readJsonList(Object? data) {
  if (data is! List) {
    throw const FormatException('API response is not a JSON list');
  }

  return data
      .map((item) {
        if (item is Map<String, dynamic>) return item;
        if (item is Map) return Map<String, dynamic>.from(item);
        throw const FormatException('API list contains a non-object item');
      })
      .toList(growable: false);
}
