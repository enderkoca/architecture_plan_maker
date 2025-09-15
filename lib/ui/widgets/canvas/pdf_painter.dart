import 'package:pdf/widgets.dart' as pw;
import '../../../data/models/project.dart';
import '../../../data/models/unit.dart';
import '../../../core/formatters.dart';

class PdfPainter {
  static pw.Widget buildProjectCanvas(ProjectModel project) {
    final visibleKatlar = project.katlar.where((kat) {
      if (kat.ad.toLowerCase().contains('çatı')) {
        return project.showCati;
      }
      return true;
    }).toList();

    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.stretch,
      children: [
        if (project.showCati) _buildCatiSection(),
        if (visibleKatlar.isEmpty)
          _buildEmptyState()
        else
          ...visibleKatlar.map((kat) => _buildFloorSection(kat)),
        if (project.showOtopark) _buildOtoparkSection(),
      ],
    );
  }

  static pw.Widget _buildCatiSection() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      height: 30,
      child: pw.CustomPaint(
        painter: (canvas, size) {
          // Çatı üçgeni çizimi
          canvas
            ..setFillColor(const pw.PdfColor(1.0, 0.6, 0.0)) // Turuncu
            ..moveTo(size.x * 0.3, size.y)
            ..lineTo(size.x * 0.5, 0)
            ..lineTo(size.x * 0.7, size.y)
            ..closePath()
            ..fillPath();
        },
      ),
    );
  }

  static pw.Widget _buildFloorSection(floor) {
    return pw.Container(
      margin: const pw.EdgeInsets.only(bottom: 12),
      padding: const pw.EdgeInsets.all(16),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: const pw.PdfColor(0.8, 0.8, 0.8)),
        borderRadius: pw.BorderRadius.circular(8),
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
                  fontSize: 14,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: pw.BoxDecoration(
                  color: const pw.PdfColor(0.9, 0.9, 1.0),
                  borderRadius: pw.BorderRadius.circular(12),
                ),
                child: pw.Text(
                  NumberFormatter.formatArea(floor.alan),
                  style: pw.TextStyle(
                    fontSize: 10,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          if (floor.aciklama != null && floor.aciklama!.isNotEmpty) ...[
            pw.SizedBox(height: 6),
            pw.Text(
              floor.aciklama!,
              style: const pw.TextStyle(
                fontSize: 9,
                color: pw.PdfColor(0.5, 0.5, 0.5),
              ),
            ),
          ],
          pw.SizedBox(height: 12),
          if (floor.daireler.isEmpty)
            pw.Container(
              padding: const pw.EdgeInsets.all(16),
              child: pw.Center(
                child: pw.Text(
                  'Bu kata henüz daire eklenmemiş',
                  style: const pw.TextStyle(
                    fontSize: 10,
                    color: pw.PdfColor(0.6, 0.6, 0.6),
                  ),
                ),
              ),
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

  static pw.Widget _buildUnitBox(UnitModel unit) {
    final isMuteahhit = unit.malik == Malik.muteahhit;
    
    return pw.Container(
      width: 120,
      padding: const pw.EdgeInsets.all(8),
      decoration: pw.BoxDecoration(
        color: isMuteahhit 
          ? const pw.PdfColor(0.99, 0.91, 0.95) // Açık pembe
          : const pw.PdfColor(1.0, 1.0, 1.0),   // Beyaz
        border: pw.Border.all(
          color: isMuteahhit
            ? const pw.PdfColor(0.98, 0.66, 0.83) // Pembe kenar
            : const pw.PdfColor(0.5, 0.5, 0.5),   // Gri kenar
          width: 1.5,
        ),
        borderRadius: pw.BorderRadius.circular(6),
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
                  fontSize: 10,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.Container(
                padding: const pw.EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: pw.BoxDecoration(
                  color: isMuteahhit
                    ? const pw.PdfColor(0.98, 0.66, 0.83)
                    : const pw.PdfColor(0.5, 0.5, 0.5),
                  borderRadius: pw.BorderRadius.circular(8),
                ),
                child: pw.Text(
                  isMuteahhit ? 'M' : 'TS',
                  style: const pw.TextStyle(
                    fontSize: 7,
                    color: pw.PdfColor(1.0, 1.0, 1.0),
                  ),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 6),
          if (unit.eskiBrut != null)
            pw.Text(
              'Eski: ${NumberFormatter.formatNumber(unit.eskiBrut)} m²',
              style: const pw.TextStyle(fontSize: 8),
            ),
          if (unit.yeniBrut != null)
            pw.Text(
              'Yeni: ${NumberFormatter.formatNumber(unit.yeniBrut)} m²',
              style: pw.TextStyle(
                fontSize: 8,
                fontWeight: pw.FontWeight.bold,
              ),
            ),
          if (unit.eskiBrut == null && unit.yeniBrut == null)
            pw.Text(
              'Alan belirtilmemiş',
              style: const pw.TextStyle(
                fontSize: 7,
                color: pw.PdfColor(0.6, 0.6, 0.6),
              ),
            ),
        ],
      ),
    );
  }

  static pw.Widget _buildOtoparkSection() {
    return pw.Container(
      margin: const pw.EdgeInsets.only(top: 8),
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        color: const pw.PdfColor(0.9, 0.9, 0.9),
        border: pw.Border.all(color: const pw.PdfColor(0.7, 0.7, 0.7)),
        borderRadius: pw.BorderRadius.circular(6),
      ),
      child: pw.Center(
        child: pw.Text(
          'OTOPARK',
          style: pw.TextStyle(
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
            color: const pw.PdfColor(0.4, 0.4, 0.4),
          ),
        ),
      ),
    );
  }

  static pw.Widget _buildEmptyState() {
    return pw.Container(
      padding: const pw.EdgeInsets.all(32),
      child: pw.Center(
        child: pw.Column(
          children: [
            pw.Text(
              'Proje Önizlemesi',
              style: pw.TextStyle(
                fontSize: 16,
                fontWeight: pw.FontWeight.bold,
                color: const pw.PdfColor(0.6, 0.6, 0.6),
              ),
            ),
            pw.SizedBox(height: 8),
            pw.Text(
              'Katlar ve daireler eklendikçe burada görünecek',
              style: const pw.TextStyle(
                fontSize: 10,
                color: pw.PdfColor(0.6, 0.6, 0.6),
              ),
              textAlign: pw.TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}