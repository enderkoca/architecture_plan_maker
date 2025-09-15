import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/project_provider.dart';

class ViewToggles extends ConsumerWidget {
  const ViewToggles({super.key});

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
              'Görünüm Ayarları',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            SwitchListTile(
              title: const Text('Çatı Alanı'),
              subtitle: const Text('Çatı katını göster/gizle'),
              value: project.showCati,
              onChanged: (value) {
                ref.read(projectProvider.notifier).updateViewSettings(
                  showCati: value,
                );
              },
              contentPadding: EdgeInsets.zero,
            ),
            SwitchListTile(
              title: const Text('Otopark'),
              subtitle: const Text('Otopark alanını göster/gizle'),
              value: project.showOtopark,
              onChanged: (value) {
                ref.read(projectProvider.notifier).updateViewSettings(
                  showOtopark: value,
                );
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
      ),
    );
  }
}