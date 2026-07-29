import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_screen.dart';
import 'features/home/product_detail_screen.dart';
import 'features/product_comparison/presentation/product_comparison_screen.dart';
import 'models/product.dart';

void main() {
  runApp(const ProviderScope(child: MediCheckApp()));
}

class MediCheckApp extends StatelessWidget {
  const MediCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      routes: [
        GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
        GoRoute(
          path: '/compare',
          builder: (context, state) {
            final extra = state.extra;
            final initialProducts = extra is List<Product> ? extra : null;
            return ProductComparisonScreen(initialProducts: initialProducts);
          },
        ),
        GoRoute(
          path: '/product/:id',
          builder: (context, state) {
            return ProductDetailScreen(productId: state.pathParameters['id']!);
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
