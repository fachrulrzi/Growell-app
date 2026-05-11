import 'package:flutter/material.dart';
import 'data/consultation_store.dart';
import 'consultation_detail_page.dart';

class ConsultationHistoryPage extends StatelessWidget {
  const ConsultationHistoryPage({super.key});

  String _formatDate(DateTime d) {
    final dd = d.day.toString().padLeft(2, '0');
    final mm = d.month.toString().padLeft(2, '0');
    final yy = d.year.toString();
    return '$dd/$mm/$yy';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Konsultasi Dokter'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ValueListenableBuilder<List<ConsultationEntry>>(
        valueListenable: ConsultationStore.consultationsNotifier,
        builder: (_, consultations, __) {
          if (consultations.isEmpty) {
            return const Center(child: Text('Belum ada riwayat konsultasi'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: consultations.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (ctx, i) {
              final c = consultations[i];
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(
                          color: Colors.blue.shade50,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Center(
                          child: Text(
                            c.doctorName
                                .split(' ')
                                .map((e) => e.isNotEmpty ? e[0] : '')
                                .take(2)
                                .join(),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              c.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              c.doctorName +
                                  (c.doctorSpecialty != null
                                      ? ' • ${c.doctorSpecialty}'
                                      : ''),
                              style: const TextStyle(fontSize: 13),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _formatDate(c.date),
                              style: const TextStyle(
                                color: Colors.black54,
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              c.description,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton(
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => ConsultationDetailPage(entry: c),
                            ),
                          );
                        },
                        icon: const Icon(Icons.info_outline),
                      ),
                      // print action moved to detail page to avoid double-step
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
