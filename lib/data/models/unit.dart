import 'package:flutter/foundation.dart';

enum Malik {
  muteahhit('Müteahhit'),
  toprakSahibi('Toprak Sahibi');

  const Malik(this.displayName);
  final String displayName;
}

enum CepheTarafi {
  kuzey('Kuzey'),
  guney('Güney'),
  dogu('Doğu'),
  bati('Batı'),
  kuzeydogu('Kuzey-Doğu'),
  kuzeybati('Kuzey-Batı'),
  guneydongu('Güney-Doğu'),
  guneybati('Güney-Batı');

  const CepheTarafi(this.displayName);
  final String displayName;
}

@immutable
class UnitModel {
  const UnitModel({
    required this.id,
    required this.ad,
    required this.malik,
    this.cepheTarafi,
    this.eskiBrut,
    this.yeniBrut,
  });

  final String id;
  final String ad;
  final Malik malik;
  final CepheTarafi? cepheTarafi;
  final double? eskiBrut;
  final double? yeniBrut;

  UnitModel copyWith({
    String? id,
    String? ad,
    Malik? malik,
    CepheTarafi? cepheTarafi,
    double? eskiBrut,
    double? yeniBrut,
  }) {
    return UnitModel(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      malik: malik ?? this.malik,
      cepheTarafi: cepheTarafi ?? this.cepheTarafi,
      eskiBrut: eskiBrut ?? this.eskiBrut,
      yeniBrut: yeniBrut ?? this.yeniBrut,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
      'malik': malik.name,
      'cepheTarafi': cepheTarafi?.name,
      'eskiBrut': eskiBrut,
      'yeniBrut': yeniBrut,
    };
  }

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String,
      ad: json['ad'] as String,
      malik: Malik.values.byName(json['malik'] as String),
      cepheTarafi: json['cepheTarafi'] != null 
          ? CepheTarafi.values.byName(json['cepheTarafi'] as String) 
          : null,
      eskiBrut: json['eskiBrut'] as double?,
      yeniBrut: json['yeniBrut'] as double?,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UnitModel &&
        other.id == id &&
        other.ad == ad &&
        other.malik == malik &&
        other.cepheTarafi == cepheTarafi &&
        other.eskiBrut == eskiBrut &&
        other.yeniBrut == yeniBrut;
  }

  @override
  int get hashCode {
    return Object.hash(id, ad, malik, cepheTarafi, eskiBrut, yeniBrut);
  }

  @override
  String toString() {
    return 'UnitModel(id: $id, ad: $ad, malik: $malik, cepheTarafi: $cepheTarafi, eskiBrut: $eskiBrut, yeniBrut: $yeniBrut)';
  }
}