import 'package:flutter/foundation.dart';

class ConsultationEntry {
  final String title;
  final String doctorName;
  final String? doctorSpecialty;
  final DateTime date;
  final String description; // Keterangan
  final String? diagnosis;
  final String? prescription; // Resep & Anjuran
  final String? notes; // Catatan penting

  ConsultationEntry({
    required this.title,
    required this.doctorName,
    this.doctorSpecialty,
    required this.date,
    required this.description,
    this.diagnosis,
    this.prescription,
    this.notes,
  });
}

class ConsultationStore {
  static final ValueNotifier<List<ConsultationEntry>> consultationsNotifier =
      ValueNotifier<List<ConsultationEntry>>([
    ConsultationEntry(
      title: 'Deteksi Dini Stunting',
      doctorName: 'dr. Sarah Wijaya, Sp.A',
      doctorSpecialty: 'Sp.A',
      date: DateTime.now().subtract(const Duration(days: 30)),
      description:
          'Deteksi Dini Stunting (Anak 18 Bulan). Tinggi badan 75 cm dan berat badan 9.5 kg. Tinggi badan anak di bawah standar WHO. Diperlukan evaluasi komprehensif asupan nutrisi, riwayat kesehatan, dan pola makan untuk intervensi stunting.',
      diagnosis: 'Risiko stunting - tinggi badan kurang dari standar usia',
      prescription:
          'Susu tinggi protein, makanan padat gizi (telur, ikan, sayuran hijau), vitamin D dan kalsium, kontrol rutin setiap bulan untuk monitoring pertumbuhan',
      notes: 'Kontrol ulang dalam 1 bulan. Jika tidak ada peningkatan, rujuk ke spesialis gizi.',
    ),
    ConsultationEntry(
      title: 'Konsultasi Tumbuh Kembang',
      doctorName: 'dr. Budi Santoso',
      doctorSpecialty: null,
      date: DateTime.now().subtract(const Duration(days: 90)),
      description:
          'Konsultasi pertumbuhan: saran pemberian makanan pendamping dan tips menyusui.',
      diagnosis: 'Pertumbuhan dalam batas normal',
      prescription: 'Tambahkan variasi MPASI; pantau berat setiap bulan',
      notes: null,
    ),
  ]);

  static List<ConsultationEntry> get consultations =>
      consultationsNotifier.value;

  static void add(ConsultationEntry entry) {
    final list = [...consultationsNotifier.value, entry];
    list.sort((a, b) => b.date.compareTo(a.date));
    consultationsNotifier.value = List<ConsultationEntry>.from(list);
  }

  static void removeAt(int index) {
    final list = [...consultationsNotifier.value];
    if (index < 0 || index >= list.length) return;
    list.removeAt(index);
    consultationsNotifier.value = List<ConsultationEntry>.from(list);
  }
}
