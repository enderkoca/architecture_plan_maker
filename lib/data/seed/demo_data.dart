import '../models/project.dart';
import '../models/floor.dart';
import '../models/unit.dart';

class DemoData {
  static ProjectModel get sampleProject {
    return ProjectModel(
      projeAdi: 'Örnek Mimari Projesi',
      adres: 'İstanbul, Beşiktaş - Örnek Mahalle, No: 123',
      malSahibi: 'Ahmet Yılmaz',
      cizen: 'Mimar Ayşe Demir',
      showCati: true,
      showOtopark: true,
      katlar: [
        FloorModel(
          id: 'zemin',
          ad: 'Zemin Kat',
          alan: 850.0,
          daireler: [
            UnitModel(
              id: 'z1',
              ad: 'Z-1',
              malik: Malik.muteahhit,
              eskiBrut: 95.0,
              yeniBrut: 120.0,
            ),
            UnitModel(
              id: 'z2',
              ad: 'Z-2',
              malik: Malik.toprakSahibi,
              eskiBrut: 85.0,
              yeniBrut: 110.0,
            ),
            UnitModel(
              id: 'z3',
              ad: 'Z-3',
              malik: Malik.muteahhit,
              eskiBrut: 78.0,
              yeniBrut: 105.0,
            ),
          ],
        ),
        FloorModel(
          id: 'birinci',
          ad: '1. Kat',
          alan: 820.0,
          daireler: [
            UnitModel(
              id: '1a',
              ad: '1-A',
              malik: Malik.toprakSahibi,
              eskiBrut: 90.0,
              yeniBrut: 115.0,
            ),
            UnitModel(
              id: '1b',
              ad: '1-B',
              malik: Malik.muteahhit,
              eskiBrut: 88.0,
              yeniBrut: 112.0,
            ),
            UnitModel(
              id: '1c',
              ad: '1-C',
              malik: Malik.muteahhit,
              eskiBrut: 82.0,
              yeniBrut: 108.0,
            ),
            UnitModel(
              id: '1d',
              ad: '1-D',
              malik: Malik.toprakSahibi,
              eskiBrut: 75.0,
              yeniBrut: 98.0,
            ),
          ],
        ),
        FloorModel(
          id: 'ikinci',
          ad: '2. Kat',
          alan: 820.0,
          daireler: [
            UnitModel(
              id: '2a',
              ad: '2-A',
              malik: Malik.muteahhit,
              eskiBrut: 90.0,
              yeniBrut: 115.0,
            ),
            UnitModel(
              id: '2b',
              ad: '2-B',
              malik: Malik.toprakSahibi,
              eskiBrut: 88.0,
              yeniBrut: 112.0,
            ),
            UnitModel(
              id: '2c',
              ad: '2-C',
              malik: Malik.muteahhit,
              eskiBrut: 82.0,
              yeniBrut: 108.0,
            ),
          ],
        ),
        FloorModel(
          id: 'cati',
          ad: 'Çatı Katı',
          alan: 650.0,
          daireler: [
            UnitModel(
              id: 'c1',
              ad: 'Çatı-1',
              malik: Malik.muteahhit,
              eskiBrut: 120.0,
              yeniBrut: 145.0,
            ),
            UnitModel(
              id: 'c2',
              ad: 'Çatı-2',
              malik: Malik.toprakSahibi,
              eskiBrut: 115.0,
              yeniBrut: 140.0,
            ),
          ],
        ),
      ],
    );
  }

  static ProjectModel get emptyProject {
    return const ProjectModel(
      projeAdi: '',
      adres: '',
      malSahibi: '',
      cizen: '',
      katlar: [],
      showCati: true,
      showOtopark: true,
    );
  }
}