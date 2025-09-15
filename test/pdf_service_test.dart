import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/services.dart';
import 'package:architecture_plan_maker/services/pdf_service.dart';
import 'package:architecture_plan_maker/data/seed/demo_data.dart';

void main() {
  group('PdfService Tests', () {
    late PdfService pdfService;

    setUpAll(() {
      TestWidgetsFlutterBinding.ensureInitialized();
    });

    setUp(() {
      pdfService = PdfService();
    });

    test('PDF servisinin oluşturulması testi', () {
      expect(pdfService, isNotNull);
    });

    test('Demo proje verisinin geçerliliği testi', () {
      final project = DemoData.sampleProject;
      
      expect(project.projeAdi, isNotEmpty);
      expect(project.katlar, isNotEmpty);
      expect(project.toplamInsaatAlani, greaterThan(0));
    });
  });
}