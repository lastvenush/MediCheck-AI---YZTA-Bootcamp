import '../../../models/product.dart';
import 'ai_assistant_response.dart';

abstract interface class AiAssistantService {
  Future<AiAssistantResponse> ask({
    required String question,
    required List<Product> products,
    Product? selectedProduct,
  });
}
