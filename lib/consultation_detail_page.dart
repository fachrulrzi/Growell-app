import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'data/consultation_store.dart';

class ConsultationDetailPage extends StatelessWidget {
  final ConsultationEntry entry;
  const ConsultationDetailPage({super.key, required this.entry});

  String _formatDateTime(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    final hh = d.hour.toString().padLeft(2, '0');
    final min = d.minute.toString().padLeft(2, '0');
    return '$dd/$mm/$yy • $hh:$min';
  }

  String _buildPrintableText() {
    final buffer = StringBuffer();
    buffer.writeln('Riwayat Konsultasi');
    buffer.writeln('Judul: ${entry.title}');
    buffer.writeln(
      'Dokter: ${entry.doctorName}${entry.doctorSpecialty != null ? ' • ${entry.doctorSpecialty}' : ''}',
    );
    buffer.writeln('Tanggal: ${_formatDateTime(entry.date)}');
    buffer.writeln();
    buffer.writeln('Keterangan:');
    buffer.writeln(entry.description);
    if (entry.diagnosis != null) {
      buffer.writeln();
      buffer.writeln('Diagnosis:');
      buffer.writeln(entry.diagnosis);
    }
    if (entry.prescription != null) {
      buffer.writeln();
      buffer.writeln('Resep & Anjuran:');
      buffer.writeln(entry.prescription);
    }
    if (entry.notes != null) {
      buffer.writeln();
      buffer.writeln('Catatan Penting:');
      buffer.writeln(entry.notes);
    }
    return buffer.toString();
  }

  Future<void> _printPdf(BuildContext context) async {
    try {
      final pdf = pw.Document();

      final content = <pw.Widget>[];
      content.add(pw.Header(level: 0, child: pw.Text('Riwayat Konsultasi')));
      content.add(pw.SizedBox(height: 6));
      content.add(
        pw.Text(
          'Judul: ${entry.title}',
          style: pw.TextStyle(fontSize: 14, fontWeight: pw.FontWeight.bold),
        ),
      );
      content.add(
        pw.Text(
          'Dokter: ${entry.doctorName}${entry.doctorSpecialty != null ? ' • ${entry.doctorSpecialty}' : ''}',
        ),
      );
      content.add(pw.Text('Tanggal: ${_formatDateTime(entry.date)}'));
      content.add(pw.SizedBox(height: 8));
      content.add(
        pw.Text(
          'Keterangan:',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
        ),
      );
      content.add(pw.Text(entry.description));
      if (entry.diagnosis != null) {
        content.add(pw.SizedBox(height: 8));
        content.add(
          pw.Text(
            'Diagnosis:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        );
        content.add(pw.Text(entry.diagnosis!));
      }
      if (entry.prescription != null) {
        content.add(pw.SizedBox(height: 8));
        content.add(
          pw.Text(
            'Resep & Anjuran:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        );
        content.add(pw.Text(entry.prescription!));
      }
      if (entry.notes != null) {
        content.add(pw.SizedBox(height: 8));
        content.add(
          pw.Text(
            'Catatan Penting:',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
          ),
        );
        content.add(pw.Text(entry.notes!));
      }

      pdf.addPage(pw.MultiPage(build: (pw.Context ctx) => content));

      await Printing.layoutPdf(onLayout: (format) async => pdf.save());
    } catch (e, st) {
      // Log for debugging
      // ignore: avoid_print
      print('PDF generation failed: $e');
      // ignore: avoid_print
      print(st);

      final text = _buildPrintableText();
      try {
        await Clipboard.setData(ClipboardData(text: text));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Gagal membuat PDF. Teks disalin ke clipboard. Error: $e',
            ),
          ),
        );
      } catch (e2) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal membuat PDF dan menyalin teks: $e2')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Konsultasi'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          IconButton(
            tooltip: 'Cetak PDF',
            icon: const Icon(Icons.print_outlined),
            onPressed: () async {
              await _printPdf(context);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text(
                      entry.doctorName
                          .split(' ')
                          .map((e) => e.isNotEmpty ? e[0] : '')
                          .take(2)
                          .join(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 18,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        entry.title,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        entry.doctorName +
                            (entry.doctorSpecialty != null
                                ? ' • ${entry.doctorSpecialty}'
                                : ''),
                        style: const TextStyle(fontSize: 13),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _formatDateTime(entry.date),
                        style: const TextStyle(
                          color: Colors.black54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Text(
              'Keterangan',
              style: TextStyle(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(entry.description, style: const TextStyle(fontSize: 14)),
            const SizedBox(height: 16),
            if (entry.diagnosis != null) ...[
              const Text(
                'Diagnosis',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  entry.diagnosis!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (entry.prescription != null) ...[
              const Text(
                'Resep & Anjuran',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  entry.prescription!,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(height: 16),
            ],
            if (entry.notes != null) ...[
              const Text(
                'Catatan Penting',
                style: TextStyle(fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 8),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(entry.notes!, style: const TextStyle(fontSize: 14)),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                icon: const Icon(Icons.print),
                label: const Text('Cetak PDF'),
                onPressed: () async {
                  await _printPdf(context);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
