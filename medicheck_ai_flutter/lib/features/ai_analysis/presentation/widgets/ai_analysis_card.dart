import 'package:flutter/material.dart';

import '../../../../models/product.dart';
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
    return Container(
      key: const Key('ai-analysis-card'),
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[200]!, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.auto_awesome, color: Colors.blue[700], size: 27),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MediCheck AI Analizi',
                      style: TextStyle(
                        color: Colors.blue[900],
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Yalnızca mevcut ürün verileri kullanılır',
                      style: TextStyle(
                        color: Colors.blueGrey[600],
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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
    );
  }
}

class _LoadingAnalysis extends StatelessWidget {
  const _LoadingAnalysis();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      key: const Key('ai-analysis-loading'),
      height: 104,
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 25,
              height: 25,
              child: CircularProgressIndicator(strokeWidth: 2.5),
            ),
            const SizedBox(height: 12),
            Text(
              'Ürün bilgileri güvenli kurallarla özetleniyor…',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.blueGrey[700], fontSize: 13),
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.red[50],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(Icons.cloud_off_outlined, color: Colors.red[600]),
          const SizedBox(height: 8),
          const Text('Analiz şu anda görüntülenemiyor.'),
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
        Text(
          result.shortSummary,
          style: const TextStyle(
            color: Colors.black87,
            fontSize: 15,
            height: 1.55,
          ),
        ),
        if (result.usagePurpose.isNotEmpty) ...[
          const SizedBox(height: 16),
          _AnalysisTextSection(
            icon: Icons.my_location_outlined,
            title: 'Kullanım amacı',
            text: result.usagePurpose,
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
        const SizedBox(height: 18),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: Colors.amber[50],
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.amber[200]!),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                Icons.info_outline_rounded,
                color: Colors.amber[800],
                size: 19,
              ),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  result.disclaimer,
                  key: const Key('ai-analysis-disclaimer'),
                  style: TextStyle(
                    color: Colors.amber[900],
                    fontSize: 12.5,
                    height: 1.45,
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

class _AnalysisTextSection extends StatelessWidget {
  const _AnalysisTextSection({
    required this.icon,
    required this.title,
    required this.text,
  });

  final IconData icon;
  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return _AnalysisSectionShell(
      icon: icon,
      title: title,
      child: Text(
        text,
        style: const TextStyle(
          color: Colors.black87,
          fontSize: 14,
          height: 1.45,
        ),
      ),
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
    return _AnalysisSectionShell(
      icon: icon,
      title: title,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 7),
                      child: Icon(
                        Icons.circle,
                        size: 5,
                        color: Colors.blue[700],
                      ),
                    ),
                    const SizedBox(width: 9),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          color: Colors.black87,
                          fontSize: 14,
                          height: 1.45,
                        ),
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

class _AnalysisSectionShell extends StatelessWidget {
  const _AnalysisSectionShell({
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
            Icon(icon, color: Colors.blue[700], size: 18),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                color: Colors.blue[900],
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 7),
        child,
      ],
    );
  }
}
