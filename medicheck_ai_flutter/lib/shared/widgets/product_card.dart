import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';

class ProductCard extends StatelessWidget {
  const ProductCard({required this.product, super.key});

  final Product product;

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
          backgroundColor: product.isMedicine
              ? Colors.red[50]
              : Colors.orange[50],
          child: Icon(
            product.isMedicine ? Icons.medication : Icons.wb_sunny,
            color: product.isMedicine ? Colors.red[400] : Colors.orange[400],
          ),
        ),
        title: Text(
          product.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text('${product.brand} • ${product.category}'),
        ),
        trailing: product.isSafe
            ? const Icon(Icons.check_circle, color: Colors.green)
            : const Icon(
                Icons.warning_amber_rounded,
                color: Colors.amber,
                size: 28,
              ),
        onTap: () => context.push('/product/${product.id}'),
      ),
    );
  }
}
