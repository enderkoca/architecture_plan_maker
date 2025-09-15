import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

class NumberFormatter {
  static final _numberFormat = NumberFormat('#,##0.##', 'tr_TR');

  static String formatNumber(double? value) {
    if (value == null) return '—';
    return _numberFormat.format(value);
  }

  static String formatArea(double? value) {
    if (value == null || value == 0) return '—';
    return '${_numberFormat.format(value)} m²';
  }

  static double? parseNumber(String input) {
    if (input.isEmpty) return null;
    
    final cleanInput = input
        .replaceAll('.', '')
        .replaceAll(',', '.');
    
    return double.tryParse(cleanInput);
  }
}

class DecimalTextInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text;
    
    if (text.isEmpty) {
      return newValue;
    }
    
    final regex = RegExp(r'^[0-9]*[,.]?[0-9]*$');
    if (!regex.hasMatch(text)) {
      return oldValue;
    }
    
    final commaCount = text.split(',').length - 1;
    final dotCount = text.split('.').length - 1;
    
    if (commaCount + dotCount > 1) {
      return oldValue;
    }
    
    return newValue;
  }
}

class ProjectFilenameGenerator {
  static String generate(String projectName) {
    final now = DateTime.now();
    final dateStr = DateFormat('yyyyMMdd').format(now);
    
    final cleanName = projectName
        .replaceAll(RegExp(r'[^\w\s-]'), '')
        .replaceAll(RegExp(r'\s+'), '_')
        .toLowerCase();
    
    return 'teklif_${cleanName.isEmpty ? 'proje' : cleanName}_$dateStr.pdf';
  }
}

class TextUtils {
  static String toAscii(String text) {
    return text
        .replaceAll('ç', 'c')
        .replaceAll('Ç', 'C')
        .replaceAll('ğ', 'g')
        .replaceAll('Ğ', 'G')
        .replaceAll('ı', 'i')
        .replaceAll('İ', 'I')
        .replaceAll('ö', 'o')
        .replaceAll('Ö', 'O')
        .replaceAll('ş', 's')
        .replaceAll('Ş', 'S')
        .replaceAll('ü', 'u')
        .replaceAll('Ü', 'U')
        .replaceAll('—', '-');
  }
}