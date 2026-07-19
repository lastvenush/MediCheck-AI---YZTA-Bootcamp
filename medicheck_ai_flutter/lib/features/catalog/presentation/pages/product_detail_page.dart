import 'package:flutter/material.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../ai_analysis/domain/ai_analysis_service.dart';
import '../../../ai_analysis/presentation/widgets/ai_analysis_card.dart';
import '../../domain/product.dart';

class ProductDetailPage extends StatelessWidget {
  const ProductDetailPage({
    required this.product,
    required this.aiAnalysisService,
    super.key,
  });

  final Product product;
  final AiAnalysisService aiAnalysisService;

  @override
  Widget build(BuildContext context) {
    final isMedicine = product.type == ProductType.medicine;
    final accent = isMedicine ? AppColors.medicine : AppColors.sunscreen;
    final soft = isMedicine ? AppColors.medicineSoft : AppColors.sunscreenSoft;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          tooltip: 'Geri',
          onPressed: () => Navigator.of(context).pop(),
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: Text(
          'Ürün detayı',
          style: Theme.of(context).textTheme.titleLarge,
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
            sliver: SliverList.list(
              children: [
                _ProductHero(product: product, accent: accent, soft: soft),
                const SizedBox(height: 18),
                const _InformationNotice(),
                const SizedBox(height: 26),
                _SectionTitle(
                  title: 'Ürün bilgileri',
                  subtitle: isMedicine
                      ? 'Prospektüs verilerinden öne çıkanlar'
                      : 'Formül ve kullanım özellikleri',
                ),
                const SizedBox(height: 12),
                _ProductFacts(product: product),
                const SizedBox(height: 26),
                _TextSection(
                  icon: Icons.info_outline_rounded,
                  title: 'Kullanım amacı',
                  body: product.usagePurpose,
                ),
                if (product.attentionPoints.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  _BulletSection(
                    icon: Icons.visibility_outlined,
                    title: 'Ürün verisindeki uyarılar',
                    items: product.attentionPoints,
                  ),
                ],
                const SizedBox(height: 28),
                _SectionTitle(
                  title: 'MediCheck AI',
                  subtitle: 'Ürün verilerinin sade ve güvenli özeti',
                ),
                const SizedBox(height: 12),
                AiAnalysisCard(product: product, service: aiAnalysisService),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ProductHero extends StatelessWidget {
  const _ProductHero({
    required this.product,
    required this.accent,
    required this.soft,
  });

  final Product product;
  final Color accent;
  final Color soft;

  @override
  Widget build(BuildContext context) {
    final isMedicine = product.type == ProductType.medicine;
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: soft,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Hero(
            tag: 'product-icon-${product.id}',
            child: Container(
              width: 72,
              height: 78,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.74),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                isMedicine
                    ? Icons.medication_outlined
                    : Icons.wb_sunny_outlined,
                color: accent,
                size: 34,
              ),
            ),
          ),
          const SizedBox(width: 17),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.type.label,
                  style: TextStyle(
                    color: accent,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  product.name,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 5),
                Text(
                  product.brand,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationNotice extends StatelessWidget {
  const _InformationNotice();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.warningSoft,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0D8B8)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.shield_outlined, color: AppColors.warning, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Bilgiler genel bilgilendirme içindir. Sağlıkla ilgili kararlar için doktorunuza veya eczacınıza danışın.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.warning,
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.headlineSmall),
        const SizedBox(height: 3),
        Text(subtitle, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }
}

class _ProductFacts extends StatelessWidget {
  const _ProductFacts({required this.product});

  final Product product;

  @override
  Widget build(BuildContext context) {
    final facts = product.type == ProductType.medicine
        ? <({String label, String value})>[
            (label: 'Marka', value: product.brand),
            (label: 'Kategori', value: 'İlaç'),
            (
              label: 'Etken madde',
              value: product.importantIngredients.isEmpty
                  ? 'Belirtilmemiş'
                  : product.importantIngredients.join(', '),
            ),
          ]
        : <({String label, String value})>[
            (
              label: 'Koruma',
              value: product.spf == null
                  ? 'Belirtilmemiş'
                  : 'SPF ${product.spf}+',
            ),
            (label: 'Filtre', value: product.filterType ?? 'Belirtilmemiş'),
            (label: 'Cilt tipi', value: product.skinType ?? 'Belirtilmemiş'),
            (label: 'Alkol', value: _presenceLabel(product.containsAlcohol)),
            (label: 'Parfüm', value: _presenceLabel(product.containsFragrance)),
          ];

    return LayoutBuilder(
      builder: (context, constraints) {
        final itemWidth = constraints.maxWidth >= 560
            ? (constraints.maxWidth - 12) / 2
            : constraints.maxWidth;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: facts
              .map(
                (fact) => SizedBox(
                  width: itemWidth,
                  child: Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.outline),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fact.label,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        const SizedBox(height: 5),
                        Text(
                          fact.value,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              )
              .toList(growable: false),
        );
      },
    );
  }

  static String _presenceLabel(bool? value) {
    return switch (value) {
      true => 'İçeriyor',
      false => 'İçermiyor',
      null => 'Belirtilmemiş',
    };
  }
}

class _TextSection extends StatelessWidget {
  const _TextSection({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return _InformationCard(
      icon: icon,
      title: title,
      child: Text(body, style: Theme.of(context).textTheme.bodyMedium),
    );
  }
}

class _BulletSection extends StatelessWidget {
  const _BulletSection({
    required this.icon,
    required this.title,
    required this.items,
  });

  final IconData icon;
  final String title;
  final List<String> items;

  @override
  Widget build(BuildContext context) {
    return _InformationCard(
      icon: icon,
      title: title,
      child: Column(
        children: items
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
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
                    const SizedBox(width: 10),
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

class _InformationCard extends StatelessWidget {
  const _InformationCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: AppColors.primary, size: 20),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
