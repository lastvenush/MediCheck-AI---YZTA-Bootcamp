import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'features/home/home_screen.dart';
import 'features/home/product_detail_screen.dart';
import 'features/onboarding/disclaimer_screen.dart';
import 'features/product_comparison/presentation/product_comparison_screen.dart';
import 'models/product.dart';
import 'services/product_service.dart';

void main() {
  runApp(const ProviderScope(child: MediCheckApp()));
}

class MediCheckApp extends StatelessWidget {
  const MediCheckApp({this.initialLocation = '/', this.loadCatalog, super.key});

  final String initialLocation;
  final ProductCatalogLoader? loadCatalog;

  @override
  Widget build(BuildContext context) {
    final router = GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const DisclaimerScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => HomeScreen(loadCatalog: loadCatalog),
        ),
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
            return ProductDetailScreen(
              productId: state.pathParameters['id']!,
              loadProducts: loadCatalog == null
                  ? null
                  : () async => (await loadCatalog!()).products,
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
