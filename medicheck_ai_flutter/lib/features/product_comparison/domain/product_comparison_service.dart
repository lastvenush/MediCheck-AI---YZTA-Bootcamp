import '../../../models/product.dart';
import 'product_comparison_result.dart';

abstract interface class ProductComparisonService {
  Future<ProductComparisonResult> compare(Product first, Product second);
}
