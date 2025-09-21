import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/project_provider.dart';
import '../../../core/formatters.dart';

class ProjectSummary extends ConsumerWidget {
  const ProjectSummary({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proje Özeti',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildSummaryRow(
              context,
              'Toplam Brüt Alan (Ortak Alan Hariç)',
              NumberFormatter.formatArea(project.toplamBrutAlanOrtakAlanHaric),
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              'Müteahhit Brüt Alanı',
              NumberFormatter.formatArea(project.muteahhitToplamYeniBrut),
              percentage: project.muteahhitYuzdesi,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              'Toprak Sahibi Brüt Alanı',
              NumberFormatter.formatArea(project.toprakSahibiToplamYeniBrut),
              percentage: project.toprakSahibiYuzdesi,
            ),
            const SizedBox(height: 8),
            _buildSummaryRow(
              context,
              'Toplam İnşaat Alanı (Ortak Alan Dahil)',
              NumberFormatter.formatArea(project.toplamInsaatAlani),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    double? percentage,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          flex: 3,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ),
        Expanded(
          flex: 2,
          child: Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.end,
          ),
        ),
        if (percentage != null) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              '${percentage.toStringAsFixed(1)}%',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ],
    );
  }
}