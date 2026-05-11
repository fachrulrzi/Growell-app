import 'package:flutter/material.dart';

import 'article_detail_page.dart';
import 'article_page.dart';
import 'profile_page.dart';
import 'reels_page.dart';

class RecommendationPage extends StatelessWidget {
  const RecommendationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF2F2F2),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B8CFF),
        foregroundColor: Colors.white,
        title: const Text('Rekomendasi Makanan'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _warningBanner(),
            const SizedBox(height: 16),
            _sectionTitle('Sesuai Kondisi Anak Anda (18 Bulan, MERAH)'),
            const SizedBox(height: 12),
            _foodGrid(context),
            const SizedBox(height: 20),
            _sectionTitle('Panduan Umum Tumbuh Kembang Anak'),
            const SizedBox(height: 12),
            _articleList(),
          ],
        ),
      ),
    );
  }

  Widget _warningBanner() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFF52B68),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        'PERINGATAN: Gizi MERAH, Kekurangan Gizi / Stunting.\nFokus: Tingkatkan Protein, Kalori & Stimulasi Intensif.',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          height: 1.4,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w800,
        color: Colors.black87,
      ),
    );
  }

  Widget _foodGrid(BuildContext context) {
    final items = List.generate(2, (i) => i);
    return Row(
      children: items
          .map(
            (i) => Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i == 0 ? 10 : 0),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: AspectRatio(
                        aspectRatio: 1,
                        child: Image.network(
                          'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=400&q=60',
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Resep MPASI Super Gizi:\nTinggi Kalori & Protein',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'Paket menu tinggi protein, minyak sehat, dan karbohidrat kompleks untuk mengejar ketertinggalan.',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.black87,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.center,
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) =>
                                  const ReelsPage(topic: 'rekomendasi-makanan'),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B8CFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: const Text(
                          'Ayo Coba',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          )
          .toList(),
    );
  }

  Widget _articleList() {
    final articles = [
      ArticleCard(
        title: 'Tips Menjaga Pola Tidur Bayi',
        subtitle:
            'Rutinitas dan lingkungan tidur yang membantu bayi lebih cepat terlelap.',
        body:
            'Jaga jadwal tidur konsisten, redupkan lampu 30 menit sebelum tidur, hindari layar, dan lakukan rutinitas singkat seperti mandi air hangat lalu membaca buku. Pastikan kamar sejuk 24-26°C.',
        time: '5 hours ago',
        views: '64 views',
        imageUrl:
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=200&q=60',
      ),
      ArticleCard(
        title: 'Stimulasi Motorik Halus',
        subtitle:
            'Latihan sederhana untuk memperkuat genggaman dan koordinasi tangan.',
        body:
            'Coba permainan meremas spons, memindahkan kacang dengan sendok kecil, atau meronce benda besar. Lakukan 10-15 menit, dua kali sehari dengan pengawasan.',
        time: '5 hours ago',
        views: '64 views',
        imageUrl:
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=200&q=60',
      ),
      ArticleCard(
        title: 'Pentingnya Bermain untuk Tumbuh Kembang',
        subtitle:
            'Mengapa sesi bermain harian membantu bahasa, emosi, dan motorik.',
        body:
            'Sediakan waktu bermain terstruktur (puzzle, balok) dan bebas (berlari, menari). Ikut terlibat, berikan pujian spesifik, dan batasi gawai agar stimulasi optimal.',
        time: '5 hours ago',
        views: '64 views',
        imageUrl:
            'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=200&q=60',
      ),
    ];

    return Column(
      children: articles
          .map(
            (a) =>
                Padding(padding: const EdgeInsets.only(bottom: 10), child: a),
          )
          .toList(),
    );
  }

  Widget _bottomNav(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: 0,
      selectedItemColor: const Color(0xFF0B8CFF),
      unselectedItemColor: Colors.grey.shade500,
      type: BottomNavigationBarType.fixed,
      onTap: (idx) {
        if (idx == 2) {
          // middle slot reserved for FAB; ignore taps
          return;
        }
        switch (idx) {
          case 0:
            Navigator.of(context).pop();
            break;
          case 1:
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ReelsPage(topic: 'rekomendasi-makanan'),
              ),
            );
            break;
          case 3:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Konsultasi belum tersedia di halaman ini'),
                duration: Duration(seconds: 2),
              ),
            );
            break;
          case 4:
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const ProfilePage()));
            break;
          default:
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Menu belum tersedia di halaman ini'),
                duration: Duration(seconds: 2),
              ),
            );
        }
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home_outlined),
          label: 'Beranda',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.play_circle_outline),
          label: 'Reels',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.circle, color: Colors.transparent),
          label: '',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.medical_services_outlined),
          label: 'Konsultasi',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person_outline),
          label: 'Profil',
        ),
      ],
    );
  }
}

class ArticleCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String body;
  final String time;
  final String views;
  final String imageUrl;

  const ArticleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.body,
    required this.time,
    required this.views,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    void openDetail() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ArticleDetailPage(
            title: title,
            subtitle: subtitle,
            imageUrl: imageUrl,
            body: body,
          ),
        ),
      );
    }

    return InkWell(
      onTap: openDetail,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(12),
                bottomLeft: Radius.circular(12),
              ),
              child: Image.network(
                imageUrl,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        time,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.remove_red_eye_outlined,
                        size: 14,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        views,
                        style: TextStyle(
                          fontSize: 11,
                          color: Colors.grey.shade600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
          ],
        ),
      ),
    );
  }
}
