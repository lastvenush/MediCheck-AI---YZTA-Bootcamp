import 'package:flutter/material.dart';

import 'core/theme/app_theme.dart';
import 'features/ai_analysis/data/mock_ai_analysis_service.dart';
import 'features/ai_analysis/domain/ai_analysis_service.dart';
import 'features/catalog/presentation/pages/catalog_page.dart';

class MediCheckApp extends StatelessWidget {
  const MediCheckApp({super.key, this.aiAnalysisService});

  final AiAnalysisService? aiAnalysisService;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MediCheck AI',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      home: CatalogPage(
        aiAnalysisService: aiAnalysisService ?? const MockAiAnalysisService(),
      ),
    );
  }
}
