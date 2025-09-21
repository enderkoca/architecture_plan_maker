import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/project.dart';
import '../data/models/unit.dart';
import '../core/formatters.dart';

class PdfService {
  Future<void> generateAndDownloadPDF(ProjectModel project, {bool buildingOnly = false}) async {
    final pdf = pw.Document();
    
    // Load font that supports Turkish characters
    final font = await PdfGoogleFonts.robotoRegular();
    final fontBold = await PdfGoogleFonts.robotoBold();

    if (buildingOnly) {
      // Building-only PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return _buildBuildingOnlyContent(project, font, fontBold);
          },
        ),
      );
    } else {
      // Full report PDF
      pdf.addPage(
        pw.Page(
          pageFormat: PdfPageFormat.a4.landscape,
          margin: const pw.EdgeInsets.all(24),
          build: (pw.Context context) {
            return _buildFullReportContent(project, font, fontBold);
          },
        ),
      );
    }

    final filename = ProjectFilenameGenerator.generate(project.projeAdi);
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: filename,
    );
  }

  pw.Widget _buildFullReportContent(ProjectModel project, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildHeader(project, font, fontBold),
        pw.SizedBox(height: 16),
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Sol taraf - Canvas
              pw.Expanded(
                flex: 7,
                child: _buildCanvas(project, font, fontBold),
              ),
              pw.SizedBox(width: 16),
              // Sağ taraf - Detaylı tablo ve bilgiler
              pw.Expanded(
                flex: 3,
                child: _buildRightPanel(project, font, fontBold),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        _buildFooterInfo(project, font, fontBold),
        pw.SizedBox(height: 12),
        _buildCompanyFooter(font, fontBold),
      ],
    );
  }

  pw.Widget _buildBuildingOnlyContent(ProjectModel project, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildHeader(project, font, fontBold),
        pw.SizedBox(height: 24),
        pw.Expanded(
          child: _buildCanvas(project, font, fontBold),
        ),
      ],
    );
  }

  pw.Widget _buildHeader(ProjectModel project, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          project.projeAdi.isEmpty ? 'Başlıksız Proje' : project.projeAdi,
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
            font: fontBold,
          ),
        ),
        if (project.adres.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            project.adres,
            style: pw.TextStyle(fontSize: 10, font: font),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildCanvas(ProjectModel project, pw.Font font, pw.Font fontBold) {
    final visibleKatlar = project.katlar;

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildSummaryStrip(project, font, fontBold),
        pw.SizedBox(height: 12),
        pw.Expanded(
          child: _buildScaledBuilding(project, visibleKatlar, font, fontBold),
        ),
      ],
    );
  }

  pw.Widget _buildScaledBuilding(ProjectModel project, List visibleKatlar, pw.Font font, pw.Font fontBold) {
    if (visibleKatlar.isEmpty) {
      return pw.Center(
        child: pw.Text(
          'Proje için henüz kat eklenmemiş',
          style: pw.TextStyle(fontSize: 12, color: PdfColors.grey, font: font),
        ),
      );
    }

    // Katları aşağıdan yukarıya sırala (zemin kat altta, üst katlar yukarıda)
    final sortedKatlar = List.from(visibleKatlar.reversed);
    
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        // Çatı en üstte
        if (project.showCati)
          pw.Container(
            height: _calculateRoofHeight(sortedKatlar.length),
            child: _buildCatiRoof(font),
          ),
        
        // Katlar (en üstten başlayarak)
        ...sortedKatlar.map((kat) => 
          pw.Expanded(
            child: _buildScaledFloorCard(kat, sortedKatlar.length, font, fontBold),
          ),
        ),
        
        // Otopark en altta
        if (project.showOtopark)
          pw.Container(
            height: _calculateOtoparkHeight(sortedKatlar.length),
            child: _buildOtoparkSection(font, fontBold),
          ),
      ],
    );
  }

  double _calculateRoofHeight(int floorCount) {
    // Kat sayısına göre çatı yüksekliği hesapla
    if (floorCount <= 3) return 40;
    if (floorCount <= 6) return 30;
    return 20;
  }

  double _calculateOtoparkHeight(int floorCount) {
    // Kat sayısına göre otopark yüksekliği hesapla
    if (floorCount <= 3) return 30;
    if (floorCount <= 6) return 25;
    return 20;
  }

  pw.Widget _buildSummaryStrip(ProjectModel project, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: PdfColors.blue50,
        border: pw.Border.all(color: PdfColors.blue200),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem(
            'Toplam İnşaat Alanı',
            NumberFormatter.formatArea(project.toplamInsaatAlani),
            font,
            fontBold,
          ),
          _buildSummaryItem(
            'Müteahhit Brüt Alanı',
            '${NumberFormatter.formatArea(project.muteahhitToplamYeniBrut)} (${project.muteahhitYuzdesi.toStringAsFixed(1)}%)',
            font,
            fontBold,
          ),
          _buildSummaryItem(
            'Toprak Sahibi Brüt Alanı',
            '${NumberFormatter.formatArea(project.toprakSahibiToplamYeniBrut)} (${project.toprakSahibiYuzdesi.toStringAsFixed(1)}%)',
            font,
            fontBold,
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String title, String value, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(fontSize: 8, font: font),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            font: fontBold,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  pw.Widget _buildCatiRoof(pw.Font font) {
    return pw.Container(
      width: double.infinity,
      height: 30,
      child: pw.CustomPaint(
        painter: (PdfGraphics canvas, PdfPoint size) {
          _drawSimpleRoof(canvas, size);
        },
      ),
    );
  }

  void _drawSimpleRoof(PdfGraphics canvas, PdfPoint size) {
    // Gerçekçi kiremit çatı görünümü - bina genişliği ile tam uyumlu
    
    // Çatıyı daha geniş yaparak bina ile aynı hizaya getir
    final roofWidth = size.x * 1.2;  // %20 daha geniş
    final roofOffsetX = (size.x - roofWidth) / 2;  // Ortalama için offset
    
    // 1. Ana çatı dolgusu (kiremit rengi - turuncu-kırmızı)
    canvas
      ..setColor(PdfColor.fromHex('#B85450'))
      ..moveTo(roofOffsetX, size.y * 0.2)                    // Sol alt
      ..lineTo(size.x * 0.5, size.y * 0.8)                  // Üst nokta - orta
      ..lineTo(roofOffsetX + roofWidth, size.y * 0.2)       // Sağ alt
      ..closePath()
      ..fillPath();

    // 2. Kiremit çizgileri - yatay satırlar
    canvas
      ..setColor(PdfColor.fromHex('#8B4513'))
      ..setLineWidth(0.5);
    
    // Sol yarım çatı üzerinde yatay kiremit çizgileri
    for (int i = 0; i < 8; i++) {
      final y = size.y * (0.2 + i * 0.07);
      final leftX = roofOffsetX + (i * (roofWidth * 0.06));
      final centerX = size.x * 0.5;
      
      canvas
        ..moveTo(leftX, y)
        ..lineTo(centerX, y)
        ..strokePath();
    }
    
    // Sağ yarım çatı üzerinde yatay kiremit çizgileri
    for (int i = 0; i < 8; i++) {
      final y = size.y * (0.2 + i * 0.07);
      final rightX = (roofOffsetX + roofWidth) - (i * (roofWidth * 0.06));
      final centerX = size.x * 0.5;
      
      canvas
        ..moveTo(centerX, y)
        ..lineTo(rightX, y)
        ..strokePath();
    }

    // 3. Dikey kiremit çizgileri - sol yarım
    canvas.setLineWidth(0.3);
    for (int i = 0; i < 10; i++) {
      final x = roofOffsetX + (roofWidth * 0.08) + (i * (roofWidth * 0.04));
      final topY = size.y * (0.25 + i * 0.055);
      final bottomY = size.y * 0.2;
      
      if (x < size.x * 0.5) {  // Sadece sol yarıda
        canvas
          ..moveTo(x, topY)
          ..lineTo(x, bottomY)
          ..strokePath();
      }
    }
    
    // 4. Dikey kiremit çizgileri - sağ yarım
    for (int i = 0; i < 10; i++) {
      final x = (roofOffsetX + roofWidth) - (roofWidth * 0.08) - (i * (roofWidth * 0.04));
      final topY = size.y * (0.25 + i * 0.055);
      final bottomY = size.y * 0.2;
      
      if (x > size.x * 0.5) {  // Sadece sağ yarıda
        canvas
          ..moveTo(x, topY)
          ..lineTo(x, bottomY)
          ..strokePath();
      }
    }

    // 5. Çatı kenar çizgileri (koyu kahverengi)
    canvas
      ..setColor(PdfColor.fromHex('#654321'))
      ..setLineWidth(1.5)
      ..moveTo(roofOffsetX, size.y * 0.2)                    // Sol kenar
      ..lineTo(size.x * 0.5, size.y * 0.8)                  // Tepe
      ..lineTo(roofOffsetX + roofWidth, size.y * 0.2)       // Sağ kenar
      ..strokePath();

    // 6. Mahya (çatı tepesi) vurgusu
    canvas
      ..setColor(PdfColor.fromHex('#8B4513'))
      ..setLineWidth(2.0)
      ..moveTo(size.x * 0.47, size.y * 0.78)
      ..lineTo(size.x * 0.53, size.y * 0.78)
      ..strokePath();

    // 7. Çatı tabanı (saçak) - çatının tam genişliği
    canvas
      ..setColor(PdfColors.grey700)
      ..setLineWidth(2.5)
      ..moveTo(roofOffsetX - (roofWidth * 0.02), size.y * 0.18)
      ..lineTo(roofOffsetX + roofWidth + (roofWidth * 0.02), size.y * 0.18)
      ..strokePath();
      
    // 8. Saçak gölgesi
    canvas
      ..setColor(PdfColors.grey500)
      ..setLineWidth(1.0)
      ..moveTo(roofOffsetX - (roofWidth * 0.02), size.y * 0.15)
      ..lineTo(roofOffsetX + roofWidth + (roofWidth * 0.02), size.y * 0.15)
      ..strokePath();
  }

  pw.Widget _buildScaledFloorCard(floor, int totalFloors, pw.Font font, pw.Font fontBold) {
    // Kat sayısına göre ölçeklendirme faktörü hesapla
    final fontSize = _calculateFontSize(totalFloors);
    final unitSize = _calculateUnitSize(totalFloors);
    final padding = _calculatePadding(totalFloors);
    
    return pw.Container(
      margin: pw.EdgeInsets.only(bottom: padding / 2),
      padding: pw.EdgeInsets.all(padding),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                floor.ad,
                style: pw.TextStyle(
                  fontSize: fontSize.title,
                  fontWeight: pw.FontWeight.bold,
                  font: fontBold,
                ),
              ),
              pw.Container(
                padding: pw.EdgeInsets.symmetric(horizontal: padding, vertical: padding / 4),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  NumberFormatter.formatArea(floor.toplamAlan),
                  style: pw.TextStyle(fontSize: fontSize.area, font: font),
                ),
              ),
            ],
          ),
          if (floor.aciklama != null && floor.aciklama!.isNotEmpty) ...[
            pw.SizedBox(height: padding / 4),
            pw.Text(
              floor.aciklama!,
              style: pw.TextStyle(fontSize: fontSize.description, color: PdfColors.grey, font: font),
            ),
          ],
          pw.SizedBox(height: padding / 2),
          if (floor.daireler.isEmpty)
            pw.Text(
              'Bu kata henüz daire eklenmemiş',
              style: pw.TextStyle(fontSize: fontSize.description, color: PdfColors.grey, font: font),
            )
          else
            pw.Expanded(
              child: pw.Wrap(
                spacing: padding / 2,
                runSpacing: padding / 2,
                children: floor.daireler.map<pw.Widget>((unit) {
                  return _buildScaledUnitBox(unit, unitSize, fontSize, font, fontBold);
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }


  ({double title, double area, double description, double unit}) _calculateFontSize(int floorCount) {
    if (floorCount <= 2) return (title: 12.0, area: 10.0, description: 8.0, unit: 7.0);
    if (floorCount <= 4) return (title: 10.0, area: 8.0, description: 7.0, unit: 6.0);
    if (floorCount <= 6) return (title: 9.0, area: 7.0, description: 6.0, unit: 5.0);
    if (floorCount <= 8) return (title: 8.0, area: 6.0, description: 5.0, unit: 4.5);
    return (title: 7.0, area: 5.5, description: 4.5, unit: 4.0);
  }

  double _calculateUnitSize(int floorCount) {
    if (floorCount <= 2) return 100.0;
    if (floorCount <= 4) return 80.0;
    if (floorCount <= 6) return 70.0;
    if (floorCount <= 8) return 60.0;
    return 50.0;
  }

  double _calculatePadding(int floorCount) {
    if (floorCount <= 2) return 8.0;
    if (floorCount <= 4) return 6.0;
    if (floorCount <= 6) return 4.0;
    if (floorCount <= 8) return 3.0;
    return 2.0;
  }

  pw.Widget _buildScaledUnitBox(UnitModel unit, double unitSize, ({double title, double area, double description, double unit}) fontSize, pw.Font font, pw.Font fontBold) {
    final isMuteahhit = unit.malik == Malik.muteahhit;
    
    return pw.Container(
      width: unitSize,
      padding: pw.EdgeInsets.all(unitSize * 0.06), // Dinamik padding
      decoration: pw.BoxDecoration(
        color: isMuteahhit ? PdfColors.pink50 : PdfColors.white,
        border: pw.Border.all(
          color: isMuteahhit ? PdfColors.pink300 : PdfColors.grey400,
          width: 1,
        ),
        borderRadius: pw.BorderRadius.circular(2),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Expanded(
                child: pw.Text(
                  unit.ad,
                  style: pw.TextStyle(
                    fontSize: fontSize.unit,
                    fontWeight: pw.FontWeight.bold,
                    font: fontBold,
                  ),
                  overflow: pw.TextOverflow.clip,
                ),
              ),
              pw.Container(
                padding: pw.EdgeInsets.symmetric(
                  horizontal: unitSize * 0.03, 
                  vertical: unitSize * 0.01
                ),
                decoration: pw.BoxDecoration(
                  color: isMuteahhit ? PdfColors.pink300 : PdfColors.grey,
                  borderRadius: pw.BorderRadius.circular(4),
                ),
                child: pw.Text(
                  isMuteahhit ? 'M' : 'TS',
                  style: pw.TextStyle(
                    fontSize: fontSize.unit * 0.8,
                    color: PdfColors.white,
                    font: fontBold,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: unitSize * 0.04),
          if (unit.eskiBrut != null)
            pw.Text(
              'Eski: ${NumberFormatter.formatNumber(unit.eskiBrut)} m²',
              style: pw.TextStyle(fontSize: fontSize.unit * 0.9, font: font),
              overflow: pw.TextOverflow.clip,
            ),
          if (unit.yeniBrut != null)
            pw.Text(
              'Yeni: ${NumberFormatter.formatNumber(unit.yeniBrut)} m²',
              style: pw.TextStyle(
                fontSize: fontSize.unit * 0.9,
                fontWeight: pw.FontWeight.bold,
                font: fontBold,
              ),
              overflow: pw.TextOverflow.clip,
            ),
          if (unit.eskiBrut == null && unit.yeniBrut == null)
            pw.Text(
              'Alan belirtilmemiş',
              style: pw.TextStyle(fontSize: fontSize.unit * 0.8, color: PdfColors.grey, font: font),
              overflow: pw.TextOverflow.clip,
            ),
        ],
      ),
    );
  }


  pw.Widget _buildOtoparkSection(pw.Font font, pw.Font fontBold) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: PdfColors.grey300,
        border: pw.Border.all(color: PdfColors.grey400),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Center(
        child: pw.Text(
          'OTOPARK',
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
            color: PdfColors.grey700,
            font: fontBold,
          ),
        ),
      ),
    );
  }

  pw.Widget _buildRightPanel(ProjectModel project, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildDetailedTable(project, font, fontBold),
        pw.SizedBox(height: 16),
        _buildImportantNotes(font, fontBold),
        pw.Spacer(),
        _buildLegend(project, font, fontBold),
      ],
    );
  }

  pw.Widget _buildDetailedTable(ProjectModel project, pw.Font font, pw.Font fontBold) {
    return pw.Container(
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
      ),
      child: pw.Column(
        children: [
          // Header
          pw.Container(
            padding: const pw.EdgeInsets.all(4),
            decoration: const pw.BoxDecoration(color: PdfColors.grey200),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'KAT ADI',
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: fontBold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'DAİRE',
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: fontBold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'ESKİ BRT',
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: fontBold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'YENİ BRT',
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: fontBold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    'ALAN M²',
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: fontBold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
          // Rows
          ...project.katlar.expand((kat) {
            return kat.daireler.map((unit) {
              return pw.Container(
                padding: const pw.EdgeInsets.all(3),
                decoration: pw.BoxDecoration(
                  border: pw.Border(bottom: pw.BorderSide(color: PdfColors.grey300)),
                  color: unit.malik == Malik.muteahhit 
                      ? PdfColors.pink50 
                      : PdfColors.white,
                ),
                child: pw.Row(
                  children: [
                    pw.Expanded(
                      flex: 2,
                      child: pw.Text(
                        kat.ad,
                        style: pw.TextStyle(fontSize: 7, font: font),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        unit.ad,
                        style: pw.TextStyle(fontSize: 7, font: font),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        unit.eskiBrut?.toString() ?? '—',
                        style: pw.TextStyle(fontSize: 7, font: font),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        unit.yeniBrut?.toString() ?? '—',
                        style: pw.TextStyle(fontSize: 7, font: font),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        NumberFormatter.formatNumber(kat.toplamAlan),
                        style: pw.TextStyle(fontSize: 7, font: font),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                  ],
                ),
              );
            });
          }),
          // Total
          pw.Container(
            padding: const pw.EdgeInsets.all(4),
            decoration: const pw.BoxDecoration(color: PdfColors.grey100),
            child: pw.Row(
              children: [
                pw.Expanded(
                  flex: 2,
                  child: pw.Text(
                    'TOPLAM M²',
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: fontBold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(''),
                ),
                pw.Expanded(
                  child: pw.Text(''),
                ),
                pw.Expanded(
                  child: pw.Text(''),
                ),
                pw.Expanded(
                  child: pw.Text(
                    NumberFormatter.formatNumber(project.toplamInsaatAlani),
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: fontBold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildImportantNotes(pw.Font font, pw.Font fontBold) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey400),
        color: PdfColors.grey50,
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ÖNEMLİ NOT',
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold, font: fontBold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            '- Proje imar durumu, kat kesit ve istikrar',
            style: pw.TextStyle(fontSize: 8, font: font),
          ),
          pw.Text(
            'planı belgeleri ile teyit kazanacaktır.',
            style: pw.TextStyle(fontSize: 8, font: font),
          ),
          pw.Text(
            '- Proje imar planı üzerinden hesaplanarak',
            style: pw.TextStyle(fontSize: 8, font: font),
          ),
          pw.Text(
            'çizilmiştir.',
            style: pw.TextStyle(fontSize: 8, font: font),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLegend(ProjectModel project, pw.Font font, pw.Font fontBold) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 15,
              height: 10,
              color: PdfColors.grey300,
            ),
            pw.SizedBox(width: 5),
            pw.Text(
              'TOPRAK SAHİBİ',
              style: pw.TextStyle(fontSize: 8, font: font),
            ),
          ],
        ),
        pw.SizedBox(height: 4),
        pw.Row(
          children: [
            pw.Container(
              width: 15,
              height: 10,
              color: PdfColors.pink200,
            ),
            pw.SizedBox(width: 5),
            pw.Text(
              'MÜTEAHHİT',
              style: pw.TextStyle(fontSize: 8, font: font),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          'MÜTEAHHİT ${project.muteahhitYuzdesi.toStringAsFixed(1)}% - MAL SAHİBİ ${project.toprakSahibiYuzdesi.toStringAsFixed(1)}%',
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold, font: fontBold),
        ),
      ],
    );
  }

  pw.Widget _buildFooterInfo(ProjectModel project, pw.Font font, pw.Font fontBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              'Proje',
              style: pw.TextStyle(fontSize: 8, font: font),
            ),
            pw.Text(
              'M.Sahibi',
              style: pw.TextStyle(fontSize: 8, font: font),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              project.adres.isNotEmpty ? project.adres : 'Adres belirtilmemiş',
              style: pw.TextStyle(fontSize: 8, font: font),
            ),
            pw.Text(
              project.malSahibi.isNotEmpty ? project.malSahibi : 'Mal sahibi belirtilmemiş',
              style: pw.TextStyle(fontSize: 8, font: font),
            ),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCompanyFooter(pw.Font font, pw.Font fontBold) {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Row(
          children: [
            pw.Container(
              width: 20,
              height: 15,
              decoration: pw.BoxDecoration(
                border: pw.Border.all(color: PdfColors.black),
              ),
              child: pw.Center(
                child: pw.Text(
                  'IMBO',
                  style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold, font: fontBold),
                ),
              ),
            ),
            pw.SizedBox(width: 5),
            pw.Text(
              'mimarilik',
              style: pw.TextStyle(fontSize: 10, font: font),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              'ŞEMATIK KESIT',
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold, font: fontBold),
            ),
            pw.Text(
              'A01',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold, font: fontBold),
            ),
          ],
        ),
      ],
    );
  }
}