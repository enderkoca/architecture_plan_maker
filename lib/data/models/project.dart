import 'package:flutter/foundation.dart';
import 'floor.dart';
import 'unit.dart';

@immutable
class ProjectModel {
  const ProjectModel({
    required this.projeAdi,
    required this.adres,
    required this.katlar,
    this.showCati = true,
    this.showOtopark = true,
  });

  final String projeAdi;
  final String adres;
  final List<FloorModel> katlar;
  final bool showCati;
  final bool showOtopark;

  double get toplamInsaatAlani {
    return katlar.fold(0.0, (sum, kat) => sum + kat.alan);
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

  ProjectModel copyWith({
    String? projeAdi,
    String? adres,
    List<FloorModel>? katlar,
    bool? showCati,
    bool? showOtopark,
  }) {
    return ProjectModel(
      projeAdi: projeAdi ?? this.projeAdi,
      adres: adres ?? this.adres,
      katlar: katlar ?? this.katlar,
      showCati: showCati ?? this.showCati,
      showOtopark: showOtopark ?? this.showOtopark,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'projeAdi': projeAdi,
      'adres': adres,
      'katlar': katlar.map((k) => k.toJson()).toList(),
      'showCati': showCati,
      'showOtopark': showOtopark,
    };
  }

  factory ProjectModel.fromJson(Map<String, dynamic> json) {
    return ProjectModel(
      projeAdi: json['projeAdi'] as String,
      adres: json['adres'] as String,
      katlar: (json['katlar'] as List<dynamic>)
          .map((k) => FloorModel.fromJson(k as Map<String, dynamic>))
          .toList(),
      showCati: json['showCati'] as bool? ?? true,
      showOtopark: json['showOtopark'] as bool? ?? true,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProjectModel &&
        other.projeAdi == projeAdi &&
        other.adres == adres &&
        listEquals(other.katlar, katlar) &&
        other.showCati == showCati &&
        other.showOtopark == showOtopark;
  }

  @override
  int get hashCode {
    return Object.hash(
      projeAdi,
      adres,
      Object.hashAll(katlar),
      showCati,
      showOtopark,
    );
  }

  @override
  String toString() {
    return 'ProjectModel(projeAdi: $projeAdi, adres: $adres, katlar: ${katlar.length}, showCati: $showCati, showOtopark: $showOtopark)';
  }
}