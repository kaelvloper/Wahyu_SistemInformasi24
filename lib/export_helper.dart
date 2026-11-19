import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:share_plus/share_plus.dart';

class ExportHelper {
  // Fungsi untuk Export & Cetak PDF
  static Future<void> exportPdf(List<dynamic> listBarang) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text(
                "Laporan Inventaris Laboratorium",
                style: pw.TextStyle(fontSize: 22, fontWeight: pw.FontWeight.bold),
              ),
              pw.SizedBox(height: 15),
              pw.TableHelper.fromTextArray(
                headers: ['Kode', 'Nama Barang', 'Kategori', 'Stok'],
                data: listBarang.map((b) => [
                  b.kode.toString(),
                  b.nama.toString(),
                  (b.kategori ?? '-').toString(),
                  b.stok.toString(),
                ]).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => pdf.save(),
    );
  }

  // Fungsi untuk Share Teks
  static void shareData(List<dynamic> listBarang) {
    if (listBarang.isEmpty) return;
    String text = "--- LAPORAN INVENTARIS LAB ---\n";
    for (var b in listBarang) {
      text += "• [${b.kode}] ${b.nama} (${b.kategori}) - Stok: ${b.stok}\n";
    }
    Share.share(text);
  }
}
