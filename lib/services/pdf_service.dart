import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import '../data/models/project.dart';
import '../data/models/unit.dart';
import '../core/formatters.dart';

class PdfService {
  Future<void> generateAndDownloadPDF(ProjectModel project) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.landscape,
        margin: const pw.EdgeInsets.all(24),
        build: (pw.Context context) {
          return _buildPdfContent(project);
        },
      ),
    );

    final filename = ProjectFilenameGenerator.generate(project.projeAdi);
    
    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
      name: filename,
    );
  }

  pw.Widget _buildPdfContent(ProjectModel project) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildHeader(project),
        pw.SizedBox(height: 16),
        pw.Expanded(
          child: pw.Row(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              // Sol taraf - Canvas
              pw.Expanded(
                flex: 7,
                child: _buildCanvas(project),
              ),
              pw.SizedBox(width: 16),
              // Sağ taraf - Detaylı tablo ve bilgiler
              pw.Expanded(
                flex: 3,
                child: _buildRightPanel(project),
              ),
            ],
          ),
        ),
        pw.SizedBox(height: 16),
        _buildFooterInfo(),
        pw.SizedBox(height: 12),
        _buildCompanyFooter(),
      ],
    );
  }

  pw.Widget _buildHeader(ProjectModel project) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          TextUtils.toAscii(project.projeAdi.isEmpty ? 'Baslıksız Proje' : project.projeAdi),
          style: pw.TextStyle(
            fontSize: 18,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        if (project.adres.isNotEmpty) ...[
          pw.SizedBox(height: 4),
          pw.Text(
            TextUtils.toAscii(project.adres),
            style: const pw.TextStyle(fontSize: 10),
          ),
        ],
      ],
    );
  }

  pw.Widget _buildCanvas(ProjectModel project) {
    final visibleKatlar = project.katlar;

    return pw.Column(
      children: [
        _buildSummaryStrip(project),
        pw.SizedBox(height: 16),
        if (project.showCati) _buildCatiRoof(),
        if (visibleKatlar.isEmpty)
          pw.Expanded(
            child: pw.Center(
              child: pw.Text(
                'Proje için henüz kat eklenmemiş',
                style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
              ),
            ),
          )
        else
          pw.Expanded(
            child: pw.Column(
              children: visibleKatlar.map((kat) => _buildFloorCard(kat)).toList(),
            ),
          ),
        if (project.showOtopark) _buildOtoparkSection(),
      ],
    );
  }

  pw.Widget _buildSummaryStrip(ProjectModel project) {
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
          ),
          _buildSummaryItem(
            'Müteahhit Toplam Yeni Brüt',
            NumberFormatter.formatArea(project.muteahhitToplamYeniBrut),
          ),
          _buildSummaryItem(
            'Toprak Sahibi Toplam Yeni Brüt',
            NumberFormatter.formatArea(project.toprakSahibiToplamYeniBrut),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildSummaryItem(String title, String value) {
    return pw.Column(
      children: [
        pw.Text(
          title,
          style: const pw.TextStyle(fontSize: 8),
          textAlign: pw.TextAlign.center,
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          value,
          style: pw.TextStyle(
            fontSize: 10,
            fontWeight: pw.FontWeight.bold,
          ),
          textAlign: pw.TextAlign.center,
        ),
      ],
    );
  }

  pw.Widget _buildCatiRoof() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      child: pw.CustomPaint(
        size: const PdfPoint(120, 30),
        painter: (PdfGraphics canvas, PdfPoint size) {
          canvas
            ..setColor(PdfColors.red300)
            ..moveTo(size.x * 0.1, size.y * 0.8)
            ..lineTo(size.x * 0.5, size.y * 0.1)
            ..lineTo(size.x * 0.9, size.y * 0.8)
            ..lineTo(size.x * 0.85, size.y)
            ..lineTo(size.x * 0.15, size.y)
            ..closePath()
            ..fillPath();
          
          canvas
            ..setColor(PdfColors.red200)
            ..moveTo(size.x * 0.15, size.y)
            ..lineTo(size.x * 0.5, size.y * 0.2)
            ..lineTo(size.x * 0.85, size.y)
            ..closePath()
            ..fillPath();
        },
      ),
    );
  }

  pw.Widget _buildFloorCard(floor) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 8),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.grey300),
        borderRadius: pw.BorderRadius.circular(4),
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
                  fontSize: 12,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: pw.BoxDecoration(
                  color: PdfColors.blue100,
                  borderRadius: pw.BorderRadius.circular(10),
                ),
                child: pw.Text(
                  NumberFormatter.formatArea(floor.alan),
                  style: const pw.TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          if (floor.aciklama != null && floor.aciklama!.isNotEmpty) ...[
            pw.SizedBox(height: 4),
            pw.Text(
              floor.aciklama!,
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            ),
          ],
          pw.SizedBox(height: 8),
          if (floor.daireler.isEmpty)
            pw.Text(
              'Bu kata henüz daire eklenmemiş',
              style: const pw.TextStyle(fontSize: 8, color: PdfColors.grey),
            )
          else
            pw.Wrap(
              spacing: 8,
              runSpacing: 8,
              children: floor.daireler.map<pw.Widget>((unit) {
                return _buildUnitBox(unit);
              }).toList(),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildUnitBox(UnitModel unit) {
    final isMuteahhit = unit.malik == Malik.muteahhit;
    
    return pw.Container(
      width: 100,
      padding: const pw.EdgeInsets.all(6),
      decoration: pw.BoxDecoration(
        color: isMuteahhit ? PdfColors.pink50 : PdfColors.white,
        border: pw.Border.all(
          color: isMuteahhit ? PdfColors.pink300 : PdfColors.grey400,
          width: 1,
        ),
        borderRadius: pw.BorderRadius.circular(4),
      ),
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Text(
                unit.ad,
                style: pw.TextStyle(
                  fontSize: 8,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 3, vertical: 1),
                decoration: pw.BoxDecoration(
                  color: isMuteahhit ? PdfColors.pink300 : PdfColors.grey,
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  isMuteahhit ? 'M' : 'TS',
                  style: const pw.TextStyle(
                    fontSize: 6,
                    color: PdfColors.white,
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 4),
          if (unit.eskiBrut != null)
            pw.Text(
              'Eski: ${NumberFormatter.formatNumber(unit.eskiBrut)} m²',
              style: const pw.TextStyle(fontSize: 7),
            ),
          if (unit.yeniBrut != null)
            pw.Text(
              'Yeni: ${NumberFormatter.formatNumber(unit.yeniBrut)} m²',
              style: pw.TextStyle(
                fontSize: 7,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          if (unit.eskiBrut == null && unit.yeniBrut == null)
            pw.Text(
              'Alan belirtilmemiş',
              style: const pw.TextStyle(fontSize: 6, color: PdfColors.grey),
            ),
        ],
      ),
    );
  }

  pw.Widget _buildOtoparkSection() {
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
          ),
        ),
      ),
    );
  }

  pw.Widget _buildRightPanel(ProjectModel project) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        _buildDetailedTable(project),
        pw.SizedBox(height: 16),
        _buildImportantNotes(),
        pw.Spacer(),
        _buildLegend(),
      ],
    );
  }

  pw.Widget _buildDetailedTable(ProjectModel project) {
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
                    TextUtils.toAscii('KAT ADI'),
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    TextUtils.toAscii('DAIRE'),
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    TextUtils.toAscii('ESK BRT'),
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    TextUtils.toAscii('YNI BRT'),
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
                    textAlign: pw.TextAlign.center,
                  ),
                ),
                pw.Expanded(
                  child: pw.Text(
                    TextUtils.toAscii('ALAN M2'),
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
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
                        TextUtils.toAscii(kat.ad),
                        style: const pw.TextStyle(fontSize: 7),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        TextUtils.toAscii(unit.ad),
                        style: const pw.TextStyle(fontSize: 7),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        unit.eskiBrut?.toString() ?? TextUtils.toAscii('—'),
                        style: const pw.TextStyle(fontSize: 7),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        unit.yeniBrut?.toString() ?? TextUtils.toAscii('—'),
                        style: const pw.TextStyle(fontSize: 7),
                        textAlign: pw.TextAlign.center,
                      ),
                    ),
                    pw.Expanded(
                      child: pw.Text(
                        NumberFormatter.formatNumber(kat.alan),
                        style: const pw.TextStyle(fontSize: 7),
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
                    TextUtils.toAscii('TOPLAM M2'),
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
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
                    style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
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

  pw.Widget _buildImportantNotes() {
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
            TextUtils.toAscii('ONEMLI NOT'),
            style: pw.TextStyle(fontSize: 10, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 4),
          pw.Text(
            TextUtils.toAscii('- Proje imar durumu, kat kesit ve istikrnet'),
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            TextUtils.toAscii('plani belgeleri ile testmik kazanacaktir.'),
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            TextUtils.toAscii('- Proje imar plani uzerinden hesaplanarak'),
            style: const pw.TextStyle(fontSize: 8),
          ),
          pw.Text(
            TextUtils.toAscii('cizilmistir.'),
            style: const pw.TextStyle(fontSize: 8),
          ),
        ],
      ),
    );
  }

  pw.Widget _buildLegend() {
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
              TextUtils.toAscii('TOPRAK S.'),
              style: const pw.TextStyle(fontSize: 8),
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
              TextUtils.toAscii('MUTEAHHIT'),
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
        pw.SizedBox(height: 8),
        pw.Text(
          TextUtils.toAscii('MUTEAHHIT 53.9 - MAL SAHIBI 56.1'),
          style: pw.TextStyle(fontSize: 8, fontWeight: pw.FontWeight.bold),
        ),
      ],
    );
  }

  pw.Widget _buildFooterInfo() {
    return pw.Row(
      mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
      children: [
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              TextUtils.toAscii('Proje'),
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              TextUtils.toAscii('M.Sahibi'),
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              TextUtils.toAscii('Cizen'),
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              TextUtils.toAscii(project.adres.isNotEmpty ? project.adres : 'Adres belirtilmemiş'),
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              TextUtils.toAscii(project.malSahibi.isNotEmpty ? project.malSahibi : 'Mal sahibi belirtilmemiş'),
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              TextUtils.toAscii(project.cizen.isNotEmpty ? project.cizen : 'Çizen belirtilmemiş'),
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              TextUtils.toAscii('Cizek'),
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              TextUtils.toAscii('Tarih'),
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text(
              TextUtils.toAscii('Rev'),
              style: const pw.TextStyle(fontSize: 8),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text('', style: const pw.TextStyle(fontSize: 8)),
            pw.Text(
              '${DateTime.now().day.toString().padLeft(2, '0')}.${DateTime.now().month.toString().padLeft(2, '0')}.${DateTime.now().year}',
              style: const pw.TextStyle(fontSize: 8),
            ),
            pw.Text('', style: const pw.TextStyle(fontSize: 8)),
          ],
        ),
      ],
    );
  }

  pw.Widget _buildCompanyFooter() {
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
                  TextUtils.toAscii('IMBO'),
                  style: pw.TextStyle(fontSize: 6, fontWeight: pw.FontWeight.bold),
                ),
              ),
            ),
            pw.SizedBox(width: 5),
            pw.Text(
              TextUtils.toAscii('mimarilik'),
              style: const pw.TextStyle(fontSize: 10),
            ),
          ],
        ),
        pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.end,
          children: [
            pw.Text(
              TextUtils.toAscii('SEMATIK KESIT'),
              style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
            ),
            pw.Text(
              'A01',
              style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
            ),
          ],
        ),
      ],
    );
  }
}