import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'project_provider.dart';

final toplamInsaatAlaniProvider = Provider<double>((ref) {
  final project = ref.watch(projectProvider);
  return project.toplamInsaatAlani;
});

final muteahhitToplamYeniBrutProvider = Provider<double>((ref) {
  final project = ref.watch(projectProvider);
  return project.muteahhitToplamYeniBrut;
});

final toprakSahibiToplamYeniBrutProvider = Provider<double>((ref) {
  final project = ref.watch(projectProvider);
  return project.toprakSahibiToplamYeniBrut;
});

final visibleKatlarProvider = Provider((ref) {
  final project = ref.watch(projectProvider);
  return project.katlar.where((kat) {
    if (kat.ad.toLowerCase().contains('çatı')) {
      return project.showCati;
    }
    return true;
  }).toList();
});