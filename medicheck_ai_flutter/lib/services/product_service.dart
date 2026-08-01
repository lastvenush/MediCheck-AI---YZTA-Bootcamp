import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter/services.dart';

import '../models/product.dart';
import 'ai_api_client.dart';

enum ProductCatalogSource { api, assetFallback }

class ProductCatalogResult {
  const ProductCatalogResult({required this.products, required this.source});

  final List<Product> products;
  final ProductCatalogSource source;
}

class ProductLoadException implements Exception {
  const ProductLoadException(this.message);

  final String message;

  @override
  String toString() => message;
}

abstract final class ProductService {
  static const _assetPath = 'assets/data/products.json';
  static ProductCatalogResult? _cachedCatalog;

  static void clearCache() {
    _cachedCatalog = null;
  }

  static Future<List<Product>> loadProducts({
    Dio? dio,
    AssetBundle? bundle,
    bool useRemote = true,
  }) async {
    final result = await loadCatalog(
      dio: dio,
      bundle: bundle,
      useRemote: useRemote,
    );
    return result.products;
  }

  static Future<ProductCatalogResult> loadCatalog({
    Dio? dio,
    AssetBundle? bundle,
    bool useRemote = true,
  }) async {
    final canUseCache = dio == null && bundle == null && useRemote;
    if (canUseCache && _cachedCatalog != null) return _cachedCatalog!;

    Object? remoteError;

    if (useRemote) {
      try {
        final products = await _loadFromApi(dio ?? createCatalogDio());
        final result = ProductCatalogResult(
          products: products,
          source: ProductCatalogSource.api,
        );
        if (canUseCache) _cachedCatalog = result;
        return result;
      } on Object catch (error) {
        remoteError = error;
      }
    }

    try {
      final products = await _loadFromAsset(bundle ?? rootBundle);
      final result = ProductCatalogResult(
        products: products,
        source: ProductCatalogSource.assetFallback,
      );
      if (canUseCache) _cachedCatalog = result;
      return result;
    } on Object catch (assetError) {
      final remoteMessage = remoteError == null
          ? ''
          : ' API hatası: $remoteError.';
      throw ProductLoadException(
        'Ürün kataloğu yüklenemedi.$remoteMessage Yerel veri hatası: '
        '$assetError.',
      );
    }
  }

  static Future<List<Product>> _loadFromApi(Dio dio) async {
    final responses = await Future.wait([
      dio.get<Object?>('/products'),
      dio.get<Object?>('/medicines'),
    ]);
    final records = [
      ...readJsonList(responses[0].data),
      ...readJsonList(responses[1].data),
    ];
    return _parseAndValidate(records);
  }

  static Future<List<Product>> _loadFromAsset(AssetBundle bundle) async {
    final jsonString = await bundle.loadString(_assetPath);
    final decoded = json.decode(jsonString);
    return _parseAndValidate(readJsonList(decoded));
  }

  static List<Product> _parseAndValidate(List<Map<String, dynamic>> records) {
    final products = records.map(Product.fromJson).toList(growable: false);
    final ids = products.map((product) => product.id).toSet();

    if (products.isEmpty) {
      throw const FormatException('Ürün kataloğu boş');
    }
    if (ids.length != products.length || ids.contains('')) {
      throw const FormatException('Ürün kimlikleri eksik veya tekrarlı');
    }
    if (products.where((product) => product.isSunscreen).length < 10 ||
        products.where((product) => product.isMedicine).length < 5) {
      throw const FormatException(
        'Katalog en az 10 güneş kremi ve 5 ilaç içermelidir',
      );
    }

    return List<Product>.unmodifiable(products);
  }
}
