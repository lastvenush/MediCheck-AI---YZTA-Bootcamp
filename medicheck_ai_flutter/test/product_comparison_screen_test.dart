import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:medicheck_ai_flutter/features/product_comparison/data/mock_product_comparison_service.dart';
import 'package:medicheck_ai_flutter/features/product_comparison/presentation/product_comparison_screen.dart';
import 'package:medicheck_ai_flutter/models/product.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('user selects two products and sees the AI comparison', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: ProductComparisonScreen(
          service: MockProductComparisonService(delay: Duration.zero),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final pickers = find.byType(DropdownButtonFormField<Product>);
    expect(pickers, findsNWidgets(2));

    await tester.tap(pickers.at(0));
    await tester.pumpAndSettle();
    await tester.tap(
      find.text('La Roche-Posay - Anthelios UVMune 400 Fluid').last,
    );
    await tester.pumpAndSettle();

    await tester.tap(pickers.at(1));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Bioderma - Photoderm Max Aquafluide').last);
    await tester.pumpAndSettle();

    final submit = find.byKey(const Key('comparison-submit'));
    await tester.ensureVisible(submit);
    await tester.pumpAndSettle();
    expect(tester.widget<FilledButton>(submit).onPressed, isNotNull);
    await tester.tap(submit);
    await tester.pumpAndSettle();

    await tester.drag(find.byType(ListView), const Offset(0, -600));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key('comparison-result')), findsOneWidget);
    expect(find.text('MediCheck AI Karşılaştırma Yorumu'), findsOneWidget);
  });
}
