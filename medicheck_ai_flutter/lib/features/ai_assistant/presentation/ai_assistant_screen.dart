import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../services/product_service.dart';
import '../../ai_analysis/domain/ai_safety_guard.dart';
import '../data/remote_ai_assistant_service.dart';
import '../domain/ai_assistant_response.dart';
import '../domain/ai_assistant_service.dart';

class AiAssistantScreen extends StatefulWidget {
  const AiAssistantScreen({this.service, super.key});

  final AiAssistantService? service;

  @override
  State<AiAssistantScreen> createState() => _AiAssistantScreenState();
}

class _AiAssistantScreenState extends State<AiAssistantScreen> {
  final TextEditingController _questionController = TextEditingController();
  late Future<List<Product>> _productsFuture;
  late final AiAssistantService _service;
  Product? _selectedProduct;
  AiAssistantResponse? _response;
  bool _isAnswering = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? RemoteAiAssistantService();
    _productsFuture = ProductService.loadProducts();
  }

  @override
  void dispose() {
    _questionController.dispose();
    super.dispose();
  }

  Future<void> _ask(List<Product> products, {String? question}) async {
    final nextQuestion = question ?? _questionController.text;
    if (question != null) {
      _questionController.text = question;
    }
    setState(() {
      _isAnswering = true;
      _response = null;
    });

    try {
      final response = await _service.ask(
        question: nextQuestion,
        products: products,
        selectedProduct: _selectedProduct,
      );
      if (!mounted) {
        return;
      }
      setState(() {
        _response = response;
        _isAnswering = false;
      });
    } on Object {
      if (!mounted) {
        return;
      }
      setState(() {
        _response = AiAssistantResponse(
          answer:
              'Yanıt şu anda oluşturulamıyor. Lütfen daha sonra tekrar deneyin.',
          disclaimer: _selectedProduct?.isMedicine == false
              ? AiSafetyGuard.cosmeticDisclaimer
              : AiSafetyGuard.medicineDisclaimer,
          suggestedQuestions: const [],
          productId: _selectedProduct?.id,
          wasBlocked: true,
        );
        _isAnswering = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        title: Text(
          'MediCheck Asistan',
          style: TextStyle(
            color: Colors.purple[900],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError ||
              !snapshot.hasData ||
              snapshot.data!.isEmpty) {
            return _LoadError(
              onRetry: () {
                setState(() {
                  _productsFuture = ProductService.loadProducts();
                });
              },
            );
          }
          return _buildAssistant(snapshot.requireData);
        },
      ),
    );
  }

  Widget _buildAssistant(List<Product> products) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.purple[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.purple[100]!),
          ),
          child: const Text(
            'Bir ürün seçin ve yalnızca mevcut ürün verileri hakkında soru sorun. Asistan tanı, tedavi, reçete, doz veya kişisel uygunluk önerisi vermez.',
            style: TextStyle(height: 1.45),
          ),
        ),
        const SizedBox(height: 18),
        DropdownButtonFormField<Product>(
          key: const Key('ai-assistant-product-picker'),
          initialValue: _selectedProduct,
          isExpanded: true,
          decoration: const InputDecoration(
            labelText: 'Ürün bağlamı',
            border: OutlineInputBorder(),
          ),
          hint: const Text('Bir ürün seçin'),
          items: products
              .map(
                (product) => DropdownMenuItem<Product>(
                  value: product,
                  child: Text('${product.brand} - ${product.name}'),
                ),
              )
              .toList(growable: false),
          onChanged: (product) {
            setState(() {
              _selectedProduct = product;
              _response = null;
            });
          },
        ),
        const SizedBox(height: 14),
        TextField(
          key: const Key('ai-assistant-question'),
          controller: _questionController,
          minLines: 2,
          maxLines: 4,
          textInputAction: TextInputAction.done,
          decoration: const InputDecoration(
            labelText: 'Sorunuz',
            hintText: 'Örneğin: Bu ürünün önemli içerikleri neler?',
            border: OutlineInputBorder(),
          ),
          onSubmitted: _isAnswering ? null : (_) => _ask(products),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          key: const Key('ai-assistant-submit'),
          onPressed: _isAnswering ? null : () => _ask(products),
          icon: const Icon(Icons.auto_awesome),
          label: const Text('Güvenli yanıt oluştur'),
        ),
        if (_isAnswering) ...[
          const SizedBox(height: 24),
          const Center(
            child: Column(
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 10),
                Text('Mevcut ürün verileri inceleniyor...'),
              ],
            ),
          ),
        ],
        if (_response case final response?) ...[
          const SizedBox(height: 22),
          _ResponseCard(response: response),
          if (response.suggestedQuestions.isNotEmpty) ...[
            const SizedBox(height: 18),
            const Text(
              'Güvenli örnek sorular',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: response.suggestedQuestions
                  .map(
                    (question) => ActionChip(
                      label: Text(question),
                      onPressed: _isAnswering
                          ? null
                          : () => _ask(products, question: question),
                    ),
                  )
                  .toList(growable: false),
            ),
          ],
        ],
      ],
    );
  }
}

class _ResponseCard extends StatelessWidget {
  const _ResponseCard({required this.response});

  final AiAssistantResponse response;

  @override
  Widget build(BuildContext context) {
    final color = response.wasBlocked ? Colors.orange : Colors.blue;
    return Container(
      key: const Key('ai-assistant-response'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: color[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                response.wasBlocked
                    ? Icons.health_and_safety_outlined
                    : Icons.auto_awesome,
                color: color[700],
              ),
              const SizedBox(width: 8),
              Text(
                response.wasBlocked ? 'Güvenli yönlendirme' : 'Ürün yanıtı',
                style: TextStyle(
                  color: color[900],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(response.answer, style: const TextStyle(height: 1.5)),
          const SizedBox(height: 16),
          Text(
            response.disclaimer,
            key: const Key('ai-assistant-disclaimer'),
            style: TextStyle(
              color: Colors.grey[700],
              fontSize: 12.5,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

class _LoadError extends StatelessWidget {
  const _LoadError({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, size: 44),
          const SizedBox(height: 12),
          const Text('Ürün verileri yüklenemedi.'),
          TextButton(onPressed: onRetry, child: const Text('Tekrar dene')),
        ],
      ),
    );
  }
}
