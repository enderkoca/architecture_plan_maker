import 'package:flutter/foundation.dart';
import 'unit.dart';

@immutable
class FloorModel {
  const FloorModel({
    required this.id,
    required this.ad,
    required this.alan,
    required this.daireler,
    this.collapsed = false,
    this.aciklama,
    this.ortakAlan = 0.0,
  });

  final String id;
  final String ad;
  final double alan;
  final List<UnitModel> daireler;
  final bool collapsed;
  final String? aciklama;
  final double ortakAlan;

  double get toplamAlan {
    final dairelerToplami = daireler.fold<double>(0.0, (sum, daire) {
      return sum + (daire.yeniBrut ?? daire.eskiBrut ?? 0.0);
    });
    return dairelerToplami + ortakAlan;
  }

  FloorModel copyWith({
    String? id,
    String? ad,
    double? alan,
    List<UnitModel>? daireler,
    bool? collapsed,
    String? aciklama,
    double? ortakAlan,
  }) {
    return FloorModel(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      alan: alan ?? this.alan,
      daireler: daireler ?? this.daireler,
      collapsed: collapsed ?? this.collapsed,
      aciklama: aciklama ?? this.aciklama,
      ortakAlan: ortakAlan ?? this.ortakAlan,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
      'alan': alan,
      'daireler': daireler.map((d) => d.toJson()).toList(),
      'collapsed': collapsed,
      'aciklama': aciklama,
      'ortakAlan': ortakAlan,
    };
  }

  factory FloorModel.fromJson(Map<String, dynamic> json) {
    return FloorModel(
      id: json['id'] as String,
      ad: json['ad'] as String,
      alan: json['alan'] as double,
      daireler: (json['daireler'] as List<dynamic>)
          .map((d) => UnitModel.fromJson(d as Map<String, dynamic>))
          .toList(),
      collapsed: json['collapsed'] as bool? ?? false,
      aciklama: json['aciklama'] as String?,
      ortakAlan: json['ortakAlan'] as double? ?? 0.0,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is FloorModel &&
        other.id == id &&
        other.ad == ad &&
        other.alan == alan &&
        listEquals(other.daireler, daireler) &&
        other.collapsed == collapsed &&
        other.aciklama == aciklama &&
        other.ortakAlan == ortakAlan;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      ad,
      alan,
      Object.hashAll(daireler),
      collapsed,
      aciklama,
      ortakAlan,
    );
  }

  @override
  String toString() {
    return 'FloorModel(id: $id, ad: $ad, alan: $alan, daireler: ${daireler.length}, collapsed: $collapsed, aciklama: $aciklama, ortakAlan: $ortakAlan)';
  }
}