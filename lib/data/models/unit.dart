import 'package:flutter/foundation.dart';

enum Malik {
  muteahhit('Müteahhit'),
  toprakSahibi('Toprak Sahibi');

  const Malik(this.displayName);
  final String displayName;
}

@immutable
class UnitModel {
  const UnitModel({
    required this.id,
    required this.ad,
    required this.malik,
    this.eskiBrut,
    this.yeniBrut,
  });

  final String id;
  final String ad;
  final Malik malik;
  final double? eskiBrut;
  final double? yeniBrut;

  UnitModel copyWith({
    String? id,
    String? ad,
    Malik? malik,
    double? eskiBrut,
    double? yeniBrut,
  }) {
    return UnitModel(
      id: id ?? this.id,
      ad: ad ?? this.ad,
      malik: malik ?? this.malik,
      eskiBrut: eskiBrut ?? this.eskiBrut,
      yeniBrut: yeniBrut ?? this.yeniBrut,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'ad': ad,
      'malik': malik.name,
      'eskiBrut': eskiBrut,
      'yeniBrut': yeniBrut,
    };
  }

  factory UnitModel.fromJson(Map<String, dynamic> json) {
    return UnitModel(
      id: json['id'] as String,
      ad: json['ad'] as String,
      malik: Malik.values.byName(json['malik'] as String),
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
        other.eskiBrut == eskiBrut &&
        other.yeniBrut == yeniBrut;
  }

  @override
  int get hashCode {
    return Object.hash(id, ad, malik, eskiBrut, yeniBrut);
  }

  @override
  String toString() {
    return 'UnitModel(id: $id, ad: $ad, malik: $malik, eskiBrut: $eskiBrut, yeniBrut: $yeniBrut)';
  }
}