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
  });

  final String id;
  final String ad;
  final double alan;
  final List<UnitModel> daireler;
  final bool collapsed;
  final String? aciklama;

  FloorModel copyWith({
    String? id,
    String? ad,
    double? alan,
    List<UnitModel>? daireler,
    bool? collapsed,
    String? aciklama,
  }) {
    return FloorModel(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      alan: alan ?? this.alan,
      daireler: daireler ?? this.daireler,
      collapsed: collapsed ?? this.collapsed,
      aciklama: aciklama ?? this.aciklama,
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
        other.aciklama == aciklama;
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
    );
  }

  @override
  String toString() {
    return 'FloorModel(id: $id, ad: $ad, alan: $alan, daireler: ${daireler.length}, collapsed: $collapsed, aciklama: $aciklama)';
  }
}