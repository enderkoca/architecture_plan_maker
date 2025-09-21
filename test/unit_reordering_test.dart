import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_plan_maker/data/models/project.dart';
import 'package:architecture_plan_maker/data/models/floor.dart';
import 'package:architecture_plan_maker/data/models/unit.dart';

void main() {
  group('Unit Reordering Logic Tests', () {

    test('Daire sırasının değiştiği basit kontrol testi', () {
      // Test için basit birimler
      final units = [
        UnitModel(
          id: '1',
          ad: 'Daire 1',
          malik: Malik.muteahhit,
          yeniBrut: 50.0,
        ),
        UnitModel(
          id: '2',
          ad: 'Daire 2',
          malik: Malik.toprakSahibi,
          yeniBrut: 45.0,
        ),
        UnitModel(
          id: '3',
          ad: 'Daire 3',
          malik: Malik.muteahhit,
          yeniBrut: 40.0,
        ),
      ];

      // Sıralamanın doğru olduğunu kontrol et
      expect(units[0].ad, equals('Daire 1'));
      expect(units[1].ad, equals('Daire 2'));
      expect(units[2].ad, equals('Daire 3'));

      // Manuel sıralama değişimi (index 0'dan index 2'ye)
      final reorderedUnits = List<UnitModel>.from(units);
      final unit = reorderedUnits.removeAt(0);
      reorderedUnits.insert(2, unit);

      // Sıranın değiştiğini kontrol et
      expect(reorderedUnits[0].malik, equals(Malik.toprakSahibi)); // Eski Daire 2
      expect(reorderedUnits[1].malik, equals(Malik.muteahhit)); // Eski Daire 3
      expect(reorderedUnits[2].malik, equals(Malik.muteahhit)); // Eski Daire 1 (taşınan)
    });

    test('Daire numarası pattern matching testi', () {
      // RegExp testleri
      expect(RegExp(r'Daire (\d+)').hasMatch('Daire 1'), isTrue);
      expect(RegExp(r'Daire (\d+)').hasMatch('Daire 123'), isTrue);
      expect(RegExp(r'Daire (\d+)').hasMatch('Özel Daire'), isFalse);
      expect(RegExp(r'Daire (\d+)').hasMatch('Penthouse'), isFalse);
      
      // Numarası çıkarma testi
      final match = RegExp(r'Daire (\d+)').firstMatch('Daire 5');
      expect(match, isNotNull);
      expect(int.tryParse(match!.group(1)!), equals(5));
    });
  });
}