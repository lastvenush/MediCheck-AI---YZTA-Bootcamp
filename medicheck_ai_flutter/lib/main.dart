import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_screen.dart';
import 'features/home/product_detail_screen.dart';
import 'features/compare/compare_screen.dart'; // Eklenen yeni sayfa
import 'models/product.dart'; // Route içindeki liste için model importu

void main() {
  runApp(const ProviderScope(child: MediCheckApp()));
}

class MediCheckApp extends StatelessWidget {
  const MediCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(
          path: '/', 
          builder: (context, state) => const HomeScreen(),
        ),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            return ProductDetailScreen(productId: state.pathParameters['id']!);
          },
        ),
       
        GoRoute(
          path: '/compare',
          builder: (context, state) {
           
            final products = state.extra as List<Product>;
            return CompareScreen(
              product1: products[0],
              product2: products[1],
            );
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
}
