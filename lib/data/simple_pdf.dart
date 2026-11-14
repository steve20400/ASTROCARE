// Minimal PDF writer in pure Dart: text lines on A4 pages, regular and bold Helvetica.
// It is enough for the health report and needs no plugin and no network.
 
import 'dart:convert';
import 'dart:typed_data';
 
class PdfLine {
  final String text;
  final double size;
  final bool bold;
 
  const PdfLine(this.text, {this.size = 11, this.bold = false});
}
 
class SimplePdf {
  static const double _width = 595;
  static const double _height = 842;
  static const double _margin = 50;
 
  /// Characters outside Latin-1 are replaced, because the built-in fonts cannot show them.
  static String _clean(String s) {
    final b = StringBuffer();
    for (final rune in s.runes) {
      if (rune == 0x2019 || rune == 0x2018) {
        b.write("'");
      } else if (rune == 0x2013 || rune == 0x2014) {
        b.write('-');
      } else if (rune == 0x0153) {
        b.write('oe');
      } else if (rune < 32 || rune > 255) {
        b.write(rune == 9 ? ' ' : '?');
      } else {
        b.writeCharCode(rune);
      }
    }
    return b.toString();
  }
 
  static String _escape(String s) =>
      s.replaceAll('\\', '\\\\').replaceAll('(', '\\(').replaceAll(')', '\\)');
  static List<String> _wrap(String text, double size) {
    final maxChars = ((_width - 2 * _margin) / (size * 0.52)).floor();
    if (text.length <= maxChars) return [text];
    final lines = <String>[];
    var current = '';
    for (final word in text.split(' ')) {
      if (current.isNotEmpty && current.length + 1 + word.length > maxChars) {
        lines.add(current);
        current = word;
      } else {
        current = current.isEmpty ? word : '$current $word';
      }
    }
    if (current.isNotEmpty) lines.add(current);
    return lines;
  }
 
  static Uint8List build(List<PdfLine> lines) {
    // 1. Lay the lines out into page content streams.
    final pages = <String>[];
    var content = StringBuffer();
    var y = _height - _margin;
    for (final line in lines) {
      final leading = line.size * 1.45;
      final parts = line.text.isEmpty ? [''] : _wrap(_clean(line.text), line.size);
      for (final part in parts) {
        if (y - leading < _margin) {
          pages.add(content.toString());
          content = StringBuffer();
          y = _height - _margin;
        }
        y -= leading;
        if (part.isNotEmpty) {
          final font = line.bold ? 'F2' : 'F1';
          content.write('BT /$font ${line.size.toStringAsFixed(1)} Tf ');
          content.write('${_margin.toStringAsFixed(0)} ${y.toStringAsFixed(1)} Td ');
          content.write('(${_escape(part)}) Tj ET\n');
        }

      }
    }
    pages.add(content.toString());
 
    // 2. Write the objects and remember where each one starts.
    final out = BytesBuilder();
    final offsets = <int>[];
    void add(String s) => out.add(latin1.encode(s));
    void object(String body) {
      offsets.add(out.length);
      add('${offsets.length} 0 obj\n$body\nendobj\n');
    }
 
    add('%PDF-1.4\n');
    final kids = [for (var i = 0; i < pages.length; i++) '${5 + i * 2} 0 R'].join(' ');
    object('<< /Type /Catalog /Pages 2 0 R >>');
    object('<< /Type /Pages /Kids [$kids] /Count ${pages.length} >>');
    object('<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica /Encoding /WinAnsiEncoding >>');
    object(
      '<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold /Encoding /WinAnsiEncoding >>',
    );
    for (var i = 0; i < pages.length; i++) {
      object(
        '<< /Type /Page /Parent 2 0 R /MediaBox [0 0 ${_width.toStringAsFixed(0)} '
        '${_height.toStringAsFixed(0)}] /Contents ${6 + i * 2} 0 R '
        '/Resources << /Font << /F1 3 0 R /F2 4 0 R >> >> >>',
      );
      final stream = latin1.encode(pages[i]);
      object('<< /Length ${stream.length} >>\nstream\n${pages[i]}endstream');
    }
 
    // 3. Cross-reference table and trailer.
    final xref = out.length;
    add('xref\n0 ${offsets.length + 1}\n');
    add('0000000000 65535 f \n');
    for (final offset in offsets) {
      add('${offset.toString().padLeft(10, '0')} 00000 n \n');
    }
    add('trailer\n<< /Size ${offsets.length + 1} /Root 1 0 R >>\n');
    add('startxref\n$xref\n%%EOF\n');
    return out.toBytes();
  }
}
