import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/project_provider.dart';

class ProjectForm extends ConsumerStatefulWidget {
  const ProjectForm({super.key});

  @override
  ConsumerState<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends ConsumerState<ProjectForm> {
  late TextEditingController _projeAdiController;
  late TextEditingController _adresController;

  @override
  void initState() {
    super.initState();
    _projeAdiController = TextEditingController();
    _adresController = TextEditingController();
  }

  @override
  void dispose() {
    _projeAdiController.dispose();
    _adresController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider);

    // Controller'ları güncelle (sadece değer değiştiğinde)
    if (_projeAdiController.text != project.projeAdi) {
      _projeAdiController.text = project.projeAdi;
    }
    if (_adresController.text != project.adres) {
      _adresController.text = project.adres;
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Proje Bilgileri',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _projeAdiController,
              decoration: const InputDecoration(
                labelText: 'Proje Adı',
                hintText: 'Proje adını giriniz',
              ),
              onChanged: (value) {
                ref.read(projectProvider.notifier).updateProjectInfo(
                  projeAdi: value,
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _adresController,
              decoration: const InputDecoration(
                labelText: 'Adres',
                hintText: 'Proje adresini giriniz',
              ),
              maxLines: 2,
              onChanged: (value) {
                ref.read(projectProvider.notifier).updateProjectInfo(
                  adres: value,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}