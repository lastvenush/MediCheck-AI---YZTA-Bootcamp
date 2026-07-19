import 'package:flutter/material.dart';

import '../../models/product.dart';
import '../../services/product_service.dart';
import '../ai_analysis/data/mock_ai_analysis_service.dart';
import '../ai_analysis/presentation/widgets/ai_analysis_card.dart';

class ProductDetailScreen extends StatelessWidget {
  const ProductDetailScreen({required this.productId, super.key});

  final String productId;

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: ProductService.loadProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(body: Center(child: Text('Ürün bulunamadı.')));
        }

        Product? product;
        for (final item in snapshot.data!) {
          if (item.id == productId) {
            product = item;
            break;
          }
        }

        if (product == null) {
          return const Scaffold(body: Center(child: Text('Ürün bulunamadı.')));
        }

        return _ProductDetailContent(product: product);
      },
    );
  }
}

class _ProductDetailContent extends StatelessWidget {
  const _ProductDetailContent({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final isIlac = product.isMedicine;
    final sec1Title = isIlac ? 'Kullanım Şekli' : 'Cilt Tipi Uyumluluğu';
    final sec1Icon = isIlac
        ? Icons.integration_instructions_rounded
        : Icons.face_retouching_natural;
    final sec2Title = isIlac ? 'Yaygın Yan Etkiler' : 'İçerik Analizi';
    final sec2Icon = isIlac
        ? Icons.personal_injury_rounded
        : Icons.science_outlined;
    final sec3Title = isIlac ? 'Kontrendikasyon / Alerji' : 'Hassasiyet Notu';
    final sec3Icon = isIlac ? Icons.block_flipped : Icons.info_outline_rounded;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.blue[900]),
        title: Text(
          product.category,
          style: TextStyle(
            color: Colors.blue[900],
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              height: 250,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 15,
                    offset: const Offset(0, 5),
                  ),
                ],
                image: product.imageUrl.isEmpty
                    ? null
                    : DecorationImage(
                        image: NetworkImage(product.imageUrl),
                        fit: BoxFit.contain,
                      ),
              ),
              child: product.imageUrl.isEmpty
                  ? Icon(
                      isIlac ? Icons.medication : Icons.wb_sunny,
                      size: 72,
                      color: isIlac ? Colors.red[200] : Colors.amber[300],
                    )
                  : null,
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Marka / Üretici Firma: ${product.brand}',
                style: TextStyle(
                  color: Colors.blue[800],
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              product.name,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
                height: 1.2,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              product.description,
              style: const TextStyle(
                color: Colors.black87,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            AiAnalysisCard(
              product: product,
              service: const MockAiAnalysisService(),
            ),
            const SizedBox(height: 32),
            Text(
              isIlac
                  ? 'Detaylı Kullanım ve Uyarılar'
                  : 'Ürün Analizi ve Uyumluluk',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            _InfoCard(
              title: sec1Title,
              content: product.usageInstructions,
              icon: sec1Icon,
              backgroundColor: Colors.blue[50]!,
              iconColor: Colors.blue[600]!,
            ),
            _InfoCard(
              title: sec2Title,
              content: product.sideEffects,
              icon: sec2Icon,
              backgroundColor: Colors.orange[50]!,
              iconColor: Colors.orange[700]!,
            ),
            _InfoCard(
              title: sec3Title,
              content: product.contraindications,
              icon: sec3Icon,
              backgroundColor: isIlac ? Colors.red[50]! : Colors.teal[50]!,
              iconColor: isIlac ? Colors.red[600]! : Colors.teal[700]!,
            ),
            const SizedBox(height: 24),
            Text(
              isIlac ? 'Etken Maddeler' : 'Filtre Tipi',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: product.ingredients
                  .map(
                    (ingredient) => Chip(
                      label: Text(ingredient),
                      backgroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey[300]!),
                      labelStyle: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(height: 40),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red[200]!),
              ),
              child: const Text(
                'YASAL UYARI: Bu uygulama bir tıbbi tavsiye niteliği taşımaz. Verilen bilgiler yalnızca bilgilendirme amaçlıdır ve sağlık profesyoneli değerlendirmesinin yerine geçmez. İlaç kullanımıyla ilgili kararlar için doktorunuza veya eczacınıza danışın.',
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.content,
    required this.icon,
    required this.backgroundColor,
    required this.iconColor,
  });

  final String title;
  final String content;
  final IconData icon;
  final Color backgroundColor;
  final Color iconColor;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: iconColor,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  content,
                  style: const TextStyle(
                    color: Colors.black87,
                    height: 1.5,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
