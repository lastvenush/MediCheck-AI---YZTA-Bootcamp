import 'package:flutter/material.dart';

import '../../../models/product.dart';
import '../../../services/product_service.dart';
import '../data/remote_product_comparison_service.dart';
import '../domain/product_comparison_result.dart';
import '../domain/product_comparison_service.dart';

class ProductComparisonScreen extends StatefulWidget {
  const ProductComparisonScreen({this.service, super.key});

  final ProductComparisonService? service;

  @override
  State<ProductComparisonScreen> createState() =>
      _ProductComparisonScreenState();
}

class _ProductComparisonScreenState extends State<ProductComparisonScreen> {
  late final ProductComparisonService _service;
  late final Future<List<Product>> _productsFuture;
  Product? _first;
  Product? _second;
  ProductComparisonResult? _result;
  bool _isComparing = false;

  @override
  void initState() {
    super.initState();
    _service = widget.service ?? RemoteProductComparisonService();
    _productsFuture = ProductService.loadProducts();
  }

  Future<void> _compare() async {
    final first = _first;
    final second = _second;
    if (first == null || second == null || first.id == second.id) return;
    setState(() {
      _isComparing = true;
      _result = null;
    });
    final result = await _service.compare(first, second);
    if (!mounted) return;
    setState(() {
      _isComparing = false;
      _result = result;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Ürün Karşılaştırma'),
        backgroundColor: Colors.grey[50],
      ),
      body: FutureBuilder<List<Product>>(
        future: _productsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final products =
              snapshot.data
                  ?.where((product) => product.isSunscreen)
                  .toList(growable: false) ??
              const <Product>[];
          if (snapshot.hasError || products.length < 2) {
            return const Center(
              child: Text('Karşılaştırılabilir ürünler yüklenemedi.'),
            );
          }
          return _buildContent(products);
        },
      ),
    );
  }

  Widget _buildContent(List<Product> products) {
    final canCompare =
        _first != null && _second != null && _first!.id != _second!.id;
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.blue[50],
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Text(
            'İki güneş koruyucuyu mevcut ürün alanlarına göre karşılaştırın. Sonuç kişisel uygunluk veya kesin güvenlik kararı değildir.',
            style: TextStyle(height: 1.45),
          ),
        ),
        const SizedBox(height: 18),
        _ProductPicker(
          key: const Key('comparison-first-picker'),
          label: 'Birinci ürün',
          value: _first,
          products: products,
          onChanged: (product) => setState(() {
            _first = product;
            _result = null;
          }),
        ),
        const SizedBox(height: 12),
        _ProductPicker(
          key: const Key('comparison-second-picker'),
          label: 'İkinci ürün',
          value: _second,
          products: products,
          onChanged: (product) => setState(() {
            _second = product;
            _result = null;
          }),
        ),
        const SizedBox(height: 16),
        FilledButton.icon(
          key: const Key('comparison-submit'),
          onPressed: canCompare && !_isComparing ? _compare : null,
          icon: const Icon(Icons.compare_arrows_rounded),
          label: const Text('Ürünleri karşılaştır'),
        ),
        if (_first != null && _second != null) ...[
          const SizedBox(height: 24),
          _ComparisonTable(first: _first!, second: _second!),
        ],
        if (_isComparing) ...[
          const SizedBox(height: 24),
          const Center(child: CircularProgressIndicator()),
        ],
        if (_result case final result?) ...[
          const SizedBox(height: 24),
          _AiComparisonCard(result: result),
        ],
      ],
    );
  }
}

class _ProductPicker extends StatelessWidget {
  const _ProductPicker({
    required this.label,
    required this.value,
    required this.products,
    required this.onChanged,
    super.key,
  });

  final String label;
  final Product? value;
  final List<Product> products;
  final ValueChanged<Product?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<Product>(
      initialValue: value,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
      ),
      items: products
          .map(
            (product) => DropdownMenuItem(
              value: product,
              child: Text('${product.brand} - ${product.name}'),
            ),
          )
          .toList(growable: false),
      onChanged: onChanged,
    );
  }
}

class _ComparisonTable extends StatelessWidget {
  const _ComparisonTable({required this.first, required this.second});

  final Product first;
  final Product second;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      color: Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _row('Ürün', first.name, second.name, isHeader: true),
            _row('Marka', first.brand, second.brand),
            _row(
              'Filtre',
              _list(first.primaryIngredients),
              _list(second.primaryIngredients),
            ),
            _row('Cilt tipi', _list(first.skinTypes), _list(second.skinTypes)),
            _row(
              'Alkol',
              _yesNoUnknown(first.containsAlcohol),
              _yesNoUnknown(second.containsAlcohol),
            ),
            _row(
              'Parfüm',
              _yesNoUnknown(first.containsFragrance),
              _yesNoUnknown(second.containsFragrance),
            ),
            _row(
              'Dikkat notu',
              first.contraindications,
              second.contraindications,
            ),
          ],
        ),
      ),
    );
  }

  Widget _row(
    String label,
    String firstValue,
    String secondValue, {
    bool isHeader = false,
  }) {
    final style = TextStyle(
      fontSize: 13,
      height: 1.35,
      fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
    );
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 74,
            child: Text(
              label,
              style: style.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(child: Text(firstValue, style: style)),
          const SizedBox(width: 12),
          Expanded(child: Text(secondValue, style: style)),
        ],
      ),
    );
  }

  static String _list(List<String> values) =>
      values.isEmpty ? 'Bilgi yok' : values.join(', ');

  static String _yesNoUnknown(bool? value) {
    if (value == null) return 'Bilgi yok';
    return value ? 'İçerir' : 'İçermez';
  }
}

class _AiComparisonCard extends StatelessWidget {
  const _AiComparisonCard({required this.result});

  final ProductComparisonResult result;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('comparison-result'),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.purple[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.purple[200]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'MediCheck AI Karşılaştırma Yorumu',
            style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(result.summary, style: const TextStyle(height: 1.45)),
          if (result.differences.isNotEmpty) ...[
            const SizedBox(height: 12),
            ...result.differences.map(
              (difference) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Text('• $difference'),
              ),
            ),
          ],
          const SizedBox(height: 12),
          Text(
            result.disclaimer,
            style: TextStyle(color: Colors.grey[700], fontSize: 12.5),
          ),
        ],
      ),
    );
  }
}
