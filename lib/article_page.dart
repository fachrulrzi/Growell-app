import 'package:flutter/material.dart';

import 'article_detail_page.dart';
import 'reels_page.dart';
import 'profile_page.dart';

class ArticlePage extends StatelessWidget {
  const ArticlePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B8CFF),
        foregroundColor: Colors.white,
        title: const Text('Artikel Edukasi'),
        elevation: 0,
        leading: Navigator.canPop(context) ? const BackButton() : null,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 20),
        itemCount: _articles.length,
        itemBuilder: (context, index) =>
            _ArticleCard(article: _articles[index]),
      ),
    );
  }
}

class _ArticleCard extends StatelessWidget {
  final _Article article;

  const _ArticleCard({required this.article});

  @override
  Widget build(BuildContext context) {
    void openDetail() {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => ArticleDetailPage(
            title: article.title,
            subtitle: article.subtitle,
            imageUrl: article.image,
            body: article.body,
          ),
        ),
      );
    }

    final card = Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
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
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(14),
              topRight: Radius.circular(14),
            ),
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(article.image, fit: BoxFit.cover),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F3FF),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        article.category,
                        style: const TextStyle(
                          color: Color(0xFF0B8CFF),
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.schedule, size: 14, color: Colors.grey),
                    const SizedBox(width: 4),
                    Text(
                      article.duration,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Icon(
                      Icons.remove_red_eye_outlined,
                      size: 14,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      article.views,
                      style: TextStyle(
                        color: Colors.grey.shade600,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  article.title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  article.subtitle,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0B8CFF),
                      side: const BorderSide(color: Color(0xFF0B8CFF)),
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: openDetail,
                    child: const Text(
                      'Baca Selengkapnya',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );

    return InkWell(
      onTap: openDetail,
      borderRadius: BorderRadius.circular(14),
      child: card,
    );
  }
}

class _Article {
  final String title;
  final String subtitle;
  final String duration;
  final String views;
  final String category;
  final String image;
  final String body;

  const _Article({
    required this.title,
    required this.subtitle,
    required this.duration,
    required this.views,
    required this.category,
    required this.image,
    required this.body,
  });
}

const List<_Article> _articles = [
  _Article(
    title: 'MPASI tinggi protein untuk ngejar gizi',
    subtitle:
        'Strategi memilih bahan makanan tinggi protein dan kalori untuk anak dengan status gizi merah.',
    duration: '4 menit',
    views: '1.2k',
    category: 'Gizi',
    image:
        'https://images.unsplash.com/photo-1504674900247-0877df9cc836?auto=format&fit=crop&w=900&q=60',
    body:
        'Pilih protein hewani utama (ayam, telur, daging sapi) dan tambahkan minyak sehat seperti EVOO atau butter di tiap porsi. Sajikan karbohidrat kompleks (beras merah, kentang) dan sayur lembut, dengan porsi kecil tapi sering 4-5 kali sehari.',
  ),
  _Article(
    title: 'Tips stimulasi motorik harian',
    subtitle:
        'Aktivitas sederhana pagi dan sore untuk membantu perkembangan motorik kasar dan halus.',
    duration: '3 menit',
    views: '980',
    category: 'Stimulasi',
    image:
        'https://images.unsplash.com/photo-1523475472560-d2df97ec485c?auto=format&fit=crop&w=900&q=60',
    body:
        'Mulai dengan jalan di permukaan berbeda, meremas spons, memindahkan kacang dengan sendok kecil, dan meronce benda besar. Lakukan 10-15 menit, 2 sesi per hari dengan pengawasan.',
  ),
  _Article(
    title: 'Mengelola alergi susu sapi',
    subtitle:
        'Kenali gejala umum, alternatif protein, dan cara membaca label agar aman untuk balita.',
    duration: '5 menit',
    views: '760',
    category: 'Alergi',
    image:
        'https://images.unsplash.com/photo-1467003909585-2f8a72700288?auto=format&fit=crop&w=900&q=60',
    body:
        'Periksa label “milk”, “casein”, “whey”. Gunakan alternatif: susu kedelai/almond terfortifikasi (sesuai rekomendasi dokter). Catat reaksi di food diary dan konsultasikan untuk rencana eliminasi atau reintroduksi.',
  ),
  _Article(
    title: 'Pola tidur sehat untuk tumbuh kembang',
    subtitle:
        'Rutinitas tidur malam yang membantu hormon pertumbuhan bekerja optimal.',
    duration: '4 menit',
    views: '1.1k',
    category: 'Tidur',
    image:
        'https://images.unsplash.com/photo-1500530855697-b586d89ba3ee?auto=format&fit=crop&w=900&q=60',
    body:
        'Buat ritual 30 menit sebelum tidur: mandi air hangat, pijat ringan, cerita buku, lampu temaram. Hindari layar 60 menit sebelum tidur dan jaga kamar 24-26°C.',
  ),
];

// Public accessor used by other pages (e.g. HomePage) to show summaries
List<Map<String, String>> getArticleSummaries() {
  return _articles
      .map(
        (a) => {
          'title': a.title,
          'subtitle': a.subtitle,
          'duration': a.duration,
          'views': a.views,
          'category': a.category,
          'image': a.image,
          'body': a.body,
        },
      )
      .toList();
}
