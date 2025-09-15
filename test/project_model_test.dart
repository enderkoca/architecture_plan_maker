import 'package:flutter_test/flutter_test.dart';
import 'package:architecture_plan_maker/data/models/project.dart';
import 'package:architecture_plan_maker/data/models/floor.dart';
import 'package:architecture_plan_maker/data/models/unit.dart';

void main() {
  group('ProjectModel Tests', () {
    late ProjectModel project;

    setUp(() {
      project = ProjectModel(
        projeAdi: 'Test Projesi',
        adres: 'Test Adres',
        katlar: [
          FloorModel(
            id: '1',
            ad: 'Zemin Kat',
            alan: 100.0,
            daireler: [
              UnitModel(
                id: '1',
                ad: 'Daire 1',
                malik: Malik.muteahhit,
                eskiBrut: 50.0,
                yeniBrut: 60.0,
              ),
              UnitModel(
                id: '2',
                ad: 'Daire 2',
                malik: Malik.toprakSahibi,
                eskiBrut: 45.0,
                yeniBrut: 55.0,
              ),
            ],
          ),
          FloorModel(
            id: '2',
            ad: '1. Kat',
            alan: 90.0,
            daireler: [
              UnitModel(
                id: '3',
                ad: 'Daire 3',
                malik: Malik.muteahhit,
                eskiBrut: 40.0,
                yeniBrut: 50.0,
              ),
            ],
          ),
        ],
      );
    });

    test('toplamInsaatAlani hesaplama testi', () {
      expect(project.toplamInsaatAlani, equals(190.0));
    });

    test('muteahhitToplamYeniBrut hesaplama testi', () {
      expect(project.muteahhitToplamYeniBrut, equals(110.0));
    });

    test('toprakSahibiToplamYeniBrut hesaplama testi', () {
      expect(project.toprakSahibiToplamYeniBrut, equals(55.0));
    });

    test('JSON serialization/deserialization testi', () {
      final json = project.toJson();
      final restoredProject = ProjectModel.fromJson(json);
      
      expect(restoredProject.projeAdi, equals(project.projeAdi));
      expect(restoredProject.adres, equals(project.adres));
      expect(restoredProject.katlar.length, equals(project.katlar.length));
      expect(restoredProject.toplamInsaatAlani, equals(project.toplamInsaatAlani));
    });

    test('copyWith metodu testi', () {
      final updatedProject = project.copyWith(
        projeAdi: 'Yeni Proje Adı',
        showCati: false,
      );
      
      expect(updatedProject.projeAdi, equals('Yeni Proje Adı'));
      expect(updatedProject.adres, equals(project.adres));
      expect(updatedProject.showCati, equals(false));
      expect(updatedProject.showOtopark, equals(project.showOtopark));
    });

    test('boş proje hesaplama testi', () {
      final emptyProject = ProjectModel(
        projeAdi: 'Boş Proje',
        adres: '',
        katlar: [],
      );
      
      expect(emptyProject.toplamInsaatAlani, equals(0.0));
      expect(emptyProject.muteahhitToplamYeniBrut, equals(0.0));
      expect(emptyProject.toprakSahibiToplamYeniBrut, equals(0.0));
    });
  });
}