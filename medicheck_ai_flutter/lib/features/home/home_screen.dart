import 'package:flutter/material.dart';
import '../../models/product.dart';
import '../../services/product_service.dart';
import '../../shared/widgets/product_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String aramaMetni = '';
  String seciliKategori = 'Tümü';
  String seciliAltFiltre = ''; 

  // Ürünleri tutacağımız liste
  List<Product> tumUrunler = [];
  bool yukleniyorMu = true; 

  final List<String> gunesKremiFiltreleri = [
    '☀️ SPF50+', '💧 Suya Dayanıklı', '🌿 Parfümsüz', '👶 Hassas Cilt', '✨ Mat Bitiş', '🧴 Mineral Filtre'
  ];
  
  final List<String> ilacFiltreleri = [
    '💊 Ağrı Kesici', '🤧 Soğuk Algınlığı', '🛡️ Vitamin', '🩹 İlk Yardım', '💧 Şurup', '🌿 Bitkisel'
  ];

  @override
  void initState() {
    super.initState();
    _urunleriGetir(); // Uygulama açılır açılmaz verileri çekmeye başla
  }

  // ProductService'den JSON verilerini asenkron çeken fonksiyon
  Future<void> _urunleriGetir() async {
    final urunler = await ProductService.loadProducts();
    setState(() {
      tumUrunler = urunler;
      yukleniyorMu = false; // Veriler geldi, yükleme ikonunu durdur
    });
  }

  @override
  Widget build(BuildContext context) {
    
    final filtrelenmisUrunler = tumUrunler.where((urun) {
      final kategoriUyuyorMu = seciliKategori == 'Tümü' || urun.category == seciliKategori;
      final aramaUyuyorMu = urun.name.toLowerCase().contains(aramaMetni.toLowerCase());

      bool altFiltreUyuyorMu = true;
      if (seciliAltFiltre.isNotEmpty) {
        final filtreKelimesi = seciliAltFiltre.split(' ').skip(1).join(' ').toLowerCase();
        
        final adindaVarMi = urun.name.toLowerCase().contains(filtreKelimesi);
        final aciklamadaVarMi = urun.description.toLowerCase().contains(filtreKelimesi);
        final icerikteVarMi = urun.ingredients.any((i) => i.toLowerCase().contains(filtreKelimesi));
        
        
        final kullanimdaVarMi = urun.usageInstructions.toLowerCase().contains(filtreKelimesi);
        final yanEtkideVarMi = urun.sideEffects.toLowerCase().contains(filtreKelimesi);
        final uyariVarMi = urun.contraindications.toLowerCase().contains(filtreKelimesi);

        altFiltreUyuyorMu = adindaVarMi || aciklamadaVarMi || icerikteVarMi || kullanimdaVarMi || yanEtkideVarMi || uyariVarMi;
      }

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
              decoration: BoxDecoration(color: Colors.blue[100], borderRadius: BorderRadius.circular(10)),
              child: Icon(Icons.health_and_safety, color: Colors.blue[800], size: 24),
            ),
            const SizedBox(width: 12),
            Text('MediCheck', style: TextStyle(color: Colors.blue[900], fontWeight: FontWeight.w800, fontSize: 22, letterSpacing: -0.5)),
            Text(' AI', style: TextStyle(color: Colors.blue[500], fontWeight: FontWeight.bold, fontSize: 22)),
          ],
        ),
      ),
      body: yukleniyorMu 
      ? const Center(child: CircularProgressIndicator()) 
      : Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('👋 Hoş Geldiniz', style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, letterSpacing: -0.5)),
                const SizedBox(height: 6),
                Text('Bugün neyi incelemek istersiniz?', style: TextStyle(fontSize: 16, color: Colors.grey[600], fontWeight: FontWeight.w500)),
                const SizedBox(height: 24),
                
                // ARAMA ÇUBUĞU (KART SİLİNDİ, DİREKT ARAMA ÇUBUĞUNA GEÇTİK)
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.04), blurRadius: 15, offset: const Offset(0, 5))],
                  ),
                  child: TextField(
                    onChanged: (deger) {
                      setState(() { aramaMetni = deger; });
                    },
                    decoration: InputDecoration(
                      hintText: 'İlaç veya ürün ara...',
                      hintStyle: TextStyle(color: Colors.grey[400]),
                      prefixIcon: const Icon(Icons.search, color: Colors.blueAccent),
                      suffixIcon: IconButton(icon: const Icon(Icons.qr_code_scanner, color: Colors.blueGrey), onPressed: () {}),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // KATEGORİ ÇUBUĞU
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Row(
              children: [
                _buildCategoryChip('Tümü', Icon(Icons.grid_view, size: 20, color: seciliKategori == 'Tümü' ? Colors.blue[900] : Colors.blue[600]), Colors.blue, 'Tümü'),
                const SizedBox(width: 8),
                _buildCategoryChip('Güneş Kremleri', Icon(Icons.wb_sunny, size: 20, color: seciliKategori == 'Güneş Kremi' ? Colors.amber[900] : Colors.amber[600]), Colors.amber, 'Güneş Kremi'),
                const SizedBox(width: 8),
                _buildCategoryChip('İlaçlar', _buildPillIcon(), Colors.red, 'İlaç'),
                const SizedBox(width: 8),
                _buildCategoryChip('Favoriler', Icon(Icons.star_rounded, size: 22, color: seciliKategori == 'Favoriler' ? Colors.orange[900] : Colors.orange[500]), Colors.orange, 'Favoriler'),
              ],
            ),
          ),

          // ALT FİLTRE ÇUBUĞU
          if (seciliKategori == 'Güneş Kremi' || seciliKategori == 'İlaç')
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: (seciliKategori == 'Güneş Kremi' ? gunesKremiFiltreleri : ilacFiltreleri).map((filtre) {
                    final isSelected = seciliAltFiltre == filtre;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8.0),
                      child: ChoiceChip(
                        label: Text(filtre),
                        selected: isSelected,
                        showCheckmark: false,
                        selectedColor: seciliKategori == 'Güneş Kremi' ? Colors.amber[100] : Colors.red[100],
                        backgroundColor: Colors.white,
                        labelStyle: TextStyle(
                          color: isSelected ? Colors.black87 : Colors.grey[600],
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                          fontSize: 13,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: isSelected ? (seciliKategori == 'Güneş Kremi' ? Colors.amber[400]! : Colors.red[400]!) : Colors.grey[300]!),
                        ),
                        onSelected: (selected) {
                          setState(() { seciliAltFiltre = selected ? filtre : ''; });
                        },
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          
          Expanded(
            child: filtrelenmisUrunler.isEmpty 
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.search_off, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 16),
                    Text('Bu filtreye uygun ürün bulunamadı.', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.only(top: 8, bottom: 80),
                itemCount: filtrelenmisUrunler.length,
                itemBuilder: (context, index) {
                  // SAYAÇ KALKTIĞI İÇİN DOĞRUDAN KARTI ÇAĞIRIYORUZ
                  return ProductCard(product: filtrelenmisUrunler[index]);
                },
              ),
          ),
        ],
      ),
      
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: Container(
        height: 64,
        width: 64,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: LinearGradient(colors: [Colors.blue[400]!, Colors.purple[600]!], begin: Alignment.topLeft, end: Alignment.bottomRight),
          boxShadow: [BoxShadow(color: Colors.purple.withValues(alpha: 0.4), blurRadius: 15, offset: const Offset(0, 6))],
        ),
        child: FloatingActionButton(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const AiBotScreen()));
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.auto_awesome, color: Colors.white, size: 32),
        ),
      ),
      
      bottomNavigationBar: BottomAppBar(
        shape: const CircularNotchedRectangle(),
        notchMargin: 10,
        color: Colors.white,
        elevation: 10,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(icon: Icon(Icons.home_rounded, size: 30, color: Colors.blue[900]), onPressed: () {}),
              const SizedBox(width: 48),
              IconButton(icon: Icon(Icons.person_outline_rounded, size: 30, color: Colors.grey[400]), onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChip(String title, Widget customIcon, MaterialColor color, String categoryName) {
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
          border: Border.all(color: isSelected ? color[400]! : Colors.grey[300]!),
        ),
        child: Row(
          children: [
            customIcon,
            const SizedBox(width: 8),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, color: isSelected ? color[900] : Colors.black87)),
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
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.red[500]!, Colors.white], stops: const [0.5, 0.5]),
        ),
      ),
    );
  }
}

class AiBotScreen extends StatelessWidget {
  const AiBotScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(backgroundColor: Colors.white, elevation: 0, iconTheme: IconThemeData(color: Colors.purple[900]), title: Text('MediCheck Asistan', style: TextStyle(color: Colors.purple[900], fontWeight: FontWeight.bold))),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.smart_toy_rounded, size: 80, color: Colors.purple[300]),
            const SizedBox(height: 24),
            Text('Yapay Zeka Altyapısı Hazırlanıyor...', style: TextStyle(fontSize: 18, color: Colors.grey[700], fontWeight: FontWeight.w600)),
            const SizedBox(height: 12),
            Text('Çok yakında sağlık asistanınız burada olacak.', style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      ),
    );
  }
}