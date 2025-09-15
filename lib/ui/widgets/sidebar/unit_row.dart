import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/unit.dart';
import '../../../state/project_provider.dart';
import '../../../core/formatters.dart';

class UnitRow extends ConsumerStatefulWidget {
  const UnitRow({
    super.key,
    required this.floorId,
    required this.unit,
  });

  final String floorId;
  final UnitModel unit;

  @override
  ConsumerState<UnitRow> createState() => _UnitRowState();
}

class _UnitRowState extends ConsumerState<UnitRow> {
  late TextEditingController _adController;
  late TextEditingController _eskiBrutController;
  late TextEditingController _yeniBrutController;

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
  }

  @override
  void dispose() {
    _adController.dispose();
    _eskiBrutController.dispose();
    _yeniBrutController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(UnitRow oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.unit != widget.unit) {
      _adController.text = widget.unit.ad;
      _eskiBrutController.text = widget.unit.eskiBrut?.toString() ?? '';
      _yeniBrutController.text = widget.unit.yeniBrut?.toString() ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            // İlk satır: Daire adı ve sil butonu
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _adController,
                    decoration: const InputDecoration(
                      labelText: 'Daire Adı',
                      isDense: true,
                    ),
                    onChanged: (value) {
                      ref.read(projectProvider.notifier).updateUnit(
                        widget.floorId,
                        widget.unit.id,
                        ad: value,
                      );
                    },
                  ),
                ),
                const SizedBox(width: 8),
                SizedBox(
                  width: 40,
                  child: IconButton(
                    onPressed: () => _showDeleteDialog(),
                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                    tooltip: 'Daireyi Sil',
                    padding: EdgeInsets.zero,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // İkinci satır: Malik dropdown
            DropdownButtonFormField<Malik>(
              value: widget.unit.malik,
              isExpanded: true,
              decoration: const InputDecoration(
                labelText: 'Malik',
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              items: Malik.values.map((malik) {
                return DropdownMenuItem(
                  value: malik,
                  child: Text(
                    malik.displayName,
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  ref.read(projectProvider.notifier).updateUnit(
                    widget.floorId,
                    widget.unit.id,
                    malik: value,
                  );
                }
              },
            ),
            const SizedBox(height: 8),
            // Üçüncü satır: Eski Brüt
            TextFormField(
              controller: _eskiBrutController,
              decoration: const InputDecoration(
                labelText: 'Eski Brüt (m²)',
                isDense: true,
                hintText: '99999',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [DecimalTextInputFormatter()],
              maxLength: 7, // 5 hane + nokta + ondalık
              onChanged: (value) {
                final eskiBrut = NumberFormatter.parseNumber(value);
                ref.read(projectProvider.notifier).updateUnit(
                  widget.floorId,
                  widget.unit.id,
                  eskiBrut: eskiBrut,
                );
              },
            ),
            const SizedBox(height: 8),
            // Dördüncü satır: Yeni Brüt
            TextFormField(
              controller: _yeniBrutController,
              decoration: const InputDecoration(
                labelText: 'Yeni Brüt (m²)',
                isDense: true,
                hintText: '99999',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [DecimalTextInputFormatter()],
              maxLength: 7, // 5 hane + nokta + ondalık
              onChanged: (value) {
                final yeniBrut = NumberFormatter.parseNumber(value);
                ref.read(projectProvider.notifier).updateUnit(
                  widget.floorId,
                  widget.unit.id,
                  yeniBrut: yeniBrut,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Daireyi Sil'),
        content: Text('${widget.unit.ad} dairesini silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(projectProvider.notifier).removeUnit(
                widget.floorId,
                widget.unit.id,
              );
              Navigator.of(context).pop();
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}