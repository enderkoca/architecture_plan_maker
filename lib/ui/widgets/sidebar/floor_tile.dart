import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../data/models/floor.dart';
import '../../../state/project_provider.dart';
import '../../../core/formatters.dart';
import 'unit_row.dart';

class FloorTile extends ConsumerStatefulWidget {
  const FloorTile({super.key, required this.floor});

  final FloorModel floor;

  @override
  ConsumerState<FloorTile> createState() => _FloorTileState();
}

class _FloorTileState extends ConsumerState<FloorTile> {
  late TextEditingController _adController;
  late TextEditingController _alanController;
  late TextEditingController _aciklamaController;

  @override
  void initState() {
    super.initState();
    _adController = TextEditingController(text: widget.floor.ad);
    _alanController = TextEditingController(
      text: widget.floor.alan > 0 ? widget.floor.alan.toString() : '',
    );
    _aciklamaController = TextEditingController(text: widget.floor.aciklama ?? '');
  }

  @override
  void dispose() {
    _adController.dispose();
    _alanController.dispose();
    _aciklamaController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(FloorTile oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.floor != widget.floor) {
      _adController.text = widget.floor.ad;
      _alanController.text = widget.floor.alan > 0 ? widget.floor.alan.toString() : '';
      _aciklamaController.text = widget.floor.aciklama ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Column(
        children: [
          ListTile(
            leading: IconButton(
              onPressed: () {
                ref.read(projectProvider.notifier).toggleFloorCollapsed(widget.floor.id);
              },
              icon: Icon(
                widget.floor.collapsed ? Icons.expand_more : Icons.expand_less,
              ),
            ),
            title: Text(widget.floor.ad),
            subtitle: Text(NumberFormatter.formatArea(widget.floor.alan)),
            trailing: PopupMenuButton<String>(
              onSelected: (value) {
                if (value == 'delete') {
                  _showDeleteDialog();
                }
              },
              itemBuilder: (context) => [
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(
                    children: [
                      Icon(Icons.delete, color: Colors.red),
                      SizedBox(width: 8),
                      Text('Katı Sil'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (!widget.floor.collapsed) ...[
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: _adController,
                          decoration: const InputDecoration(
                            labelText: 'Kat Adı',
                            isDense: true,
                          ),
                          onChanged: (value) {
                            ref.read(projectProvider.notifier).updateFloor(
                              widget.floor.id,
                              ad: value,
                            );
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextFormField(
                          controller: _alanController,
                          decoration: const InputDecoration(
                            labelText: 'Alan (m²)',
                            isDense: true,
                            hintText: '99999',
                          ),
                          keyboardType: TextInputType.number,
                          inputFormatters: [DecimalTextInputFormatter()],
                          maxLength: 7, // 5 hane + nokta + ondalık
                          onChanged: (value) {
                            final alan = NumberFormatter.parseNumber(value) ?? 0.0;
                            ref.read(projectProvider.notifier).updateFloor(
                              widget.floor.id,
                              alan: alan,
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _aciklamaController,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama (opsiyonel)',
                      isDense: true,
                    ),
                    maxLines: 2,
                    onChanged: (value) {
                      ref.read(projectProvider.notifier).updateFloor(
                        widget.floor.id,
                        aciklama: value.isEmpty ? null : value,
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Daireler (${widget.floor.daireler.length})',
                        style: Theme.of(context).textTheme.titleSmall,
                      ),
                      IconButton(
                        onPressed: () {
                          ref.read(projectProvider.notifier).addUnit(widget.floor.id);
                        },
                        icon: const Icon(Icons.add),
                        tooltip: 'Daire Ekle',
                      ),
                    ],
                  ),
                  if (widget.floor.daireler.isEmpty)
                    Container(
                      padding: const EdgeInsets.all(16),
                      child: Text(
                        'Bu kata henüz daire eklenmemiş',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context).colorScheme.outline,
                        ),
                      ),
                    )
                  else
                    ...widget.floor.daireler.map((unit) => UnitRow(
                      key: ValueKey(unit.id),
                      floorId: widget.floor.id,
                      unit: unit,
                    )),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _showDeleteDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Katı Sil'),
        content: Text('${widget.floor.ad} katını silmek istediğinizden emin misiniz?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('İptal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(projectProvider.notifier).removeFloor(widget.floor.id);
              Navigator.of(context).pop();
            },
            child: const Text('Sil'),
          ),
        ],
      ),
    );
  }
}