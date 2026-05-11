import 'package:flutter/material.dart';
import 'konsultasi_doctor_page.dart';

class PilihDokterPage extends StatelessWidget {
  final List<Map<String, String>> doctors = [
    {
      'name': 'Dr. Irfan Nufis M, Sp.A',
      'specialist': 'Spesialis Anak',
      'photo': '',
    },
    {
      'name': 'Dr. Siti Rahmawati, Sp.PD',
      'specialist': 'Spesialis Penyakit Dalam',
      'photo': '',
    },
    {
      'name': 'Dr. Budi Santoso, Sp.OG',
      'specialist': 'Spesialis Kandungan',
      'photo': '',
    },
    // Tambahkan dokter lain sesuai kebutuhan
  ];

  PilihDokterPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih Dokter'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: doctors.length,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (context, index) {
          final doctor = doctors[index];
          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            elevation: 2,
            child: ListTile(
              leading: CircleAvatar(
                radius: 28,
                backgroundColor: Colors.blue[100],
                child: Icon(Icons.person, color: Colors.blue, size: 32),
              ),
              title: Text(
                doctor['name'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              subtitle: Text(doctor['specialist'] ?? ''),
              trailing: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => KonsultasiDoctorPage(
                        doctorName: doctor['name'] ?? '',
                        doctorSpecialist: doctor['specialist'] ?? '',
                        doctorPhoto: doctor['photo'],
                      ),
                    ),
                  );
                },
                child: const Text('Konsultasi'),
              ),
            ),
          );
        },
      ),
    );
  }
}
