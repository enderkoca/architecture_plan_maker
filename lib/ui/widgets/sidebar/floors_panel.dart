import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/project_provider.dart';
import 'floor_tile.dart';

class FloorsPanel extends ConsumerWidget {
  const FloorsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final project = ref.watch(projectProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Katlar',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  onPressed: () {
                    ref.read(projectProvider.notifier).addFloor();
                  },
                  icon: const Icon(Icons.add),
                  tooltip: 'Kat Ekle',
                ),
              ],
            ),
            const SizedBox(height: 8),
            if (project.katlar.isEmpty)
              Container(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    Icon(
                      Icons.apartment_outlined,
                      size: 48,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Henüz kat eklenmemiş',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.outline,
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: () {
                        ref.read(projectProvider.notifier).addFloor();
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('İlk Katı Ekle'),
                    ),
                  ],
                ),
              )
            else
              ReorderableListView(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                onReorder: (oldIndex, newIndex) {
                  if (newIndex > oldIndex) newIndex--;
                  ref.read(projectProvider.notifier).reorderFloors(oldIndex, newIndex);
                },
                children: project.katlar.asMap().entries.map((entry) {
                  final floor = entry.value;
                  return FloorTile(
                    key: ValueKey(floor.id),
                    floor: floor,
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}