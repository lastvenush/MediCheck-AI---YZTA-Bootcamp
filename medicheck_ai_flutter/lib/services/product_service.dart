import 'dart:convert';
import 'package:flutter/services.dart';
import '../models/product.dart';

class ProductService {
  // JSON dosyasını okuyup ürün listesi döndüren asenkron fonksiyon
  static Future<List<Product>> loadProducts() async {
    try {
      // 1. assets klasöründeki dosyayı metin olarak oku
      final String jsonString = await rootBundle.loadString('assets/data/products.json');
      
      // 2. Metni JSON (Map/List) formatına çevir
      final List<dynamic> jsonList = json.decode(jsonString);
      
      // 3. Her bir JSON nesnesini Product sınıfına dönüştür ve listele
      return jsonList.map((json) => Product.fromJson(json)).toList();
    } catch (e) {
      print("JSON okuma hatası: $e");
      return []; // Hata olursa boş liste döndür ki uygulama çökmesin
    }
  }
}