import 'package:flutter/material.dart';
import '../../models/product.dart';

class CompareScreen extends StatelessWidget {
  const CompareScreen({
    required this.product1,
    required this.product2,
    super.key,
  });

  final Product product1;
  final Product product2;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue[900]),
        title: Text(
          'Ürün Karşılaştırma',
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildProductHeader(product1)),
                const SizedBox(width: 12),
                Expanded(child: _buildProductHeader(product2)),
              ],
            ),
            const SizedBox(height: 24),
            
           
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.grey[200]!),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildCompareRow('Filtre Tipi / İçerik', 
                      product1.ingredients.join(', '), 
                      product2.ingredients.join(', ')),
                  _buildCompareRow('Cilt Tipi Uyumu', 
                      product1.usageInstructions, 
                      product2.usageInstructions, 
                      isAlternate: true),
                  _buildCompareRow('Alkol / Parfüm', 
                      product1.sideEffects, 
                      product2.sideEffects),
                  _buildCompareRow('Dikkat Notu', 
                      product1.contraindications, 
                      product2.contraindications, 
                      isAlternate: true, 
                      isLast: true),
                ],
              ),
            ),
            const SizedBox(height: 32),

            
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [Colors.purple[50]!, Colors.blue[50]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: Colors.purple[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.auto_awesome, color: Colors.purple[700]),
                      const SizedBox(width: 8),
                      Text(
                        'AI Karşılaştırma Yorumu',
                        style: TextStyle(
                          color: Colors.purple[900],
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Text(
                    ' Mock AI servisi bağlandığında, bu iki ürünün kısa ve güvenli karşılaştırma yorumu burada görünecek.',
                    style: TextStyle(
                      color: Colors.purple[800],
                      height: 1.5,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildProductHeader(Product product) {
    return Column(
      children: [
        Container(
          height: 120,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey[200]!),
            image: product.imageUrl.isNotEmpty
                ? DecorationImage(
                    image: NetworkImage(product.imageUrl),
                    fit: BoxFit.contain,
                  )
                : null,
          ),
          child: product.imageUrl.isEmpty
              ? Center(
                  child: Icon(
                    product.isMedicine ? Icons.medication : Icons.wb_sunny,
                    size: 40,
                    color: product.isMedicine ? Colors.red[200] : Colors.amber[200],
                  ),
                )
              : null,
        ),
        const SizedBox(height: 12),
        Text(
          product.brand,
          style: TextStyle(
            color: Colors.blue[800],
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 4),
        Text(
          product.name,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            height: 1.2,
          ),
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildCompareRow(String title, String val1, String val2, {bool isAlternate = false, bool isLast = false}) {
    return Container(
      decoration: BoxDecoration(
        color: isAlternate ? Colors.grey[50] : Colors.white,
        border: isLast ? null : Border(bottom: BorderSide(color: Colors.grey[200]!)),
      ),
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Text(
              title,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.grey[600],
              ),
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  val1,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.grey[300],
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: Text(
                  val2,
                  style: const TextStyle(fontSize: 14, height: 1.4),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}