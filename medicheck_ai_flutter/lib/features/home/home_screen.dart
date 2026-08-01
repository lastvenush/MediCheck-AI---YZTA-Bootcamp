import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';
import '../../services/product_filter.dart';
import '../../services/product_service.dart';
import '../../shared/widgets/product_card.dart';
import '../ai_assistant/presentation/ai_assistant_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String aramaMetni = '';
  String seciliKategori = 'Tümü';
  String seciliAltFiltre = '';
  List<Product> tumUrunler = [];
  bool yukleniyorMu = true;
  String? yuklemeHatasi;
  bool yerelVeriKullaniliyor = false;

  List<Product> seciliUrunler = [];

  final List<String> gunesKremiFiltreleri = [
    '☀️ SPF50+',
    '🌿 Parfümsüz',
    '👶 Hassas Cilt',
    '✨ Yağlı Cilt',
    '💧 Kuru Cilt',
    '🧴 Mineral Filtre',
  ];

  final List<String> ilacFiltreleri = [
    '💊 Ağrı / Ateş',
    '🤧 Alerji',
    '🩹 Spazm',
  ];

  @override
  void initState() {
    super.initState();
    _urunleriGetir();
  }

  Future<void> _urunleriGetir() async {
    ProductService.clearCache();
    setState(() {
      yukleniyorMu = true;
      yuklemeHatasi = null;
    });
    try {
      final sonuc = await ProductService.loadCatalog();
      if (!mounted) return;
      setState(() {
        tumUrunler = sonuc.products;
        yerelVeriKullaniliyor =
            sonuc.source == ProductCatalogSource.assetFallback;
        yukleniyorMu = false;
      });
    } on Object {
      if (!mounted) return;
      setState(() {
        tumUrunler = [];
        yuklemeHatasi =
            'Ürünler yüklenemedi. Bağlantınızı kontrol edip yeniden deneyin.';
        yukleniyorMu = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtrelenmisUrunler = tumUrunler.where((urun) {
      final kategoriUyuyorMu =
          seciliKategori == 'Tümü' || urun.category == seciliKategori;
      final aramaUyuyorMu = ProductFilter.matchesQuery(urun, aramaMetni);
      final altFiltreUyuyorMu = ProductFilter.matchesSubfilter(
        urun,
        seciliAltFiltre,
      );

      return kategoriUyuyorMu && aramaUyuyorMu && altFiltreUyuyorMu;
    }).toList();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.grey[50],
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue[100],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.health_and_safety,
                color: Colors.blue[800],
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'MediCheck',
              style: TextStyle(
                color: Colors.blue[900],
                fontWeight: FontWeight.w800,
                fontSize: 22,
                letterSpacing: -0.5,
              ),
            ),
            Text(
              ' AI',
              style: TextStyle(
                color: Colors.blue[500],
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            key: const Key('open-comparison'),
            tooltip: 'Ürün karşılaştır',
            onPressed: () => context.push('/compare'),
            icon: const Icon(Icons.compare_arrows_rounded),
          ),
        ],
      ),
      body: yukleniyorMu
          ? const Center(child: CircularProgressIndicator())
          : yuklemeHatasi != null
          ? _buildCatalogError()
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '👋 Hoş Geldiniz',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.5,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Bugün neyi incelemek istersiniz?',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withValues(alpha: 0.04),
                              blurRadius: 15,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: TextField(
                          onChanged: (deger) {
                            setState(() => aramaMetni = deger);
                          },
                          decoration: InputDecoration(
                            hintText: 'Ürün, marka veya etken madde ara...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            prefixIcon: const Icon(
                              Icons.search,
                              color: Colors.blueAccent,
                            ),
                            border: InputBorder.none,
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20,
                              vertical: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Row(
                    children: [
                      _buildCategoryChip(
                        'Tümü',
                        Icon(
                          Icons.grid_view,
                          size: 20,
                          color: seciliKategori == 'Tümü'
                              ? Colors.blue[900]
                              : Colors.blue[600],
                        ),
                        Colors.blue,
                        'Tümü',
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                        'Güneş Kremleri',
                        Icon(
                          Icons.wb_sunny,
                          size: 20,
                          color: seciliKategori == 'Güneş Kremi'
                              ? Colors.amber[900]
                              : Colors.amber[600],
                        ),
                        Colors.amber,
                        'Güneş Kremi',
                      ),
                      const SizedBox(width: 8),
                      _buildCategoryChip(
                        'İlaçlar',
                        _buildPillIcon(),
                        Colors.red,
                        'İlaç',
                      ),
                    ],
                  ),
                ),
                if (seciliKategori == 'Güneş Kremi' || seciliKategori == 'İlaç')
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      child: Row(
                        children:
                            (seciliKategori == 'Güneş Kremi'
                                    ? gunesKremiFiltreleri
                                    : ilacFiltreleri)
                                .map((filtre) {
                                  final isSelected = seciliAltFiltre == filtre;
                                  final selectedColor =
                                      seciliKategori == 'Güneş Kremi'
                                      ? Colors.amber
                                      : Colors.red;
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 8),
                                    child: ChoiceChip(
                                      label: Text(filtre),
                                      selected: isSelected,
                                      showCheckmark: false,
                                      selectedColor: selectedColor[100],
                                      backgroundColor: Colors.white,
                                      labelStyle: TextStyle(
                                        color: isSelected
                                            ? Colors.black87
                                            : Colors.grey[600],
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.normal,
                                        fontSize: 13,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: BorderSide(
                                          color: isSelected
                                              ? selectedColor[400]!
                                              : Colors.grey[300]!,
                                        ),
                                      ),
                                      onSelected: (selected) {
                                        setState(() {
                                          seciliAltFiltre = selected
                                              ? filtre
                                              : '';
                                        });
                                      },
                                    ),
                                  );
                                })
                                .toList(),
                      ),
                    ),
                  ),
                if (yerelVeriKullaniliyor)
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 6, 16, 4),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.amber[50],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.amber[200]!),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.cloud_off_outlined, size: 18),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sunucuya ulaşılamadı; yerel demo verisi gösteriliyor.',
                            style: TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                Expanded(
                  child: tumUrunler.isEmpty
                      ? const Center(
                          child: Text('Henüz katalog verisi bulunmuyor.'),
                        )
                      : filtrelenmisUrunler.isEmpty
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.search_off,
                                size: 48,
                                color: Colors.grey[400],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Bu filtreye uygun ürün bulunamadı.',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          padding: const EdgeInsets.only(top: 8, bottom: 80),
                          itemCount: filtrelenmisUrunler.length,
                          itemBuilder: (context, index) {
                            final urun = filtrelenmisUrunler[index];
                            final isSelected = seciliUrunler.contains(urun);

                            return Row(
                              children: [
                                if (urun.category == 'Güneş Kremi')
                                  Padding(
                                    padding: const EdgeInsets.only(left: 8.0),
                                    child: Checkbox(
                                      value: isSelected,
                                      activeColor: Colors.purple[700],
                                      onChanged: (bool? secildiMi) {
                                        setState(() {
                                          if (secildiMi == true) {
                                            if (seciliUrunler.length < 2) {
                                              seciliUrunler.add(urun);
                                            } else {
                                              ScaffoldMessenger.of(
                                                context,
                                              ).showSnackBar(
                                                const SnackBar(
                                                  content: Text(
                                                    'Karşılaştırma için en fazla 2 ürün seçebilirsiniz.',
                                                  ),
                                                  duration: Duration(
                                                    seconds: 2,
                                                  ),
                                                ),
                                              );
                                            }
                                          } else {
                                            seciliUrunler.remove(urun);
                                          }
                                        });
                                      },
                                    ),
                                  ),
                                Expanded(child: ProductCard(product: urun)),
                              ],
                            );
                          },
                        ),
                ),
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: seciliUrunler.length == 2
          ? FloatingActionButton.extended(
              onPressed: () {
                context.push('/compare', extra: seciliUrunler);
              },
              backgroundColor: Colors.purple[700],
              icon: const Icon(Icons.compare_arrows, color: Colors.white),
              label: const Text(
                'Karşılaştır',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )
          : Container(
              height: 64,
              width: 64,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Colors.blue[400]!, Colors.purple[600]!],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.purple.withValues(alpha: 0.4),
                    blurRadius: 15,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: FloatingActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute<void>(
                      builder: (context) => const AiAssistantScreen(),
                    ),
                  );
                },
                backgroundColor: Colors.transparent,
                elevation: 0,
                child: const Icon(
                  Icons.auto_awesome,
                  color: Colors.white,
                  size: 32,
                ),
              ),
            ),
    );
  }

  Widget _buildCategoryChip(
    String title,
    Widget customIcon,
    MaterialColor color,
    String categoryName,
  ) {
    final isSelected = seciliKategori == categoryName;
    return GestureDetector(
      onTap: () {
        setState(() {
          seciliKategori = categoryName;
          seciliAltFiltre = '';
        });
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? color[100] : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color[400]! : Colors.grey[300]!,
          ),
        ),
        child: Row(
          children: [
            customIcon,
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? color[900] : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCatalogError() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.error_outline, size: 52, color: Colors.red[400]),
            const SizedBox(height: 14),
            Text(
              yuklemeHatasi!,
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[700], height: 1.4),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              key: const Key('retry-products'),
              onPressed: _urunleriGetir,
              icon: const Icon(Icons.refresh),
              label: const Text('Yeniden dene'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPillIcon() {
    return Transform.rotate(
      angle: 0.5,
      child: Container(
        width: 12,
        height: 20,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.red[700]!, width: 1.5),
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red[500]!, Colors.white],
            stops: const [0.5, 0.5],
          ),
        ),
      ),
    );
  }
}
