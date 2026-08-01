import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/services/product_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('catalog combines product and medicine API responses', () async {
    final records =
        (jsonDecode(await rootBundle.loadString('assets/data/products.json'))
                as List)
            .cast<Map<String, dynamic>>();
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.httpClientAdapter = _CatalogAdapter(records: records);

    final result = await ProductService.loadCatalog(dio: dio);

    expect(result.source, ProductCatalogSource.api);
    expect(result.products, hasLength(15));
    expect(result.products.where((item) => item.isSunscreen), hasLength(10));
    expect(result.products.where((item) => item.isMedicine), hasLength(5));
  });

  test('catalog uses the bundled data when the API is unavailable', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.httpClientAdapter = const _FailingAdapter();

    final result = await ProductService.loadCatalog(dio: dio);

    expect(result.source, ProductCatalogSource.assetFallback);
    expect(result.products, hasLength(15));
  });

  test('catalog reports an error when API and asset both fail', () async {
    final dio = Dio(BaseOptions(baseUrl: 'https://example.test'));
    dio.httpClientAdapter = const _FailingAdapter();

    expect(
      ProductService.loadCatalog(dio: dio, bundle: _FailingAssetBundle()),
      throwsA(isA<ProductLoadException>()),
    );
  });
}

class _CatalogAdapter implements HttpClientAdapter {
  const _CatalogAdapter({required this.records});

  final List<Map<String, dynamic>> records;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    final category = options.path == '/medicines' ? 'İlaç' : 'Güneş Kremi';
    final payload = records
        .where((record) => record['category'] == category)
        .toList(growable: false);
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

class _FailingAdapter implements HttpClientAdapter {
  const _FailingAdapter();

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    return ResponseBody.fromString('unavailable', 503);
  }

  @override
  void close({bool force = false}) {}
}

class _FailingAssetBundle extends CachingAssetBundle {
  @override
  Future<ByteData> load(String key) {
    return Future<ByteData>.error(StateError('asset unavailable'));
  }
}
