import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/features/home/home_screen.dart';
import 'package:medicheck_ai_flutter/main.dart';
import 'package:medicheck_ai_flutter/models/product.dart';
import 'package:medicheck_ai_flutter/services/product_service.dart';

void main() {
  testWidgets('medical notice is shown before the home catalog', (
    tester,
  ) async {
    await tester.pumpWidget(MediCheckApp(loadCatalog: _loadCatalog));

    expect(find.text('Önemli bilgilendirme'), findsOneWidget);
    expect(find.text('👋 Hoş Geldiniz'), findsNothing);

    await tester.tap(find.byKey(const Key('accept-disclaimer')));
    await tester.pumpAndSettle();

    expect(find.text('👋 Hoş Geldiniz'), findsOneWidget);
  });

  testWidgets('home search matches an active ingredient', (tester) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(loadCatalog: _loadCatalog)),
    );
    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextField), 'setirizin');
    await tester.pump();

    expect(find.text('Zyrtec 10 mg Film Kaplı Tablet'), findsOneWidget);
    expect(find.text('Parol 500 mg Tablet'), findsNothing);
  });

  testWidgets('medicine subfilter only displays matching records', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(home: HomeScreen(loadCatalog: _loadCatalog)),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.text('İlaçlar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('🤧 Alerji'));
    await tester.pumpAndSettle();

    expect(find.text('Zyrtec 10 mg Film Kaplı Tablet'), findsOneWidget);
    expect(find.text('Parol 500 mg Tablet'), findsNothing);
  });

  testWidgets('unknown product route shows a not-found state', (tester) async {
    await tester.pumpWidget(
      MediCheckApp(
        initialLocation: '/product/unknown',
        loadCatalog: _loadCatalog,
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Ürün bulunamadı.'), findsOneWidget);
  });
}

Future<ProductCatalogResult> _loadCatalog() async {
  return const ProductCatalogResult(
    source: ProductCatalogSource.api,
    products: [_sunscreen, _parol, _zyrtec, _buscopan],
  );
}

const _sunscreen = Product(
  id: 'g1',
  brand: 'Demo Dermokozmetik',
  name: 'Mineral SPF50+',
  category: 'Güneş Kremi',
  description: 'Mineral filtreli güneş koruyucu.',
  ingredients: ['Çinko oksit'],
  usageInstructions: 'Ambalaj talimatlarını izleyin.',
  sideEffects: 'Kişisel hassasiyet değişebilir.',
  contraindications: 'Rahatsızlık halinde kullanımı bırakın.',
  aiAnalysis: '',
  isSafe: false,
  imageUrl: '',
  filterTypes: ['Mineral filtre'],
  skinTypes: ['Hassas'],
  containsFragrance: false,
);

const _parol = Product(
  id: 'i1',
  brand: 'Atabay',
  name: 'Parol 500 mg Tablet',
  category: 'İlaç',
  description: 'Parasetamol içeren ilaç.',
  ingredients: ['Parasetamol'],
  usageInstructions: 'Resmî ürün bilgisini kontrol edin.',
  sideEffects: 'Yan etkiler kişiden kişiye değişebilir.',
  contraindications: 'Doktor veya eczacıya danışın.',
  aiAnalysis: '',
  isSafe: false,
  imageUrl: '',
  activeIngredients: ['Parasetamol 500 mg'],
  indications: ['Hafif-orta şiddette ağrı', 'Ateş'],
);

const _zyrtec = Product(
  id: 'i2',
  brand: 'UCB',
  name: 'Zyrtec 10 mg Film Kaplı Tablet',
  category: 'İlaç',
  description: 'Setirizin içeren antihistaminik ilaç.',
  ingredients: ['Setirizin'],
  usageInstructions: 'Resmî ürün bilgisini kontrol edin.',
  sideEffects: 'Yan etkiler kişiden kişiye değişebilir.',
  contraindications: 'Doktor veya eczacıya danışın.',
  aiAnalysis: '',
  isSafe: false,
  imageUrl: '',
  activeIngredients: ['Setirizin dihidroklorür 10 mg'],
  indications: ['Alerjik nezle', 'Ürtiker'],
);

const _buscopan = Product(
  id: 'i3',
  brand: 'Opella',
  name: 'Buscopan 10 mg Kaplı Tablet',
  category: 'İlaç',
  description: 'Hiyosin-N-butilbromür içeren ilaç.',
  ingredients: ['Hiyosin-N-butilbromür'],
  usageInstructions: 'Resmî ürün bilgisini kontrol edin.',
  sideEffects: 'Yan etkiler kişiden kişiye değişebilir.',
  contraindications: 'Doktor veya eczacıya danışın.',
  aiAnalysis: '',
  isSafe: false,
  imageUrl: '',
  activeIngredients: ['Hiyosin-N-butilbromür 10 mg'],
  indications: ['Gastrointestinal sistem spazmları'],
);
