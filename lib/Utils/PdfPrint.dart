import 'dart:convert';
import 'dart:html';
import 'dart:ui';

import 'package:syncfusion_flutter_pdf/pdf.dart';

Future<void> createPDF(String text) async {
  //Create a PDF document.
  PdfDocument document = PdfDocument();
  //Add a page and draw text
  document.pages.add().graphics.drawString(
      text, PdfStandardFont(PdfFontFamily.helvetica, 20),
      brush: PdfSolidBrush(PdfColor(0, 0, 0)),
      // bounds: Rect.fromLTWH(20, 60, 150, 30)
  );
  //Save the document
  List<int> bytes = await document.save();
  //Dispose the document
  document.dispose();
  AnchorElement(
      href:
      "data:application/octet-stream;charset=utf-16le;base64,${base64.encode(bytes)}")
    ..setAttribute("download", "Download.pdf")
    ..click();
}
