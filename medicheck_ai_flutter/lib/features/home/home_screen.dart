import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../models/product.dart';
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

  List<Product> seciliUrunler = [];

  final List<String> gunesKremiFiltreleri = [
    '☀️ SPF50+',
    '💧 Suya Dayanıklı',
    '🌿 Parfümsüz',
    '👶 Hassas Cilt',
    '✨ Mat Bitiş',
    '🧴 Mineral Filtre',
  ];

  final List<String> ilacFiltreleri = [
    '💊 Ağrı Kesici',
    '🤧 Soğuk Algınlığı',
    '🛡️ Vitamin',
    '🩹 İlk Yardım',
    '💧 Şurup',
    '🌿 Bitkisel',
  ];

  @override
  void initState() {
    super.initState();
    _urunleriGetir();
  }

  Future<void> _urunleriGetir() async {
    final urunler = await ProductService.loadProducts();
    if (!mounted) {
      return;
    }
    setState(() {
      tumUrunler = urunler;
      yukleniyorMu = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filtrelenmisUrunler = tumUrunler.where((urun) {
      final kategoriUyuyorMu =
          seciliKategori == 'Tümü' || urun.category == seciliKategori;
      final aramaUyuyorMu = urun.name.toLowerCase().contains(
        aramaMetni.toLowerCase(),
      );

      var altFiltreUyuyorMu = true;
      if (seciliAltFiltre.isNotEmpty) {
        final filtreKelimesi = seciliAltFiltre
            .split(' ')
            .skip(1)
            .join(' ')
            .toLowerCase();
        altFiltreUyuyorMu =
            urun.name.toLowerCase().contains(filtreKelimesi) ||
            urun.description.toLowerCase().contains(filtreKelimesi) ||
            urun.ingredients.any(
              (item) => item.toLowerCase().contains(filtreKelimesi),
            ) ||
            urun.usageInstructions.toLowerCase().contains(filtreKelimesi) ||
            urun.sideEffects.toLowerCase().contains(filtreKelimesi) ||
            urun.contraindications.toLowerCase().contains(filtreKelimesi);
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
                            hintText: 'İlaç veya ürün ara...',
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
                Expanded(
                  child: filtrelenmisUrunler.isEmpty
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

// Çalışan AI Asistan Ekranı (Chat UI)
class AiBotScreen extends StatefulWidget {
  const AiBotScreen({super.key});

  @override
  State<AiBotScreen> createState() => _AiBotScreenState();
}

class _AiBotScreenState extends State<AiBotScreen> {
  final TextEditingController _controller = TextEditingController();
  final List<Map<String, String>> _messages = [];
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.add({
      'sender': 'ai',
      'text':
          'Merhaba! Ben MediCheck AI. Dermokozmetik ve ilaç içerikleri hakkında size bilgi verebilirim. Ancak tıbbi tanı koyamam veya doz öneremem. Size nasıl yardımcı olabilirim?',
    });
  }

  void _sendMessage() {
    if (_controller.text.trim().isEmpty) return;

    final userText = _controller.text.trim();
    setState(() {
      _messages.add({'sender': 'user', 'text': userText});
      _isTyping = true;
      _controller.clear();
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      setState(() {
        _isTyping = false;
        _messages.add({
          'sender': 'ai',
          'text':
              'Bu bir demo yanıtıdır. Sistem şu anda güvenli modda çalışıyor. Sorduğunuz soruya dair ürün içeriklerini analiz edebilirim ancak sağlık durumunuzla ilgili kesin kararlar için lütfen bir doktora veya eczacıya danışın.',
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: IconThemeData(color: Colors.purple[900]),
        title: Row(
          children: [
            Icon(Icons.auto_awesome, color: Colors.purple[700]),
            const SizedBox(width: 8),
            Text(
              'MediCheck Asistan',
              style: TextStyle(
                color: Colors.purple[900],
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final msg = _messages[index];
                final isUser = msg['sender'] == 'user';
                return Align(
                  alignment: isUser
                      ? Alignment.centerRight
                      : Alignment.centerLeft,
                  child: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    constraints: BoxConstraints(
                      maxWidth: MediaQuery.of(context).size.width * 0.75,
                    ),
                    decoration: BoxDecoration(
                      color: isUser ? Colors.purple[600] : Colors.white,
                      borderRadius: BorderRadius.circular(16).copyWith(
                        bottomRight: isUser
                            ? const Radius.circular(0)
                            : const Radius.circular(16),
                        bottomLeft: !isUser
                            ? const Radius.circular(0)
                            : const Radius.circular(16),
                      ),
                      boxShadow: [
                        if (!isUser)
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.05),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                      ],
                    ),
                    child: Text(
                      msg['text']!,
                      style: TextStyle(
                        color: isUser ? Colors.white : Colors.black87,
                        fontSize: 15,
                        height: 1.4,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (_isTyping)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'AI Asistan yanıtlıyor...',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  offset: const Offset(0, -2),
                  blurRadius: 10,
                ),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: 'Merak ettiğiniz bir şey sorun...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.purple[600],
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
