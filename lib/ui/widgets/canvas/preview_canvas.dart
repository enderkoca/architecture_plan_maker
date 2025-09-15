import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/project_provider.dart';
import '../../../state/selectors.dart';
import '../../../state/theme_provider.dart';
import '../../../data/models/unit.dart';
import '../../../core/formatters.dart';
import '../../../theme.dart';

class PreviewCanvas extends ConsumerWidget {
  const PreviewCanvas({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);
    final visibleKatlar = ref.watch(visibleKatlarProvider);
    final toplamInsaatAlani = ref.watch(toplamInsaatAlaniProvider);
    final muteahhitToplam = ref.watch(muteahhitToplamYeniBrutProvider);
    final toprakSahibiToplam = ref.watch(toprakSahibiToplamYeniBrutProvider);
    final isDark = ref.watch(themeProvider.notifier).isDark;

    return Container(
      color: Theme.of(context).colorScheme.surfaceContainerLowest,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildSummaryCard(
                  context,
                  toplamInsaatAlani,
                  muteahhitToplam,
                  toprakSahibiToplam,
                  isDark,
                ),
                const SizedBox(height: 24),
                if (project.showCati) _buildCatiSection(context),
                if (visibleKatlar.isEmpty)
                  _buildEmptyState(context)
                else
                  ...visibleKatlar.map((kat) => _buildFloorCard(context, kat, isDark)),
                const SizedBox(height: 16),
                if (project.showOtopark) _buildOtoparkSection(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryCard(
    BuildContext context,
    double toplamInsaatAlani,
    double muteahhitToplam,
    double toprakSahibiToplam,
    bool isDark,
  ) {
    return Card(
      elevation: 4,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Theme.of(context).colorScheme.primary.withOpacity(0.1),
              Theme.of(context).colorScheme.primary.withOpacity(0.05),
            ],
          ),
        ),
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Toplam İnşaat Alanı',
                  NumberFormatter.formatArea(toplamInsaatAlani),
                  Icons.business,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              Container(
                width: 1,
                color: Theme.of(context).dividerColor,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Müteahhit Toplam',
                  NumberFormatter.formatArea(muteahhitToplam),
                  Icons.engineering,
                  UnitColors.getBorderColor(true, isDark),
                ),
              ),
              Container(
                width: 1,
                color: Theme.of(context).dividerColor,
                margin: const EdgeInsets.symmetric(horizontal: 8),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Toprak Sahibi Toplam',
                  NumberFormatter.formatArea(toprakSahibiToplam),
                  Icons.person,
                  UnitColors.getBorderColor(false, isDark),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryItem(
    BuildContext context,
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 6),
        Text(
          title,
          textAlign: TextAlign.center,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            fontSize: 10,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: color,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildCatiSection(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: CustomPaint(
        size: const Size(double.infinity, 40),
        painter: _CatiPainter(
          color: Theme.of(context).colorScheme.secondary,
        ),
      ),
    );
  }

  Widget _buildFloorCard(BuildContext context, floor, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  floor.ad,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.secondaryContainer,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    NumberFormatter.formatArea(floor.alan),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSecondaryContainer,
                    ),
                  ),
                ),
              ],
            ),
            if (floor.aciklama != null && floor.aciklama!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                floor.aciklama!,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
            const SizedBox(height: 16),
            if (floor.daireler.isEmpty)
              Container(
                padding: const EdgeInsets.all(20),
                child: Center(
                  child: Text(
                    'Bu kata henüz daire eklenmemiş',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).colorScheme.outline,
                    ),
                  ),
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: floor.daireler.map<Widget>((unit) {
                  return _buildUnitCard(context, unit, isDark);
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitCard(BuildContext context, UnitModel unit, bool isDark) {
    final isMuteahhit = unit.malik == Malik.muteahhit;
    
    return Container(
      width: 140,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: UnitColors.getBackgroundColor(isMuteahhit, isDark),
        border: Border.all(
          color: UnitColors.getBorderColor(isMuteahhit, isDark),
          width: 2,
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                unit.ad,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: UnitColors.getBorderColor(isMuteahhit, isDark),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isMuteahhit ? 'M' : 'TS',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          if (unit.eskiBrut != null)
            Text(
              'Eski: ${NumberFormatter.formatNumber(unit.eskiBrut)} m²',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          if (unit.yeniBrut != null)
            Text(
              'Yeni: ${NumberFormatter.formatNumber(unit.yeniBrut)} m²',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          if (unit.eskiBrut == null && unit.yeniBrut == null)
            Text(
              'Alan belirtilmemiş',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildOtoparkSection(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        border: Border.all(color: Colors.grey.shade400),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'OTOPARK',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.grey.shade700,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Card(
      child: Container(
        padding: const EdgeInsets.all(40),
        child: Column(
          children: [
            Icon(
              Icons.apartment_outlined,
              size: 64,
              color: Theme.of(context).colorScheme.outline,
            ),
            const SizedBox(height: 16),
            Text(
              'Proje Önizlemesi',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Katlar ve daireler eklendikçe burada görünecek',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.outline,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

class _CatiPainter extends CustomPainter {
  final Color color;

  _CatiPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width * 0.2, size.height)
      ..lineTo(size.width * 0.5, 0)
      ..lineTo(size.width * 0.8, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}