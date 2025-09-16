import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../state/project_provider.dart';
import '../../../core/formatters.dart';

class ProjectForm extends ConsumerStatefulWidget {
  const ProjectForm({super.key});

  @override
  ConsumerState<ProjectForm> createState() => _ProjectFormState();
}

class _ProjectFormState extends ConsumerState<ProjectForm> {
  late TextEditingController _projeAdiController;
  late TextEditingController _adresController;
  late TextEditingController _malSahibiController;
  late TextEditingController _cizenController;
  late TextEditingController _otoparkAlaniController;

  @override
  void initState() {
    super.initState();
    _projeAdiController = TextEditingController();
    _adresController = TextEditingController();
    _malSahibiController = TextEditingController();
    _cizenController = TextEditingController();
    _otoparkAlaniController = TextEditingController();
  }

  @override
  void dispose() {
    _projeAdiController.dispose();
    _adresController.dispose();
    _malSahibiController.dispose();
    _cizenController.dispose();
    _otoparkAlaniController.dispose();
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
    if (_malSahibiController.text != project.malSahibi) {
      _malSahibiController.text = project.malSahibi;
    }
    if (_cizenController.text != project.cizen) {
      _cizenController.text = project.cizen;
    }
    final otoparkText = project.otoparkAlani > 0 ? project.otoparkAlani.toString() : '';
    if (_otoparkAlaniController.text != otoparkText) {
      _otoparkAlaniController.text = otoparkText;
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
              textDirection: TextDirection.ltr,
              enableInteractiveSelection: true,
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
              textDirection: TextDirection.ltr,
              enableInteractiveSelection: true,
              onChanged: (value) {
                ref.read(projectProvider.notifier).updateProjectInfo(
                  adres: value,
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _malSahibiController,
              decoration: const InputDecoration(
                labelText: 'Mal Sahibi',
                hintText: 'Mal sahibi adını giriniz',
              ),
              textDirection: TextDirection.ltr,
              enableInteractiveSelection: true,
              onChanged: (value) {
                ref.read(projectProvider.notifier).updateProjectInfo(
                  malSahibi: value,
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _cizenController,
              decoration: const InputDecoration(
                labelText: 'Çizen',
                hintText: 'Mimar/çizen adını giriniz',
              ),
              textDirection: TextDirection.ltr,
              enableInteractiveSelection: true,
              onChanged: (value) {
                ref.read(projectProvider.notifier).updateProjectInfo(
                  cizen: value,
                );
              },
            ),
            const SizedBox(height: 12),
            TextFormField(
              controller: _otoparkAlaniController,
              decoration: const InputDecoration(
                labelText: 'Otopark Alanı (m²)',
                hintText: 'Otopark alanını giriniz',
              ),
              keyboardType: TextInputType.number,
              inputFormatters: [DecimalTextInputFormatter()],
              textDirection: TextDirection.ltr,
              enableInteractiveSelection: true,
              onChanged: (value) {
                final alan = NumberFormatter.parseNumber(value) ?? 0.0;
                ref.read(projectProvider.notifier).updateProjectInfo(
                  otoparkAlani: alan,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}