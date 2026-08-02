import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../shared/widgets/product_image.dart';
import '../ai_analysis/data/remote_ai_analysis_service.dart';
import '../ai_analysis/presentation/widgets/ai_analysis_card.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({
    required this.productId,
    this.loadProducts,
    super.key,
  });

  final String productId;
  final Future<List<Product>> Function()? loadProducts;

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  late Future<List<Product>> _productsFuture;

  @override
  void initState() {
    super.initState();
    _productsFuture = _loadProducts();
  }

  Future<List<Product>> _loadProducts() {
    return widget.loadProducts?.call() ?? ProductService.loadProducts();
  }

  void _retry() {
    ProductService.clearCache();
    setState(() {
      _productsFuture = _loadProducts();
    });
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<Product>>(
      future: _productsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: const Text('Ürün detayı')),
            body: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.error_outline, size: 48),
                  const SizedBox(height: 12),
                  const Text('Ürün bilgileri yüklenemedi.'),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: _retry,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Yeniden dene'),
                  ),
                ],
              ),
            ),
          );
        }

        if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return const Scaffold(
            body: Center(child: Text('Henüz katalog verisi bulunmuyor.')),
          );
        }

        Product? product;
        for (final item in snapshot.data!) {
          if (item.id == widget.productId) {
            product = item;
            break;
          }
        }

        if (product == null) {
          return const Scaffold(body: Center(child: Text('Ürün bulunamadı.')));
        }

        return _ProductDetailContent(
          product: product,
          tumUrunler: snapshot.data!,
        );
      },
    );
  }
}

class _CompareBottomSheet extends StatefulWidget {
  const _CompareBottomSheet({required this.digerUrunler, required this.product});

  final List<Product> digerUrunler;
  final Product product;

  @override
  State<_CompareBottomSheet> createState() => _CompareBottomSheetState();
}

class _CompareBottomSheetState extends State<_CompareBottomSheet> {
  String aramaMetni = '';

