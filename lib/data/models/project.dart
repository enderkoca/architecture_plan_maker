import 'package:flutter/foundation.dart';
import 'floor.dart';
import 'unit.dart';

@immutable
class ProjectModel {
  const ProjectModel({
    required this.projeAdi,
    required this.adres,
    required this.katlar,
    this.malSahibi = '',
    this.showCati = true,
    this.showOtopark = true,
    this.otoparkAlani = 0.0,
  });

  final String projeAdi;
  final String adres;
  final String malSahibi;
  final List<FloorModel> katlar;
  final bool showCati;
  final bool showOtopark;
  final double otoparkAlani;

  double get toplamInsaatAlani {
    return katlar.fold(0.0, (sum, kat) => sum + kat.toplamAlan);
  }

  double get toplamInsaatAlaniOtoparkDahil {
    return toplamInsaatAlani + otoparkAlani;
  }

  double get muteahhitToplamYeniBrut {
    return katlar
        .expand((kat) => kat.daireler)
        .where((daire) => daire.malik == Malik.muteahhit)
        .fold(0.0, (sum, daire) => sum + (daire.yeniBrut ?? 0.0));
  }

  double get toprakSahibiToplamYeniBrut {
    return katlar
        .expand((kat) => kat.daireler)
        .where((daire) => daire.malik == Malik.toprakSahibi)
        .fold(0.0, (sum, daire) => sum + (daire.yeniBrut ?? 0.0));
  }

  // Toplam brüt alan (ortak alanlar hariç)
  double get toplamBrutAlanOrtakAlanHaric {
    return katlar
        .expand((kat) => kat.daireler)
        .fold(0.0, (sum, daire) => sum + (daire.yeniBrut ?? daire.eskiBrut ?? 0.0));
  }

  // Müteahhit yüzdesi = Müteahhit brüt alanı / Toplam brüt alan (ortak alan hariç)
  double get muteahhitYuzdesi {
    final toplamBrut = toplamBrutAlanOrtakAlanHaric;
    if (toplamBrut == 0) return 0.0;
    return (muteahhitToplamYeniBrut / toplamBrut) * 100;
  }

  // Toprak sahibi yüzdesi = Toprak sahibi brüt alanı / Toplam brüt alan (ortak alan hariç)  
  double get toprakSahibiYuzdesi {
    final toplamBrut = toplamBrutAlanOrtakAlanHaric;
    if (toplamBrut == 0) return 0.0;
    return (toprakSahibiToplamYeniBrut / toplamBrut) * 100;
  }

  ProjectModel copyWith({
    String? projeAdi,
    String? adres,
    String? malSahibi,
    List<FloorModel>? katlar,
    bool? showCati,
    bool? showOtopark,
    double? otoparkAlani,
  }) {
    return ProjectModel(
      projeAdi: projeAdi ?? this.projeAdi,
      adres: adres ?? this.adres,
      malSahibi: malSahibi ?? this.malSahibi,
      katlar: katlar ?? this.katlar,
      showCati: showCati ?? this.showCati,
      showOtopark: showOtopark ?? this.showOtopark,
      otoparkAlani: otoparkAlani ?? this.otoparkAlani,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projeAdi': projeAdi,
      'adres': adres,
      'malSahibi': malSahibi,
      'katlar': katlar.map((k) => k.toJson()).toList(),
      'showCati': showCati,
      'showOtopark': showOtopark,
      'otoparkAlani': otoparkAlani,
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projeAdi: json['projeAdi'] as String,
      adres: json['adres'] as String,
      malSahibi: json['malSahibi'] as String? ?? '',
      katlar: (json['katlar'] as List<dynamic>)
          .map((k) => FloorModel.fromJson(k as Map<String, dynamic>))
          .toList(),
      showCati: json['showCati'] as bool? ?? true,
      showOtopark: json['showOtopark'] as bool? ?? true,
      otoparkAlani: json['otoparkAlani'] as double? ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectModel &&
        other.projeAdi == projeAdi &&
        other.adres == adres &&
        other.malSahibi == malSahibi &&
        listEquals(other.katlar, katlar) &&
        other.showCati == showCati &&
        other.showOtopark == showOtopark &&
        other.otoparkAlani == otoparkAlani;
  }

  @override
  int get hashCode {
    return Object.hash(
      projeAdi,
      adres,
      malSahibi,
      Object.hashAll(katlar),
      showCati,
      showOtopark,
      otoparkAlani,
    );
  }

  @override
  String toString() {
    return 'ProjectModel(projeAdi: $projeAdi, adres: $adres, malSahibi: $malSahibi, katlar: ${katlar.length}, showCati: $showCati, showOtopark: $showOtopark, otoparkAlani: $otoparkAlani)';
  }
}