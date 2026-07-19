import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../catalog/domain/product.dart';
import '../../domain/ai_analysis_result.dart';
import '../../domain/ai_analysis_service.dart';

class AiAnalysisCard extends StatefulWidget {
  const AiAnalysisCard({
    required this.product,
    required this.service,
    super.key,
  });

  final Product product;
  final AiAnalysisService service;

  @override
  State<AiAnalysisCard> createState() => _AiAnalysisCardState();
}

class _AiAnalysisCardState extends State<AiAnalysisCard> {
  late Future<AiAnalysisResult> _analysis;

  @override
  void initState() {
    super.initState();
    _loadAnalysis();
  }

  @override
  void didUpdateWidget(covariant AiAnalysisCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.product.id != widget.product.id ||
        oldWidget.service != widget.service) {
      _loadAnalysis();
    }
  }

  void _loadAnalysis() {
    _analysis = widget.service.analyzeProduct(widget.product);
  }

  void _retry() {
    setState(_loadAnalysis);
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      key: const Key('ai-analysis-card'),
      color: const Color(0xFFFBFDFC),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: const BorderSide(color: Color(0xFFCFE2DF), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _AnalysisHeader(),
            const SizedBox(height: 18),
            FutureBuilder<AiAnalysisResult>(
              future: _analysis,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _LoadingAnalysis();
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return _ErrorAnalysis(onRetry: _retry);
                }
                return _AnalysisContent(result: snapshot.requireData);
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _AnalysisHeader extends StatelessWidget {
  const _AnalysisHeader();

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(13),
          ),
          child: const Icon(
            Icons.auto_awesome_outlined,
            color: AppColors.primaryDark,
            size: 22,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MediCheck AI Analizi',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 2),
              Text(
                'Yalnızca mevcut ürün verileri kullanılır',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
          decoration: BoxDecoration(
            color: AppColors.primarySoft,
            borderRadius: BorderRadius.circular(9),
          ),
          child: const Text(
            'Güvenli',
            style: TextStyle(
              color: AppColors.primaryDark,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _LoadingAnalysis extends StatelessWidget {
  const _LoadingAnalysis();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('ai-analysis-loading'),
      height: 132,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 26,
              height: 26,
              child: CircularProgressIndicator(
                strokeWidth: 2.4,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 14),
            Text(
              'Ürün bilgileri güvenli kurallarla özetleniyor…',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorAnalysis extends StatelessWidget {
  const _ErrorAnalysis({required this.onRetry});

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('ai-analysis-error'),
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.error.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(
            Icons.cloud_off_outlined,
            color: Theme.of(context).colorScheme.error,
          ),
          const SizedBox(height: 8),
          Text(
            'Analiz şu anda görüntülenemiyor.',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 4),
          Text(
            'Ürün bilgileri ekranda kalmaya devam eder.',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 10),
          TextButton.icon(
            key: const Key('ai-analysis-retry'),
            onPressed: onRetry,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: const Text('Tekrar dene'),
          ),
        ],
      ),
    );
  }
}

class _AnalysisContent extends StatelessWidget {
  const _AnalysisContent({required this.result});

  final AiAnalysisResult result;

  @override
  Widget build(BuildContext context) {
    return Column(
      key: const Key('ai-analysis-success'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(result.shortSummary, style: Theme.of(context).textTheme.bodyLarge),
        if (result.usagePurpose.isNotEmpty) ...[
          const SizedBox(height: 18),
          _AnalysisSection(
            icon: Icons.my_location_outlined,
            title: 'Ne amaçla kullanılır?',
            body: result.usagePurpose,
          ),
        ],
        if (result.importantIngredients.isNotEmpty) ...[
          const SizedBox(height: 16),
          _AnalysisListSection(
            icon: Icons.science_outlined,
            title: 'Önemli içerikler',
            items: result.importantIngredients,
          ),
        ],
        if (result.attentionPoints.isNotEmpty) ...[
          const SizedBox(height: 16),
          _AnalysisListSection(
            icon: Icons.report_gmailerrorred_outlined,
            title: 'Dikkat noktaları',
            items: result.attentionPoints,
          ),
        ],
        if (result.commonEffects.isNotEmpty) ...[
          const SizedBox(height: 16),
          _AnalysisListSection(
            icon: Icons.spa_outlined,
            title: 'Yaygın etkiler / hassasiyet',
            items: result.commonEffects,
          ),
        ],
        const SizedBox(height: 20),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.warningSoft,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline_rounded,
                color: AppColors.warning,
                size: 19,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  result.disclaimer,
                  key: const Key('ai-analysis-disclaimer'),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.warning,
                    fontSize: 12.5,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _AnalysisSection extends StatelessWidget {
  const _AnalysisSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      icon: icon,
      title: title,
      child: Text(body, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _AnalysisListSection extends StatelessWidget {
  const _AnalysisListSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _SectionShell(
      icon: icon,
      title: title,
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 7),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 7),
                      child: Icon(
                        Icons.circle,
                        size: 5,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        item,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(growable: false),
      ),
    );
  }
}

class _SectionShell extends StatelessWidget {
  const _SectionShell({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 19),
            const SizedBox(width: 8),
            Text(title, style: Theme.of(context).textTheme.titleMedium),
          ],
        ),
        const SizedBox(height: 8),
        child,
      ],
    );
  }
}
