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
    final toplamInsaatAlaniOtoparkDahil = project.toplamInsaatAlaniOtoparkDahil;
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
                  toplamInsaatAlaniOtoparkDahil,
                  muteahhitToplam,
                  toprakSahibiToplam,
                  isDark,
                ),
                const SizedBox(height: 24),
                if (project.showCati) _buildCatiSection(context),
                if (visibleKatlar.isEmpty)
                  _buildEmptyState(context)
                else
                  _buildReorderableFloors(context, visibleKatlar, isDark, ref),
                const SizedBox(height: 16),
                if (project.showTicariAlan) _buildCommercialSection(context),
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
    double toplamInsaatAlaniOtoparkDahil,
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
                  'İnşaat Alanı',
                  NumberFormatter.formatArea(toplamInsaatAlani),
                  Icons.business,
                  Theme.of(context).colorScheme.primary,
                ),
              ),
              Container(
                width: 1,
                color: Theme.of(context).dividerColor,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Otopark Dahil',
                  NumberFormatter.formatArea(toplamInsaatAlaniOtoparkDahil),
                  Icons.local_parking,
                  Theme.of(context).colorScheme.secondary,
                ),
              ),
              Container(
                width: 1,
                color: Theme.of(context).dividerColor,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Müteahhit',
                  NumberFormatter.formatArea(muteahhitToplam),
                  Icons.engineering,
                  UnitColors.getBorderColor(true, isDark),
                ),
              ),
              Container(
                width: 1,
                color: Theme.of(context).dividerColor,
                margin: const EdgeInsets.symmetric(horizontal: 4),
              ),
              Expanded(
                child: _buildSummaryItem(
                  context,
                  'Toprak Sahibi',
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

  Widget _buildReorderableFloors(BuildContext context, List visibleKatlar, bool isDark, WidgetRef ref) {
    return Column(
      children: visibleKatlar.asMap().entries.map((entry) {
        final index = entry.key;
        final floor = entry.value;
        return _buildDraggableFloorCard(context, floor, index, visibleKatlar, isDark, ref);
      }).toList(),
    );
  }

  Widget _buildDraggableFloorCard(BuildContext context, floor, int index, List visibleKatlar, bool isDark, WidgetRef ref) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: LongPressDraggable<int>(
        data: index,
        feedback: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(12),
          child: Opacity(
            opacity: 0.8,
            child: SizedBox(
              width: 400,
              child: _buildFloorCard(context, floor, isDark),
            ),
          ),
        ),
        childWhenDragging: Opacity(
          opacity: 0.5,
          child: _buildFloorCard(context, floor, isDark),
        ),
        child: DragTarget<int>(
          onWillAcceptWithDetails: (details) => details.data != index,
          onAcceptWithDetails: (details) {
            final oldIndex = details.data;
            final newIndex = index;
            
            // Visible katların index'lerini gerçek project.katlar index'lerine çevir
            final project = ref.read(projectProvider);
            final oldRealIndex = project.katlar.indexOf(visibleKatlar[oldIndex]);
            final newRealIndex = project.katlar.indexOf(visibleKatlar[newIndex]);
            
            if (oldRealIndex != -1 && newRealIndex != -1) {
              ref.read(projectProvider.notifier).reorderFloors(oldRealIndex, newRealIndex);
            }
          },
          builder: (context, candidateData, rejectedData) {
            final isHovering = candidateData.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12),
                border: isHovering
                    ? Border.all(
                        color: Theme.of(context).colorScheme.primary,
                        width: 2,
                      )
                    : null,
              ),
              child: _buildFloorCard(context, floor, isDark),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFloorCard(BuildContext context, floor, bool isDark) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.drag_handle,
                        color: Theme.of(context).colorScheme.outline,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Consumer(
                          builder: (context, ref, child) {
                            return GestureDetector(
                              onTap: () => _showFloorNameEditDialog(context, floor, ref),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.edit,
                                    color: Theme.of(context).colorScheme.outline,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      floor.ad,
                                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Consumer(
                        builder: (context, ref, child) {
                          return IconButton(
                            onPressed: () {
                              ref.read(projectProvider.notifier).copyFloor(floor.id);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Kat kopyalandı'),
                                  duration: Duration(seconds: 1),
                                ),
                              );
                            },
                            icon: const Icon(Icons.copy),
                            iconSize: 20,
                            tooltip: 'Katı Kopyala',
                            visualDensity: VisualDensity.compact,
                          );
                        },
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    SizedBox(
                      width: 120,
                      child: Consumer(
                        builder: (context, ref, child) {
                          return TextFormField(
                            initialValue: floor.ortakAlan > 0 ? floor.ortakAlan.toString() : '',
                            decoration: InputDecoration(
                              labelText: 'Ortak Alan',
                              hintText: '0',
                              isDense: true,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 6,
                              ),
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [DecimalTextInputFormatter()],
                            textDirection: TextDirection.ltr,
                            enableInteractiveSelection: true,
                            style: Theme.of(context).textTheme.bodySmall,
                            onChanged: (value) {
                              final ortakAlan = NumberFormatter.parseNumber(value) ?? 0.0;
                              ref.read(projectProvider.notifier).updateFloor(
                                floor.id,
                                ortakAlan: ortakAlan,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
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
                        NumberFormatter.formatArea(floor.toplamAlan),
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSecondaryContainer,
                        ),
                      ),
                    ),
                  ],
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
              Consumer(
                builder: (context, ref, child) {
                  return _buildDraggableUnits(context, floor, isDark, ref);
                },
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDraggableUnits(BuildContext context, floor, bool isDark, WidgetRef ref) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: floor.daireler.asMap().entries.map<Widget>((entry) {
        final index = entry.key;
        final unit = entry.value;
        return _buildDraggableUnitCard(context, floor, unit, index, isDark, ref);
      }).toList(),
    );
  }

  Widget _buildDraggableUnitCard(BuildContext context, floor, UnitModel unit, int index, bool isDark, WidgetRef ref) {
    return LongPressDraggable<Map<String, dynamic>>(
      data: {
        'type': 'unit',
        'floorId': floor.id,
        'unitIndex': index,
        'unit': unit,
      },
      feedback: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(8),
        child: Opacity(
          opacity: 0.8,
          child: SizedBox(
            width: 140,
            child: _buildUnitCard(context, unit, isDark, floor, ref),
          ),
        ),
      ),
      childWhenDragging: Opacity(
        opacity: 0.5,
        child: _buildUnitCard(context, unit, isDark, floor, ref),
      ),
      child: DragTarget<Map<String, dynamic>>(
        onWillAcceptWithDetails: (details) {
          final data = details.data;
          return data['type'] == 'unit' && 
                 data['floorId'] == floor.id && 
                 data['unitIndex'] != index;
        },
        onAcceptWithDetails: (details) {
          final data = details.data;
          final oldIndex = data['unitIndex'] as int;
          final newIndex = index;
          
          if (oldIndex != newIndex) {
            ref.read(projectProvider.notifier).reorderUnits(floor.id, oldIndex, newIndex);
          }
        },
        builder: (context, candidateData, rejectedData) {
          final isHovering = candidateData.isNotEmpty;
          return AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: isHovering
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 2,
                    )
                  : null,
            ),
            child: _buildUnitCard(context, unit, isDark, floor, ref),
          );
        },
      ),
    );
  }

  Widget _buildUnitCard(BuildContext context, UnitModel unit, bool isDark, floor, WidgetRef ref) {
    final isMuteahhit = unit.malik == Malik.muteahhit;
    
    return GestureDetector(
      onTap: () => _showUnitEditDialog(context, unit, floor, ref),
      child: Container(
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
                Expanded(
                  child: Row(
                    children: [
                      Icon(
                        Icons.edit,
                        color: Theme.of(context).colorScheme.outline,
                        size: 12,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          unit.ad,
                          style: Theme.of(context).textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
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
            if (unit.cepheTarafi != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                margin: const EdgeInsets.only(bottom: 4),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  unit.cepheTarafi!.displayName,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 10,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
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
      ),
    );
  }

  Widget _buildCommercialSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final project = ref.watch(projectProvider);
        return Container(
          margin: const EdgeInsets.only(bottom: 16),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.tertiaryContainer,
            border: Border.all(
              color: Theme.of(context).colorScheme.tertiary,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.store,
                    color: Theme.of(context).colorScheme.onTertiaryContainer,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'TİCARİ ALAN / DÜKKAN',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onTertiaryContainer,
                    ),
                  ),
                ],
              ),
              if (project.ticariOrtakAlani > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.tertiary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    NumberFormatter.formatArea(project.ticariOrtakAlani),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Theme.of(context).colorScheme.onTertiary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  Widget _buildOtoparkSection(BuildContext context) {
    return Consumer(
      builder: (context, ref, child) {
        final project = ref.watch(projectProvider);
        return Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surfaceContainerHighest,
            border: Border.all(
              color: Theme.of(context).colorScheme.outline,
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.local_parking,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 24,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'OTOPARK',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (project.otoparkAlani > 0) ...[
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primary,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    NumberFormatter.formatArea(project.otoparkAlani),
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ] else ...[
                const SizedBox(height: 8),
                Text(
                  'Alan belirtilmemiş',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.outline,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ],
          ),
        );
      },
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

  void _showUnitEditDialog(BuildContext context, UnitModel unit, floor, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => _UnitEditDialog(
        unit: unit,
        floorId: floor.id,
        ref: ref,
      ),
    );
  }

  void _showFloorNameEditDialog(BuildContext context, floor, WidgetRef ref) {
    final controller = TextEditingController(text: floor.ad);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Kat Adını Düzenle'),
        content: TextFormField(
          controller: controller,
          decoration: const InputDecoration(
            labelText: 'Kat Adı',
            border: OutlineInputBorder(),
          ),
          textDirection: TextDirection.ltr,
          enableInteractiveSelection: true,
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              if (controller.text.trim().isNotEmpty) {
                ref.read(projectProvider.notifier).updateFloor(
                  floor.id,
                  ad: controller.text.trim(),
                );
                Navigator.of(context).pop();
              }
            },
            child: const Text('Kaydet'),
          ),
        ],
      ),
    ).then((_) => controller.dispose());
  }
}

class _UnitEditDialog extends StatefulWidget {
  const _UnitEditDialog({
    required this.unit,
    required this.floorId,
    required this.ref,
  });

  final UnitModel unit;
  final String floorId;
  final WidgetRef ref;

  @override
  State<_UnitEditDialog> createState() => _UnitEditDialogState();
}

class _UnitEditDialogState extends State<_UnitEditDialog> {
  late TextEditingController _adController;
  late TextEditingController _eskiBrutController;
  late TextEditingController _yeniBrutController;
  late Malik _selectedMalik;
  late CepheTarafi? _selectedCepheTarafi;

  @override
  void initState() {
    super.initState();
    _adController = TextEditingController(text: widget.unit.ad);
    _eskiBrutController = TextEditingController(
      text: widget.unit.eskiBrut?.toString() ?? '',
    );
    _yeniBrutController = TextEditingController(
      text: widget.unit.yeniBrut?.toString() ?? '',
    );
    _selectedMalik = widget.unit.malik;
    _selectedCepheTarafi = widget.unit.cepheTarafi;
  }

  @override
  void dispose() {
    _adController.dispose();
    _eskiBrutController.dispose();
    _yeniBrutController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Daire Düzenle'),
      content: SizedBox(
        width: 400,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _adController,
                decoration: const InputDecoration(
                  labelText: 'Daire Adı',
                  border: OutlineInputBorder(),
                ),
                textDirection: TextDirection.ltr,
                enableInteractiveSelection: true,
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<Malik>(
                initialValue: _selectedMalik,
                decoration: const InputDecoration(
                  labelText: 'Malik',
                  border: OutlineInputBorder(),
                ),
                items: Malik.values.map((malik) {
                  return DropdownMenuItem(
                    value: malik,
                    child: Text(malik.displayName),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedMalik = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),
              DropdownButtonFormField<CepheTarafi>(
                initialValue: _selectedCepheTarafi,
                decoration: const InputDecoration(
                  labelText: 'Cephe Tarafı',
                  border: OutlineInputBorder(),
                ),
                items: [
                  const DropdownMenuItem<CepheTarafi>(
                    value: null,
                    child: Text('Seçilmedi'),
                  ),
                  ...CepheTarafi.values.map((cephe) {
                    return DropdownMenuItem(
                      value: cephe,
                      child: Text(cephe.displayName),
                    );
                  }),
                ],
                onChanged: (value) {
                  setState(() {
                    _selectedCepheTarafi = value;
                  });
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _eskiBrutController,
                decoration: const InputDecoration(
                  labelText: 'Eski Brüt (m²)',
                  hintText: '99999',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [DecimalTextInputFormatter()],
                textDirection: TextDirection.ltr,
                enableInteractiveSelection: true,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _yeniBrutController,
                decoration: const InputDecoration(
                  labelText: 'Yeni Brüt (m²)',
                  hintText: '99999',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [DecimalTextInputFormatter()],
                textDirection: TextDirection.ltr,
                enableInteractiveSelection: true,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('İptal'),
        ),
        ElevatedButton(
          onPressed: _saveChanges,
          child: const Text('Kaydet'),
        ),
      ],
    );
  }

  void _saveChanges() {
    final eskiBrut = NumberFormatter.parseNumber(_eskiBrutController.text);
    final yeniBrut = NumberFormatter.parseNumber(_yeniBrutController.text);

    widget.ref.read(projectProvider.notifier).updateUnit(
      widget.floorId,
      widget.unit.id,
      ad: _adController.text,
      malik: _selectedMalik,
      cepheTarafi: _selectedCepheTarafi,
      eskiBrut: eskiBrut,
      yeniBrut: yeniBrut,
    );

    Navigator.of(context).pop();
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