  @override
  Widget build(BuildContext context) {
    final filtrelenmisList = widget.digerUrunler.where((u) {
      return u.name.toLowerCase().contains(aramaMetni.toLowerCase()) ||
          u.brand.toLowerCase().contains(aramaMetni.toLowerCase());
    }).toList();

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
        left: 20,
        right: 20,
        top: 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.sizeOf(context).height * 0.7,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Icon(Icons.compare_arrows, color: Colors.purple[700]),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Karşılaştırılacak Ürünü Seçin',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.purple[900],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            TextField(
              onChanged: (deger) => setState(() => aramaMetni = deger),
              decoration: InputDecoration(
                hintText: 'Ürün veya marka ara...',
                prefixIcon: const Icon(Icons.search),
                filled: true,
                fillColor: Colors.grey[100],
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none,
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
            ),
            const SizedBox(height: 12),
            Flexible(
              child: ListView.builder(
                shrinkWrap: true,
                itemCount: filtrelenmisList.length,
                itemBuilder: (context, index) {
                  final digerUrun = filtrelenmisList[index];
                  return Card(
                    elevation: 0,
                    color: Colors.grey[50],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey[200]!),
                    ),
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: Colors.amber[50],
                        child: Icon(
                          Icons.wb_sunny,
                          color: Colors.amber[400],
                          size: 20,
                        ),
                      ),
                      title: Text(
                        digerUrun.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        digerUrun.brand,
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.purple[300],
                      ),
                      onTap: () {
                        Navigator.pop(context);
                        context.push('/compare', extra: [widget.product, digerUrun]);
                      },
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}

class _ProductDetailContent extends StatefulWidget {
  const _ProductDetailContent({
    required this.product,
    required this.tumUrunler,
  });

  final Product product;
  final List<Product> tumUrunler;

  @override
  State<_ProductDetailContent> createState() => _ProductDetailContentState();
}

class _ProductDetailContentState extends State<_ProductDetailContent> {
  static final _aiAnalysisService = RemoteAiAnalysisService();
  String? seciliFiltreAciklamasi;

  String? _getFilterExplanation(String filter) {
    final lower = filter.toLowerCase();
    if (lower.contains('kimyasal')) {
      return 'Cilt tarafından emilerek zararlı UV ışınlarını zararsız ısıya dönüştürür. Dokusu genellikle daha hafiftir.';
    } else if (lower.contains('mineral') || lower.contains('fiziksel')) {
      return 'Cilt yüzeyinde koruyucu bir bariyer oluşturarak UV ışınlarını ayna gibi dışarı yansıtır.';
    } else if (lower.contains('hibrit')) {
      return 'Hem kimyasal hem de mineral filtrelerin özelliklerini bir arada sunar.';
    }
    return null;
  }

  void _karsilastirmaMenusuGoster(BuildContext context) {
    final digerUrunler = widget.tumUrunler
        .where((u) => u.isSunscreen && u.id != widget.product.id)
        .toList();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => _CompareBottomSheet(digerUrunler: digerUrunler, product: widget.product),
    );
  }

  @override
  Widget build(BuildContext context) {
    final product = widget.product;
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
        scrolledUnderElevation: 0,
        surfaceTintColor: Colors.transparent,
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
        padding: EdgeInsets.only(
          left: 20,
          right: 20,
          top: 20,
          bottom: MediaQuery.paddingOf(context).bottom + 40,
        ),
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
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: product.imageUrl.isEmpty
                    ? Icon(
                        isIlac ? Icons.medication : Icons.wb_sunny,
                        size: 72,
                        color: isIlac ? Colors.red[200] : Colors.amber[300],
                      )
                    : buildProductImage(
                        product: product,
                        fit: BoxFit.contain,
                        errorBuilder: (context, error, stackTrace) {
                          return Center(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  isIlac ? Icons.medication : Icons.wb_sunny,
                                  size: 72,
                                  color: Colors.grey[300],
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Görsel Yüklenemedi',
                                  style: TextStyle(
                                    color: Colors.grey[400],
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'Marka / Üretici Firma: ${product.displayManufacturer}',
                        style: TextStyle(
                          color: Colors.blue[800],
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                ),
                if (product.isSunscreen)
                  InkWell(
                    onTap: () => _karsilastirmaMenusuGoster(context),
                    borderRadius: BorderRadius.circular(8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.purple[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.purple[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.compare_arrows,
                            size: 16,
                            color: Colors.purple[800],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Karşılaştır',
                            style: TextStyle(
                              color: Colors.purple[800],
                              fontSize: 13,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
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
            AiAnalysisCard(product: product, service: _aiAnalysisService),
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
              children: product.primaryIngredients
                  .map(
                    (ingredient) {
                      final hasExplanation = _getFilterExplanation(ingredient) != null;
                      final isSelected = seciliFiltreAciklamasi != null && seciliFiltreAciklamasi == _getFilterExplanation(ingredient);
                      
                      return ActionChip(
                        label: Text(ingredient),
                        backgroundColor: isSelected ? Colors.blue[50] : Colors.white,
                        side: BorderSide(color: isSelected ? Colors.blue[300]! : Colors.grey[300]!),
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.blue[900] : Colors.black87,
                          fontWeight: FontWeight.w600,
                        ),
                        onPressed: hasExplanation ? () {
                          final exp = _getFilterExplanation(ingredient);
                          setState(() {
                            if (seciliFiltreAciklamasi == exp) {
                              seciliFiltreAciklamasi = null;
                            } else {
                              seciliFiltreAciklamasi = exp;
                            }
                          });
                        } : () {},
                      );
                    }
                  )
                  .toList(growable: false),
            ),
            if (seciliFiltreAciklamasi != null) ...[
              const SizedBox(height: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(Icons.lightbulb_outline, size: 20, color: Colors.blue[800]),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        seciliFiltreAciklamasi!,
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.blue[900],
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (product.sources.isNotEmpty) ...[
              const SizedBox(height: 32),
              const Text(
                'Bilgi Kaynakları',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                product.lastReviewedAt.isEmpty
                    ? 'İnceleme tarihi belirtilmemiştir.'
                    : 'Son içerik incelemesi: ${product.lastReviewedAt}',
                style: TextStyle(color: Colors.grey[700], fontSize: 13),
              ),
              const SizedBox(height: 8),
              ...product.sources.map(
                (source) => Card(
                  elevation: 0,
                  color: Colors.blue[50],
                  child: ListTile(
                    leading: const Icon(Icons.description_outlined),
                    title: Text(source.title),
                    subtitle: SelectableText(
                      source.url,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
              ),
            ],
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