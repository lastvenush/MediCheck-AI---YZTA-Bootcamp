import 'package:flutter/material.dart';
import '../../models/product.dart';
import 'package:go_router/go_router.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: product.category == 'İlaç' ? Colors.red[50] : Colors.orange[50],
          child: Icon(
            product.category == 'İlaç' ? Icons.medication : Icons.wb_sunny,
            color: product.category == 'İlaç' ? Colors.red[400] : Colors.orange[400],
          ),
        ),
        title: Text(product.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4.0),
          child: Text('${product.brand} • ${product.category}'),
        ),
        trailing: product.isSafe 
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(Icons.warning_amber_rounded, color: Colors.amber, size: 28),
        onTap: () {
          // Router ile ID'yi gönderiyoruz
          context.push('/product/${product.id}');
        },
      ),
    );
  }
}