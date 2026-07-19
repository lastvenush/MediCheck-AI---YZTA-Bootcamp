import 'features/home/product_detail_screen.dart'; // Yeni ekranı tanıtalım
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'features/home/home_screen.dart'; // Ana sayfamızı içeri aktarıyoruz

import 'app.dart';

void main() {
<<<<<<< HEAD
  runApp(
    // Riverpod'u kullanabilmek için uygulamayı ProviderScope ile sarmak zorundayız.
    const ProviderScope(
      child: MediCheckApp(),
    ),
  );
}

class MediCheckApp extends StatelessWidget {
  const MediCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    // GoRouter ayarları: Hangi url/yol hangi sayfayı açacak?
    final GoRouter router = GoRouter(
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const HomeScreen(),
        ),
        
        GoRoute(
          path: '/product/:id', // URL'de /product/1 gibi ID taşıyacağız
          builder: (context, state) {
            // URL'deki 'id' parametresini alıp detay sayfasına gönderiyoruz
            final productId = state.pathParameters['id']!;
            return ProductDetailScreen(productId: productId);
          },
        ),
      ],
    );

    return MaterialApp.router(
      title: 'MediCheck AI',
      debugShowCheckedModeBanner: false, 
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true, 
      ),
      routerConfig: router, 
    );
  }
=======
  runApp(const MediCheckApp());
>>>>>>> 9d48b08bd1d6135bdfe7262e08386b71d23d6207
}
