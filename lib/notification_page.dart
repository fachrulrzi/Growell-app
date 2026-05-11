import 'package:flutter/material.dart';

class NotificationPage extends StatelessWidget {
  const NotificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    final items = _mockNotifications;
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B8CFF),
        foregroundColor: Colors.white,
        title: const Text('Notifikasi'),
        elevation: 0,
      ),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        itemBuilder: (context, index) {
          final item = items[index];
          return _NotificationCard(item: item);
        },
        separatorBuilder: (context, _) => const SizedBox(height: 12),
        itemCount: items.length,
      ),
    );
  }
}

class _NotificationItem {
  final String title;
  final String subtitle;
  final String date;
  final String time;

  const _NotificationItem({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.time,
  });
}

class _NotificationCard extends StatelessWidget {
  final _NotificationItem item;

  const _NotificationCard({required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFFE8F3FF),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF0B8CFF).withOpacity(0.18)),
            ),
            child: const Icon(Icons.campaign, color: Color(0xFF0B8CFF), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  item.subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${item.date}, ${item.time}',
                  style: const TextStyle(
                    fontSize: 11,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

const List<_NotificationItem> _mockNotifications = [
  _NotificationItem(
    title: 'Saatnya Cek Gizi Hari Ini!',
    subtitle: 'Pastikan si kecil mendapat asupan protein dan sayur hari ini. Yuk cek rekomendasi menu di aplikasi!',
    date: '09/06/2025',
    time: '14:02',
  ),
  _NotificationItem(
    title: 'Pantauan Tumbuh Kembang Tersedia!',
    subtitle: 'Data terbaru tinggi dan berat badan anak telah tersedia. Lihat grafik tumbuh kembang sekarang.',
    date: '09/06/2025',
    time: '10:45',
  ),
  _NotificationItem(
    title: 'Saatnya Cek Gizi Hari Ini!',
    subtitle: 'Pastikan si kecil mendapat asupan protein dan sayur hari ini. Yuk cek rekomendasi menu di aplikasi!',
    date: '09/06/2025',
    time: '14:02',
  ),
  _NotificationItem(
    title: 'Pantauan Tumbuh Kembang Tersedia!',
    subtitle: 'Data terbaru tinggi dan berat badan anak telah tersedia. Lihat grafik tumbuh kembang sekarang.',
    date: '09/06/2025',
    time: '10:45',
  ),
  _NotificationItem(
    title: 'Saatnya Cek Gizi Hari Ini!',
    subtitle: 'Pastikan si kecil mendapat asupan protein dan sayur hari ini. Yuk cek rekomendasi menu di aplikasi!',
    date: '09/06/2025',
    time: '14:02',
  ),
  _NotificationItem(
    title: 'Saatnya Cek Gizi Hari Ini!',
    subtitle: 'Pastikan si kecil mendapat asupan protein dan sayur hari ini. Yuk cek rekomendasi menu di aplikasi!',
    date: '09/06/2025',
    time: '14:02',
  ),
];
