import 'package:flutter/material.dart';
import 'add_child_page.dart';
import 'pilih_dokter_page.dart';
import 'recommendation_page.dart';
import 'article_page.dart';
import 'article_detail_page.dart';
import 'growth_camera_page.dart';
import 'notification_page.dart';
import 'reels_page.dart';
import 'profile_page.dart';
import 'nutrition_capture_page.dart';
import 'nutrition_assistant_page.dart';
import 'edit_child_page.dart';
import 'consultation_history_page.dart';
import 'data/child_store.dart';
import 'data/schedule_store.dart';
import 'ibi_page.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:math' as math;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _currentIndex = 0;
  int _activeChild = 0;
  bool _dummyScheduleInjected = false;

  final Color _primary = const Color(0xFF0B8CFF);
  final Color _danger = const Color(0xFFEF2B59);
  final Color _warning = const Color(0xFFF5A524);
  final Color _info = const Color(0xFF35C3F3);
  final Color _success = const Color(0xFF21C384);
  final Color _surface = const Color(0xFFF5F7FB);
  Widget _buildDecorativeCircle(
    double size,
    Color color, {
    double? top,
    double? left,
    double? right,
    double? bottom,
  }) {
    return Positioned(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<List<ChildEntry>>(
      valueListenable: ChildStore.childrenNotifier,
      builder: (context, entries, _) {
        if (entries.isEmpty) {
          return Scaffold(
            backgroundColor: _surface,
            body: SafeArea(
              child: Stack(
                children: [
                  _buildDecorativeCircle(
                    200,
                    _primary.withOpacity(0.05),
                    top: -50,
                    left: -50,
                  ),
                  _buildDecorativeCircle(
                    300,
                    _warning.withOpacity(0.05),
                    bottom: -100,
                    right: -100,
                  ),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(32.0),
                      child: Card(
                        elevation: 8.0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset(
                                'lib/assets/img/logo-growell.png',
                                width: 120,
                              ),
                              const SizedBox(height: 24),
                              const Text(
                                'Selamat Datang!',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                              ),
                              const SizedBox(height: 12),
                              const Text(
                                'Untuk mulai menggunakan aplikasi, silakan tambahkan data anak Anda terlebih dahulu.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black54,
                                  height: 1.5,
                                ),
                              ),
                              const SizedBox(height: 24),
                              SizedBox(
                                width: double.infinity,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: _primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 14,
                                    ),
                                    textStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  onPressed: () async {
                                    await Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) => const AddChildPage(),
                                      ),
                                    );
                                    // Setelah tambah anak, kembali ke Home otomatis
                                  },
                                  child: const Text('Tambah Data Anak'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (ChildStore.activeIndex != null &&
            ChildStore.activeIndex! < entries.length) {
          _activeChild = ChildStore.activeIndex!;
        } else if (_activeChild >= entries.length) {
          _activeChild = entries.isNotEmpty ? entries.length - 1 : 0;
        }
        if (_activeChild < 0) _activeChild = 0;
        final profiles = _mapProfiles(entries);

        // Inject a dummy doctor-assigned schedule once when there are children
        if (!_dummyScheduleInjected &&
            entries.isNotEmpty &&
            ScheduleStore.schedules.isEmpty) {
          _dummyScheduleInjected = true;
          ScheduleStore.add(DateTime.now().add(const Duration(days: 5)));
        }

        return Scaffold(
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerDocked,
          floatingActionButton: FloatingActionButton(
            heroTag: 'main_fab',
            backgroundColor: _primary,
            tooltip: 'Tambah',
            elevation: 4,
            shape: const CircleBorder(),
            child: const Icon(Icons.add, color: Colors.white, size: 28),
            onPressed: () {
              showModalBottomSheet(
                context: context,
                builder: (_) => SafeArea(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ListTile(
                        leading: const Icon(Icons.restaurant_menu),
                        title: const Text('Catat Gizi Harian'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const NutritionCapturePage(),
                            ),
                          );
                        },
                      ),
                      ListTile(
                        leading: const Icon(Icons.camera_alt),
                        title: const Text('Catat Berat Badan (Jepret)'),
                        onTap: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GrowthCameraPage(),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          backgroundColor: _surface,
          body: Stack(
            children: [
              Builder(
                builder: (context) {
                  switch (_currentIndex) {
                    case 0:
                      return SafeArea(
                        child: SingleChildScrollView(
                          padding: const EdgeInsets.only(bottom: 24),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _buildHeader(profiles),
                              const SizedBox(height: 12),
                              ValueListenableBuilder<List<DateTime>>(
                                valueListenable:
                                    ScheduleStore.schedulesNotifier,
                                builder: (_, schedules, __) {
                                  final next = ScheduleStore.next();
                                  if (next == null)
                                    return const SizedBox.shrink();
                                  final days = ScheduleStore.daysUntil(next);
                                  if (days <= 7) {
                                    return Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                      ),
                                      child: Container(
                                        width: double.infinity,
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.orange.shade100,
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          border: Border.all(
                                            color: Colors.orange.shade300,
                                          ),
                                        ),
                                        child: Row(
                                          children: [
                                            const Icon(
                                              Icons.notifications_active,
                                              color: Colors.orange,
                                            ),
                                            const SizedBox(width: 10),
                                            Expanded(
                                              child: Text(
                                                'Peringatan: Dokter menjadwalkan kontrol pada ${ScheduleStore.nextLabel()} (dalam $days hari)',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w700,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    );
                                  }
                                  return const SizedBox.shrink();
                                },
                              ),
                              _buildChildTabs(profiles),
                              const SizedBox(height: 12),
                              _buildAlertCard(profiles),
                              const SizedBox(height: 12),
                              _buildGrowthCard(profiles),
                              const SizedBox(height: 12),
                              _buildActionList(),
                              const SizedBox(height: 12),
                              _buildInfoRow(),
                              const SizedBox(height: 12),
                              _buildRecommendedArticles(),
                            ],
                          ),
                        ),
                      );
                    case 1:
                      return const ReelsPage(embedded: true);
                    case 2:
                      // middle placeholder (FAB handles quick actions)
                      return const SizedBox.shrink();
                    case 3:
                      return PilihDokterPage();
                    case 4:
                      return const ProfilePage();
                    default:
                      return const SizedBox.shrink();
                  }
                },
              ),

              // Floating Nutrition Assistant FAB (bottom-right) - show only on Beranda
              if (_currentIndex == 0)
                Positioned(
                  right: 16,
                  bottom: 84,
                  child: Tooltip(
                    message: 'Tanya Ahli Gizi (AI)',
                    child: FloatingActionButton(
                      heroTag: 'nutrition_assistant_fab',
                      mini: true,
                      backgroundColor: _success,
                      elevation: 6,
                      child: const Icon(
                        Icons.health_and_safety,
                        color: Colors.white,
                        size: 18,
                      ),
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const NutritionAssistantPage(),
                          ),
                        );
                      },
                    ),
                  ),
                ),
            ],
          ),
          bottomNavigationBar: BottomAppBar(
            shape: const CircularNotchedRectangle(),
            notchMargin: 6.0,
            color: Colors.white,
            elevation: 8,
            height: 64,
            child: SizedBox(
              height: 64,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildNavItem(
                    icon: Icons.home_outlined,
                    label: 'Beranda',
                    index: 0,
                  ),
                  _buildNavItem(
                    icon: Icons.play_circle_outline,
                    label: 'Reels',
                    index: 1,
                  ),
                  const SizedBox(width: 56), // Space for FAB
                  _buildNavItem(
                    icon: Icons.medical_services_outlined,
                    label: 'Konsultasi',
                    index: 3,
                  ),
                  _buildNavItem(
                    icon: Icons.person_outline,
                    label: 'Profil',
                    index: 4,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
  }) {
    final isSelected = _currentIndex == index;
    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _currentIndex = index;
          });
        },
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isSelected ? _primary : Colors.grey.shade500,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: isSelected ? _primary : Colors.grey.shade500,
                  fontSize: 11,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  height: 1.0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }

  Color _statusColor(ChildStatus status) {
    switch (status) {
      case ChildStatus.red:
        return _danger;
      case ChildStatus.yellow:
        return _warning;
      case ChildStatus.green:
        return _success;
    }
  }

  String _statusLabel(ChildStatus status) {
    switch (status) {
      case ChildStatus.red:
        return 'MERAH (Kurang)';
      case ChildStatus.yellow:
        return 'KUNING (Waspada)';
      case ChildStatus.green:
        return 'HIJAU (Normal)';
    }
  }

  IconData _statusIcon(ChildStatus status) {
    switch (status) {
      case ChildStatus.red:
        return Icons.warning_amber_rounded;
      case ChildStatus.yellow:
        return Icons.info_outline;
      case ChildStatus.green:
        return Icons.verified_user_outlined;
    }
  }

  List<_ChildProfile> _mapProfiles(List<ChildEntry> entries) {
    if (entries.isEmpty) return [];
    final statuses = [ChildStatus.red, ChildStatus.green, ChildStatus.yellow];
    return entries.asMap().entries.map((entry) {
      final idx = entry.key;
      final child = entry.value;
      final status = statuses[idx % statuses.length];
      final statusDesc = switch (status) {
        ChildStatus.red => 'Gizi anak kurang, kunjungi Puskesmas SEGERA!',
        ChildStatus.yellow => 'Berat badan perlu perhatian lebih',
        ChildStatus.green => 'Berat badan ideal untuk usianya',
      };
      final bars = _sampleBars(status);
      final ageLabel = _ageLabel(child.birthDate);
      return _ChildProfile(
        name: child.name,
        ageLabel: ageLabel,
        status: status,
        statusDesc: statusDesc,
        bars: bars,
      );
    }).toList();
  }

  List<_BarData> _sampleBars(ChildStatus status) {
    // Height is roughly based on WHO child growth standards (e.g., a 1-year-old is ~75cm)
    // Weight is in kg.
    switch (status) {
      case ChildStatus.red:
        return [
          _BarData(label: 'Jan', weight: 5, height: 55, color: _danger),
          _BarData(label: 'Feb', weight: 6, height: 58, color: _danger),
          _BarData(label: 'Mar', weight: 8, height: 62, color: _warning),
          _BarData(label: 'Apr', weight: 10, height: 65, color: _warning),
          _BarData(label: 'May', weight: 12, height: 70, color: _success),
          _BarData(label: 'Jun', weight: 14, height: 72, color: _success),
          _BarData(label: 'Jul', weight: 15, height: 74, color: _success),
          _BarData(label: 'Aug', weight: 16, height: 76, color: _success),
          _BarData(label: 'Sep', weight: 17, height: 78, color: _success),
          _BarData(label: 'Oct', weight: 18, height: 80, color: _success),
          _BarData(label: 'Nov', weight: 18, height: 81, color: _success),
          _BarData(label: 'Dec', weight: 19, height: 82, color: _success),
        ];
      case ChildStatus.yellow:
        return [
          _BarData(label: 'Jan', weight: 9, height: 68, color: _warning),
          _BarData(label: 'Feb', weight: 10, height: 70, color: _warning),
          _BarData(label: 'Mar', weight: 11, height: 72, color: _warning),
          _BarData(label: 'Apr', weight: 12, height: 74, color: _success),
          _BarData(label: 'May', weight: 13, height: 76, color: _success),
          _BarData(label: 'Jun', weight: 14, height: 78, color: _success),
          _BarData(label: 'Jul', weight: 15, height: 80, color: _success),
          _BarData(label: 'Aug', weight: 15, height: 81, color: _warning),
          _BarData(label: 'Sep', weight: 16, height: 82, color: _warning),
          _BarData(label: 'Oct', weight: 16, height: 83, color: _warning),
          _BarData(label: 'Nov', weight: 17, height: 84, color: _warning),
          _BarData(label: 'Dec', weight: 17, height: 85, color: _warning),
        ];
      case ChildStatus.green:
        return [
          _BarData(label: 'Jan', weight: 17, height: 80, color: _success),
          _BarData(label: 'Feb', weight: 17, height: 81, color: _success),
          _BarData(label: 'Mar', weight: 18, height: 82, color: _success),
          _BarData(label: 'Apr', weight: 19, height: 84, color: _success),
          _BarData(label: 'May', weight: 20, height: 86, color: _success),
          _BarData(label: 'Jun', weight: 21, height: 88, color: _success),
          _BarData(label: 'Jul', weight: 21, height: 89, color: _success),
          _BarData(label: 'Aug', weight: 22, height: 90, color: _success),
          _BarData(label: 'Sep', weight: 22, height: 91, color: _success),
          _BarData(label: 'Oct', weight: 23, height: 92, color: _success),
          _BarData(label: 'Nov', weight: 23, height: 93, color: _success),
          _BarData(label: 'Dec', weight: 24, height: 94, color: _success),
        ];
    }
  }

  String _ageLabel(DateTime birthDate) {
    final now = DateTime.now();
    int months = (now.year - birthDate.year) * 12 + now.month - birthDate.month;
    if (now.day < birthDate.day) months -= 1;
    if (months < 24) return '${months.clamp(0, 200)} Bulan';
    final years = (months / 12).floor();
    return '$years Tahun';
  }

  void _showBarDetails(_BarData bar) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Bulan: ${bar.label} | Berat: ${bar.weight.toStringAsFixed(1)} kg | Tinggi: ${bar.height.toStringAsFixed(1)} cm',
        ),
        duration: const Duration(seconds: 3),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Widget _buildHeader(List<_ChildProfile> profiles) {
    if (profiles.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: _primary,
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              'Tambah anak dulu di Profil',
              style: TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w700,
              ),
            ),
            _headerIcon(Icons.notifications_none),
          ],
        ),
      );
    }

    final child = profiles[_activeChild];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: _primary,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Row(
                  children: [
                    const CircleAvatar(
                      radius: 24,
                      backgroundColor: Colors.white,
                      child: Icon(Icons.child_friendly, color: Colors.black87),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Halo, ${child.name}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          child.ageLabel,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              // Removed "Pilih anak" pill per request
              Row(
                children: [
                  _headerIcon(
                    Icons.notifications_none,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const NotificationPage(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 10),
                  _headerIcon(Icons.headset_mic_outlined),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _headerIcon(IconData icon, {VoidCallback? onTap}) {
    final child = Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(icon, color: Colors.white, size: 20),
    );

    if (onTap == null) return child;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: child,
    );
  }

  Widget _buildAlertCard(List<_ChildProfile> profiles) {
    if (profiles.isEmpty) return const SizedBox.shrink();
    final child = profiles[_activeChild];
    final statusColor = _statusColor(child.status);
    final statusLabel = _statusLabel(child.status);
    final statusIcon = _statusIcon(child.status);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 6),
          const Text(
            'Status Tumbuh Kembang Anak',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: statusColor,
              borderRadius: BorderRadius.circular(18),
            ),
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(statusIcon, color: Colors.black87),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Status Perkembangan Anak : $statusLabel',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            child.statusDesc,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => const RecommendationPage(),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      elevation: 3,
                      shadowColor: Colors.black.withOpacity(0.08),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(22),
                      ),
                    ),
                    child: const Text(
                      'Rekomendasi Makanan',
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
        ],
      ),
    );
  }

  Widget _buildChildTabs(List<_ChildProfile> profiles) {
    if (profiles.length <= 1) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 0),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: profiles.asMap().entries.map((entry) {
            final idx = entry.key;
            final child = entry.value;
            final selected = idx == _activeChild;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onLongPress: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => EditChildPage(
                        index: idx,
                        child: ChildStore.childrenNotifier.value[idx],
                      ),
                    ),
                  );
                },
                child: ChoiceChip(
                  label: Text(child.name),
                  selected: selected,
                  onSelected: (_) {
                    setState(() => _activeChild = idx);
                    ChildStore.setActive(idx);
                  },
                  selectedColor: _primary.withOpacity(0.18),
                  labelStyle: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: selected ? _primary : Colors.black87,
                  ),
                  side: BorderSide(
                    color: selected
                        ? _primary.withOpacity(0.8)
                        : Colors.grey.shade300,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _buildInfoRow() {
    final activities = [
      {
        'title': 'Seminar Pencegahan Stunting',
        'subtitle': 'Puskesmas Sukmajaya',
        'date': '29 Juli 2023',
        'badgeText': 'Daftar',
        'color': _primary,
        'url': 'https://forms.gle/vEnqVvVa1jZPSg9f8',
      },
      {
        'title': 'Edukasi Gizi',
        'subtitle': 'Puskesmas Sukmajaya',
        'date': '20 November 2023',
        'badgeText': 'Daftar',
        'color': _primary,
        'url': 'https://forms.gle/vEnqVvVa1jZPSg9f8',
      },
      {
        'title': 'Vaksin Polio',
        'subtitle': 'Posyandu Mawar',
        'date': '10 Desember 2023',
        'badgeText': 'Terjadwal',
        'color': _success,
        'url': null,
      },
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Kegiatan Mendatang',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
          ),
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 130,
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: activities.length,
            clipBehavior: Clip.none,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: (context, index) {
              final activity = activities[index];
              return SizedBox(
                width: MediaQuery.of(context).size.width * 0.65,
                child: _InfoCard(
                  title: activity['title'] as String,
                  subtitle: activity['subtitle'] as String,
                  date: activity['date'] as String,
                  badgeText: activity['badgeText'] as String,
                  color: activity['color'] as Color,
                  url: activity['url'] as String?,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendedArticles() {
    final items = getArticleSummaries();

    if (items.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Rekomendasi Artikel',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const ArticlePage()),
                  );
                },
                child: const Text('Lihat Semua'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 220,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(width: 12),
              itemBuilder: (context, idx) {
                final it = items[idx];
                return GestureDetector(
                  onTap: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ArticleDetailPage(
                          title: it['title'] ?? '',
                          subtitle: it['subtitle'] ?? '',
                          imageUrl: it['image'] ?? '',
                          body: it['body'] ?? '',
                        ),
                      ),
                    );
                  },
                  child: Container(
                    width: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.06),
                          blurRadius: 12,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // image with overlay title
                        Stack(
                          children: [
                            AspectRatio(
                              aspectRatio: 16 / 9,
                              child: Image.network(
                                it['image'] ?? '',
                                fit: BoxFit.cover,
                                width: double.infinity,
                                errorBuilder: (ctx, err, stack) => Container(
                                  color: Colors.grey.shade200,
                                  child: const Icon(
                                    Icons.article_outlined,
                                    size: 40,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ),
                            // gradient + title overlay
                            Positioned(
                              left: 0,
                              right: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.fromLTRB(
                                  10,
                                  8,
                                  10,
                                  8,
                                ),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.topCenter,
                                    end: Alignment.bottomCenter,
                                    colors: [
                                      Colors.transparent,
                                      Colors.black.withOpacity(0.45),
                                    ],
                                  ),
                                ),
                                child: Text(
                                  it['title'] ?? '',
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ),
                            ),
                            // category badge
                            if ((it['category'] ?? '').isNotEmpty)
                              Positioned(
                                left: 8,
                                top: 8,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.9),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Text(
                                    it['category'] ?? '',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w700,
                                      color: Colors.black87,
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                it['subtitle'] ?? '',
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey.shade800,
                                ),
                              ),
                              const SizedBox(height: 10),
                              Row(
                                children: [
                                  Icon(
                                    Icons.schedule,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    it['duration'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Icon(
                                    Icons.remove_red_eye_outlined,
                                    size: 14,
                                    color: Colors.grey.shade600,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    it['views'] ?? '',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey.shade600,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrowthCard(List<_ChildProfile> profiles) {
    if (profiles.isEmpty) return const SizedBox.shrink();
    final child = profiles[_activeChild];
    final bars = child.bars;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        height: 320,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Flexible(
                  child: Text(
                    'Ringkasan Tumbuh Kembang',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    'Berat & Tinggi (Kg/cm)',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                    textAlign: TextAlign.right,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Expanded(
              child: _buildBarChart(
                bars,
                highlightIndex: DateTime.now().month - 1,
                highlightColor: _statusColor(child.status),
              ),
            ),
            const SizedBox(height: 12),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(
    List<_BarData> bars, {
    int? highlightIndex,
    Color? highlightColor,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Use available height to avoid overflow inside tight flex constraints
        final totalHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 180.0;
        const labelHeight = 18.0;
        const gap = 8.0;
        final maxBarHeight = math.max(0.0, totalHeight - labelHeight - gap);
        const maxValue = 30.0; // Max for weight

        return SizedBox(
          height: totalHeight,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: bars.asMap().entries.map((entry) {
              final idx = entry.key;
              final bar = entry.value;
              final value = bar.weight;
              final color =
                  (highlightIndex != null &&
                      highlightIndex == idx &&
                      highlightColor != null)
                  ? highlightColor
                  : bar.color;
              final barH = maxBarHeight * (value / maxValue);
              return Expanded(
                child: GestureDetector(
                  onTap: () => _showBarDetails(bar),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Container(
                        height: barH,
                        decoration: BoxDecoration(
                          color: color,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: gap),
                      Text(
                        bar.label,
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        );
      },
    );
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendDot(_success, 'Normal'),
        _legendDot(_warning, 'Waspada'),
        _legendDot(_danger, 'Kurang'),
      ],
    );
  }

  Widget _legendDot(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, color: Colors.black87)),
      ],
    );
  }

  Widget _buildActionList() {
    return ValueListenableBuilder<List<DateTime>>(
      valueListenable: ScheduleStore.schedulesNotifier,
      builder: (_, schedules, __) {
        final actions = [
          _ActionItem(
            title: 'Konsultasi Dokter',
            subtitle: 'Mulai chat atau buat jadwal',
            icon: Icons.medical_information,
            color: _primary,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => PilihDokterPage()));
            },
          ),
          _ActionItem(
            title: 'Riwayat Konsultasi Dokter',
            subtitle: 'Lihat catatan sebelumnya',
            icon: Icons.history,
            color: _info,
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const ConsultationHistoryPage(),
                ),
              );
            },
          ),

          _ActionItem(
            title: 'Cek Gizi Si Kecil',
            subtitle: 'Pantau detail nutrisi yang dikonsumsi',
            icon: Icons.timeline,
            color: _success,
            onTap: () {
              Navigator.of(
                context,
              ).push(MaterialPageRoute(builder: (_) => const IbiPage()));
            },
          ),
        ];

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 8),
              Text(
                'Layanan Kesehatan',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 10),
              ...actions.map(
                (item) => Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _ActionTile(item: item),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // _showChildSheet dihapus, diganti dengan EditChildPage

  Widget _genderChip(String text, bool selected, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFF0B8CFF).withOpacity(0.12)
              : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: selected ? const Color(0xFF0B8CFF) : Colors.grey.shade300,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            color: selected ? const Color(0xFF0B8CFF) : Colors.black87,
          ),
        ),
      ),
    );
  }

  Widget _label(String text) {
    return Text(
      text,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w700,
        color: Colors.black87,
      ),
    );
  }

  Widget _input(
    TextEditingController controller, {
    String? hint,
    TextInputType keyboard = TextInputType.text,
  }) {
    return TextField(
      controller: controller,
      keyboardType: keyboard,
      decoration: InputDecoration(
        hintText: hint,
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: _primary),
        ),
      ),
    );
  }

  String _formatDate(DateTime? date) {
    if (date == null) return '-';
    final d = date.day.toString().padLeft(2, '0');
    final m = date.month.toString().padLeft(2, '0');
    final y = date.year.toString();
    return '$d/$m/$y';
  }
}

class _InfoCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String date;
  final String badgeText;
  final Color color;
  final String? url;

  const _InfoCard({
    required this.title,
    required this.subtitle,
    required this.date,
    required this.badgeText,
    required this.color,
    this.url,
  });

  Future<void> _launchUrl(String? urlString) async {
    if (urlString == null || urlString.isEmpty) return;
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      // In a real app, show a snackbar or some other feedback
      debugPrint('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w700,
              height: 1.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(color: Colors.white70, fontSize: 11),
          ),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  date,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              InkWell(
                onTap: () => _launchUrl(url),
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: url != null && url!.isNotEmpty
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    badgeText,
                    style: TextStyle(
                      color: url != null && url!.isNotEmpty
                          ? Colors.black87
                          : Colors.black.withOpacity(0.6),
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BarData {
  final String label;
  final double weight;
  final double height;
  final Color color;

  _BarData({
    required this.label,
    required this.weight,
    required this.height,
    required this.color,
  });

  _BarData copyWith({
    String? label,
    double? weight,
    double? height,
    Color? color,
  }) {
    return _BarData(
      label: label ?? this.label,
      weight: weight ?? this.weight,
      height: height ?? this.height,
      color: color ?? this.color,
    );
  }
}

class _ActionItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  _ActionItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    this.onTap,
  });
}

class _ActionTile extends StatelessWidget {
  final _ActionItem item;

  const _ActionTile({required this.item});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: item.onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: item.color.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: Icon(item.icon, color: item.color),
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
                  const SizedBox(height: 4),
                  Text(
                    item.subtitle,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }
}

class _ChildProfile {
  final String name;
  final String ageLabel;
  final ChildStatus status;
  final String statusDesc;
  final List<_BarData> bars;

  _ChildProfile({
    required this.name,
    required this.ageLabel,
    required this.status,
    required this.statusDesc,
    required this.bars,
  });
}

enum ChildStatus { red, yellow, green }
