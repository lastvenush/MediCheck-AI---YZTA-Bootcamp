import '../../catalog/domain/product.dart';
import 'ai_analysis_result.dart';

abstract interface class AiAnalysisService {
  Future<AiAnalysisResult> analyzeProduct(Product product);
}
