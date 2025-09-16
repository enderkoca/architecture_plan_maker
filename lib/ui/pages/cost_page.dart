import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../state/project_provider.dart';
import '../../core/formatters.dart';

class CostPage extends ConsumerStatefulWidget {
  const CostPage({super.key});

  @override
  ConsumerState<CostPage> createState() => _CostPageState();
}

class _CostPageState extends ConsumerState<CostPage> {
  late TextEditingController _birimMaliyetController;
  late TextEditingController _toplamInsaatAlaniController;
  late TextEditingController _kabaYapiFiyatController;
  late TextEditingController _inceyapiFiyatController;
  late TextEditingController _anahtarTeslimFiyatController;

  @override
  void initState() {
    super.initState();
    _birimMaliyetController = TextEditingController();
    _toplamInsaatAlaniController = TextEditingController();
    _kabaYapiFiyatController = TextEditingController();
    _inceyapiFiyatController = TextEditingController();
    _anahtarTeslimFiyatController = TextEditingController();
  }

  @override
  void dispose() {
    _birimMaliyetController.dispose();
    _toplamInsaatAlaniController.dispose();
    _kabaYapiFiyatController.dispose();
    _inceyapiFiyatController.dispose();
    _anahtarTeslimFiyatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final project = ref.watch(projectProvider);
    
    // Otomatik hesaplamalar
    final birimMaliyet = NumberFormatter.parseNumber(_birimMaliyetController.text) ?? 0.0;
    final toplamAlan = NumberFormatter.parseNumber(_toplamInsaatAlaniController.text) ?? project.toplamInsaatAlani;
    final toplamMaliyet = birimMaliyet * toplamAlan;
    
    final kabaYapiFiyat = NumberFormatter.parseNumber(_kabaYapiFiyatController.text) ?? 0.0;
    final inceyapiFiyat = NumberFormatter.parseNumber(_inceyapiFiyatController.text) ?? 0.0;
    final anahtarTeslimFiyat = NumberFormatter.parseNumber(_anahtarTeslimFiyatController.text) ?? 0.0;
    
    final yukleniciKabaYapiAlan = project.muteahhitToplamYeniBrut;
    final yukleniciInceyapiAlan = project.muteahhitToplamYeniBrut;
    final yukleniciAnahtarTeslimAlan = project.muteahhitToplamYeniBrut;
    
    final yukleniciKabaYapiMaliyet = yukleniciKabaYapiAlan * kabaYapiFiyat;
    final yukleniciInceyapiMaliyet = yukleniciInceyapiAlan * inceyapiFiyat;
    final yukleniciAnahtarTeslimMaliyet = yukleniciAnahtarTeslimAlan * anahtarTeslimFiyat;

    // Controller'ları güncelle
    if (_toplamInsaatAlaniController.text.isEmpty) {
      _toplamInsaatAlaniController.text = toplamAlan > 0 ? toplamAlan.toString() : '';
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Maliyet Hesaplama'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Genel Maliyet Kartı
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Genel Maliyet Bilgileri',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: _toplamInsaatAlaniController,
                            decoration: const InputDecoration(
                              labelText: 'Toplam İnşaat Alanı (m²)',
                              hintText: 'Manuel alan giriniz',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [DecimalTextInputFormatter()],
                            textDirection: TextDirection.ltr,
                            enableInteractiveSelection: true,
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextFormField(
                            controller: _birimMaliyetController,
                            decoration: const InputDecoration(
                              labelText: 'Birim Maliyet (₺/m²)',
                              hintText: 'M² başına maliyet',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [DecimalTextInputFormatter()],
                            textDirection: TextDirection.ltr,
                            enableInteractiveSelection: true,
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.primaryContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Toplam Maliyet:',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            '${NumberFormatter.formatNumber(toplamMaliyet)} ₺',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            // Yüklenici Fizibilite Kartı
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Yüklenici Fizibilite Hesaplama',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Yüklenici Payı: ${NumberFormatter.formatArea(yukleniciKabaYapiAlan)}',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Kaba Yapı
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _kabaYapiFiyatController,
                            decoration: const InputDecoration(
                              labelText: 'Kaba Yapı (₺/m²)',
                              hintText: 'Kaba yapı birim fiyatı',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [DecimalTextInputFormatter()],
                            textDirection: TextDirection.ltr,
                            enableInteractiveSelection: true,
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Toplam: ${NumberFormatter.formatNumber(yukleniciKabaYapiMaliyet)} ₺',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // İnce Yapı
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _inceyapiFiyatController,
                            decoration: const InputDecoration(
                              labelText: 'İnce Yapı (₺/m²)',
                              hintText: 'İnce yapı birim fiyatı',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [DecimalTextInputFormatter()],
                            textDirection: TextDirection.ltr,
                            enableInteractiveSelection: true,
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Toplam: ${NumberFormatter.formatNumber(yukleniciInceyapiMaliyet)} ₺',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    // Anahtar Teslim
                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: TextFormField(
                            controller: _anahtarTeslimFiyatController,
                            decoration: const InputDecoration(
                              labelText: 'Anahtar Teslim (₺/m²)',
                              hintText: 'Anahtar teslim birim fiyatı',
                            ),
                            keyboardType: TextInputType.number,
                            inputFormatters: [DecimalTextInputFormatter()],
                            textDirection: TextDirection.ltr,
                            enableInteractiveSelection: true,
                            onChanged: (value) => setState(() {}),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          flex: 3,
                          child: Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              'Toplam: ${NumberFormatter.formatNumber(yukleniciAnahtarTeslimMaliyet)} ₺',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}