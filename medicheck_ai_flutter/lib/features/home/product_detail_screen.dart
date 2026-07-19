import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';

class ProductDetailScreen extends StatelessWidget {
  final String productId;

  const ProductDetailScreen({super.key, required this.productId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: ProductService.loadProducts(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        
        if (snapshot.hasError || !snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(body: Center(child: Text("Ürün bulunamadı.")));
        }

        final product = snapshot.data!.firstWhere(
          (p) => p.id == productId, 
          orElse: () => snapshot.data!.first
        );

        
        final bool isIlac = product.category == 'İlaç';

        final String sec1Title = isIlac ? 'Kullanım Şekli' : 'Cilt Tipi Uyumluluğu';
        final IconData sec1Icon = isIlac ? Icons.integration_instructions_rounded : Icons.face_retouching_natural;

        final String sec2Title = isIlac ? 'Yaygın Yan Etkiler' : 'İçerik Analizi';
        final IconData sec2Icon = isIlac ? Icons.personal_injury_rounded : Icons.science_outlined;

        final String sec3Title = isIlac ? 'Kontrendikasyon / Alerji' : 'Hassasiyet Notu';
        final IconData sec3Icon = isIlac ? Icons.block_flipped : Icons.info_outline_rounded;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            backgroundColor: Colors.grey[50],
            elevation: 0,
            iconTheme: IconThemeData(color: Colors.blue[900]),
            title: Text(product.category, style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.bold)),
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
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.1), blurRadius: 15, offset: const Offset(0, 5))],
                    image: DecorationImage(image: NetworkImage(product.imageUrl), fit: BoxFit.contain),
                  ),
                ),
                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(color: Colors.blue[50], borderRadius: BorderRadius.circular(8)),
                  child: Text('Marka / Üretici Firma: ${product.brand}', style: TextStyle(color: Colors.blue[800], fontSize: 13, fontWeight: FontWeight.bold)),
                ),
                const SizedBox(height: 12),
                Text(product.name, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -1, height: 1.2)),
                const SizedBox(height: 16),
                Text(product.description, style: const TextStyle(color: Colors.black87, fontSize: 16, height: 1.5)),
                const SizedBox(height: 24),

                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: product.isSafe ? Colors.green[50] : Colors.amber[50],
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: product.isSafe ? Colors.green[300]! : Colors.amber[300]!, width: 1.5),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(product.isSafe ? Icons.check_circle : Icons.warning_amber_rounded, color: product.isSafe ? Colors.green[700] : Colors.amber[700], size: 28),
                          const SizedBox(width: 12),
                          Text('MediCheck AI Analizi', style: TextStyle(color: product.isSafe ? Colors.green[900] : Colors.amber[900], fontSize: 18, fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(product.aiAnalysis, style: TextStyle(color: product.isSafe ? Colors.green[900] : Colors.black87, fontSize: 16, height: 1.6, fontWeight: product.isSafe ? FontWeight.w500 : FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 32),

                
                Text(isIlac ? 'Detaylı Kullanım ve Uyarılar' : 'Ürün Analizi ve Uyumluluk', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                
                // Dinamik Bilgi Kartları
                _buildInfoCard(title: sec1Title, content: product.usageInstructions, icon: sec1Icon, bgColor: Colors.blue[50]!, iconColor: Colors.blue[600]!),
                _buildInfoCard(title: sec2Title, content: product.sideEffects, icon: sec2Icon, bgColor: Colors.orange[50]!, iconColor: Colors.orange[700]!),
                _buildInfoCard(title: sec3Title, content: product.contraindications, icon: sec3Icon, bgColor: isIlac ? Colors.red[50]! : Colors.teal[50]!, iconColor: isIlac ? Colors.red[600]! : Colors.teal[700]!),
                const SizedBox(height: 24),

                Text(isIlac ? 'Etken Maddeler' : 'Filtre Tipi', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: product.ingredients.map((ingredient) => Chip(label: Text(ingredient), backgroundColor: Colors.white, side: BorderSide(color: Colors.grey[300]!), labelStyle: const TextStyle(color: Colors.black87, fontWeight: FontWeight.w600))).toList(),
                ),
                const SizedBox(height: 40),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.red[50], borderRadius: BorderRadius.circular(12), border: Border.all(color: Colors.red[200]!)),
                  child: const Text(
                    'YASAL UYARI: Bu uygulama bir tıbbi tavsiye niteliği taşımaz. Verilen bilgiler yapay zeka tarafından sağlanmıştır ve hata payı olabilir. Lütfen herhangi bir ilacı veya kremi kullanmadan önce mutlaka doktorunuza veya eczacınıza danışın.',
                    style: TextStyle(color: Colors.red, fontSize: 13, fontWeight: FontWeight.w600, height: 1.5),
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        );
      }
    );
  }

  Widget _buildInfoCard({required String title, required String content, required IconData icon, required Color bgColor, required Color iconColor}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(16)),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: iconColor, fontSize: 16)),
                const SizedBox(height: 6),
                Text(content, style: const TextStyle(color: Colors.black87, height: 1.5, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}