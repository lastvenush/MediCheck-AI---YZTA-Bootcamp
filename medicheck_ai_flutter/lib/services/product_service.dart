import 'dart:convert';

import 'package:flutter/services.dart';

import '../models/product.dart';

abstract final class ProductService {
  static Future<List<Product>> loadProducts() async {
    try {
      final jsonString = await rootBundle.loadString(
        'assets/data/products.json',
      );
      final decoded = json.decode(jsonString);
      if (decoded is! List) {
        return const [];
      }

      return decoded
          .whereType<Map<String, dynamic>>()
          .map(Product.fromJson)
          .toList(growable: false);
    } on Object {
      return const [];
    }
  }
}
