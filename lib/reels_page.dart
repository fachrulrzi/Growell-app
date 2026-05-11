import 'dart:async';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:url_launcher/url_launcher.dart';

class ReelsPage extends StatefulWidget {
  final bool embedded;
  final String? topic;

  const ReelsPage({super.key, this.embedded = false, this.topic});

  @override
  State<ReelsPage> createState() => _ReelsPageState();
}

class _ReelsPageState extends State<ReelsPage> {
  final PageController _controller = PageController();
  late final List<_ReelItem> _items;

  @override
  void initState() {
    super.initState();
    final source = _itemsForTopic(widget.topic) ?? _mockReels;
    _items = source.map((item) => item.copy()).toList();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = Stack(
      children: [
        PageView.builder(
          controller: _controller,
          scrollDirection: Axis.vertical,
          itemCount: _items.length,
          itemBuilder: (context, index) => _ReelView(
            item: _items[index],
            onLike: () => _toggleLike(index),
            onComment: () => _openComments(index),
          ),
        ),
        if (!widget.embedded)
          Positioned(
            top: 12,
            left: 12,
            child: _BackButton(onTap: () => Navigator.of(context).pop()),
          ),
      ],
    );

    if (widget.embedded) {
      return body;
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(child: body),
    );
  }

  void _toggleLike(int index) {
    setState(() {
      final reel = _items[index];
      reel.liked = !reel.liked;
      reel.likes += reel.liked ? 1 : -1;
    });
  }

  void _openComments(int index) {
    final reel = _items[index];
    final controller = TextEditingController();
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: Colors.black,
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(16, 6, 16, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Komentar (${reel.comments})',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 12),
              ..._sampleComments
                  .map(
                    (text) => Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        text,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              const SizedBox(height: 4),
              TextField(
                controller: controller,
                style: const TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Tulis komentar...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.08),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final text = controller.text.trim();
                    if (text.isEmpty) return;
                    setState(() {
                      reel.comments += 1;
                    });
                    Navigator.of(ctx).pop();
                    if (!mounted) return;
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Komentar terkirim: "$text"'),
                        duration: const Duration(seconds: 2),
                      ),
                    );
                  },
                  child: const Text(
                    'Kirim komentar',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ReelItem {
  final String title;
  final String description;
  final String duration;
  int likes;
  int comments;
  final String author;
  final String avatar;
  final String? videoUrl;
  final String? videoAsset; // Local video asset path
  bool liked;

  _ReelItem({
    required this.title,
    required this.description,
    required this.duration,
    required this.likes,
    required this.comments,
    required this.author,
    required this.avatar,
    this.videoUrl,
    this.videoAsset,
    this.liked = false,
  });

  _ReelItem copy() => _ReelItem(
    title: title,
    description: description,
    duration: duration,
    likes: likes,
    comments: comments,
    author: author,
    avatar: avatar,
    videoUrl: videoUrl,
    videoAsset: videoAsset,
    liked: liked,
  );
}

class _ReelView extends StatefulWidget {
  final _ReelItem item;
  final VoidCallback onLike;
  final VoidCallback onComment;

  const _ReelView({
    required this.item,
    required this.onLike,
    required this.onComment,
  });

  @override
  State<_ReelView> createState() => _ReelViewState();
}

class _ReelViewState extends State<_ReelView> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _showUI = true;
  bool _isDescriptionExpanded = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 4), () {
      if (mounted) {
        setState(() {
          _showUI = false;
        });
      }
    });
  }

  void _toggleUI() {
    setState(() {
      _showUI = !_showUI;
      if (_showUI) {
        _startHideTimer();
      }
    });
  }

  Future<void> _initializeVideo() async {
    if (widget.item.videoAsset != null && widget.item.videoAsset!.isNotEmpty) {
      try {
        _controller = VideoPlayerController.asset(widget.item.videoAsset!);
        await _controller!.initialize();
        await _controller!.setLooping(true);
        await _controller!.play();
        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      } catch (e) {
        print('Error loading video: $e');
        print('Video path: ${widget.item.videoAsset}');
        if (mounted) {
          setState(() {
            _hasError = true;
          });
        }
      }
    }
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Toggle UI visibility
        _toggleUI();

        // Toggle play/pause for local video
        if (_controller != null && _isInitialized) {
          if (_controller!.value.isPlaying) {
            _controller!.pause();
          } else {
            _controller!.play();
          }
        }
        // Open YouTube link if videoUrl exists
        else if (widget.item.videoUrl != null &&
            widget.item.videoUrl!.isNotEmpty) {
          _launchVideo(widget.item.videoUrl!);
        }
      },
      child: Stack(
        children: [
          // Video player or placeholder
          if (_controller != null && _isInitialized)
            Positioned.fill(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            )
          else
            Positioned.fill(
              child: Container(
                color:
                    _hasError ||
                        (widget.item.videoUrl != null &&
                            widget.item.videoUrl!.isNotEmpty)
                    ? Colors.black87
                    : Colors.grey.shade400,
                child: _hasError
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.warning_amber_rounded,
                              color: Colors.orange,
                              size: 80,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Video MP4 Lokal',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tidak support di Web/Chrome',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Gunakan Android APK untuk melihat video',
                              style: TextStyle(
                                color: Colors.white60,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : widget.item.videoUrl != null &&
                          widget.item.videoUrl!.isNotEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.play_circle_filled,
                              color: Colors.red.shade600,
                              size: 80,
                            ),
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'YouTube Video',
                                style: TextStyle(
                                  color: Colors.black87,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'Tap untuk membuka',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.play_circle_outline,
                          color: Colors.white,
                          size: 80,
                        ),
                      ),
              ),
            ),
          // Gradient overlays for readability
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.55),
                    Colors.transparent,
                    Colors.black.withOpacity(0.65),
                  ],
                  stops: const [0, 0.4, 1],
                ),
              ),
            ),
          ),
          // Video progress slider (with fade animation)
          if (_controller != null && _isInitialized)
            AnimatedPositioned(
              duration: const Duration(milliseconds: 300),
              left: 16,
              right: 16,
              bottom: _showUI ? 5 : -100,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: _showUI ? 1.0 : 0.0,
                child: Column(
                  children: [
                    ValueListenableBuilder(
                      valueListenable: _controller!,
                      builder: (context, VideoPlayerValue value, child) {
                        return Column(
                          children: [
                            SliderTheme(
                              data: SliderThemeData(
                                trackHeight: 3,
                                thumbShape: const RoundSliderThumbShape(
                                  enabledThumbRadius: 6,
                                ),
                                overlayShape: const RoundSliderOverlayShape(
                                  overlayRadius: 14,
                                ),
                                activeTrackColor: Colors.white,
                                inactiveTrackColor: Colors.white.withOpacity(
                                  0.3,
                                ),
                                thumbColor: Colors.white,
                                overlayColor: Colors.white.withOpacity(0.3),
                              ),
                              child: Slider(
                                value: value.position.inMilliseconds.toDouble(),
                                min: 0,
                                max: value.duration.inMilliseconds.toDouble(),
                                onChanged: (newValue) {
                                  _controller!.seekTo(
                                    Duration(milliseconds: newValue.toInt()),
                                  );
                                  _startHideTimer();
                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    _formatDuration(value.position),
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  Text(
                                    _formatDuration(value.duration),
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          // Right action bar (with fade animation)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            right: _showUI ? 16 : -100,
            bottom: 90,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showUI ? 1.0 : 0.0,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconStat(
                    icon: widget.item.liked
                        ? Icons.favorite
                        : Icons.favorite_border,
                    label: widget.item.likes.toString(),
                    color: widget.item.liked ? Colors.redAccent : Colors.white,
                    onTap: widget.onLike,
                  ),
                  const SizedBox(height: 18),
                  _iconStat(
                    icon: Icons.chat_bubble_outline,
                    label: widget.item.comments.toString(),
                    onTap: widget.onComment,
                  ),
                  const SizedBox(height: 18),
                  _iconStat(icon: Icons.reply_rounded, label: 'Share'),
                  const SizedBox(height: 18),
                  _iconStat(icon: Icons.bookmark_border, label: 'Save'),
                ],
              ),
            ),
          ),
          // Bottom info (with fade animation)
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            left: 16,
            right: 80,
            bottom: _showUI ? 65 : -200,
            child: AnimatedOpacity(
              duration: const Duration(milliseconds: 300),
              opacity: _showUI ? 1.0 : 0.0,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          widget.item.author,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.item.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _isDescriptionExpanded = !_isDescriptionExpanded;
                            });
                            if (_showUI) {
                              _startHideTimer();
                            }
                          },
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                widget.item.description,
                                maxLines: _isDescriptionExpanded ? null : 2,
                                overflow: _isDescriptionExpanded
                                    ? TextOverflow.visible
                                    : TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  height: 1.3,
                                ),
                              ),
                              if (widget.item.description.length > 80)
                                Padding(
                                  padding: const EdgeInsets.only(top: 4),
                                  child: Text(
                                    _isDescriptionExpanded
                                        ? 'Lebih sedikit'
                                        : 'Selengkapnya...',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Play/Pause button overlay
          if (_controller != null && _isInitialized)
            Center(
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 200),
                opacity: !_controller!.value.isPlaying ? 1.0 : 0.0,
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.play_arrow_rounded,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  Widget _iconStat({
    required IconData icon,
    required String label,
    Color color = Colors.white,
    VoidCallback? onTap,
  }) {
    final content = Column(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.35),
            shape: BoxShape.circle,
          ),
          child: Icon(icon, color: color, size: 24),
        ),
        const SizedBox(height: 6),
        Text(label, style: const TextStyle(color: Colors.white, fontSize: 12)),
      ],
    );

    if (onTap == null) return content;

    return GestureDetector(onTap: onTap, child: content);
  }

  Widget _avatar(String initial) {
    return CircleAvatar(
      radius: 20,
      backgroundColor: Colors.white,
      child: Text(
        initial,
        style: const TextStyle(
          color: Colors.black87,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Future<void> _launchVideo(String url) async {
    try {
      final Uri videoUri = Uri.parse(url);
      final canLaunch = await canLaunchUrl(videoUri);
      if (canLaunch) {
        await launchUrl(videoUri, mode: LaunchMode.externalApplication);
      } else {
        await launchUrl(videoUri);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Tidak dapat membuka video: $e'),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }
  }
}

class _BackButton extends StatelessWidget {
  final VoidCallback onTap;

  const _BackButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.35),
          shape: BoxShape.circle,
        ),
        child: const Icon(Icons.arrow_back, color: Colors.white, size: 22),
      ),
    );
  }
}

List<_ReelItem>? _itemsForTopic(String? topic) {
  if (topic == null) return null;

  switch (topic) {
    case 'rekomendasi-makanan':
      return [
        _ReelItem(
          title: 'MPASI tinggi protein untuk ngejar gizi',
          description:
              'Paket menu daging, telur, dan minyak sehat buat naikin kalori & protein harian.',
          duration: '00:48',
          likes: 1420,
          comments: 96,
          author: 'Dr. Irfan Nafis',
          avatar: 'I',
        ),
        _ReelItem(
          title: 'Cara masak cepat MPASI super gizi',
          description:
              'Meal prep 15 menit: ayam cincang, wortel, butter, plus kaldu sendiri.',
          duration: '00:54',
          likes: 980,
          comments: 61,
          author: 'Dr. Irfan Nafis',
          avatar: 'I',
        ),
        _ReelItem(
          title: 'Boost kalori pakai lemak baik',
          description:
              'Tambahkan EVOO/butter ke bubur dan pure buah biar berat badan cepat naik.',
          duration: '00:37',
          likes: 860,
          comments: 44,
          author: 'Dr. Irfan Nafis',
          avatar: 'I',
        ),
      ];
    default:
      return null;
  }
}

final List<_ReelItem> _mockReels = [
  _ReelItem(
    title: 'MPASI 6 Bulan Bergizi',
    description:
        'Menu MPASI 6 bulan pertama menurut Kemenkes yang simple dan bergizi untuk tumbuh kembang optimal.',
    duration: '00:38',
    likes: 2140,
    comments: 156,
    author: 'Dr. Irfan Nafis',
    avatar: 'I',
    videoAsset: 'assets/video/mpasi_6_bulan.mp4',
  ),
  _ReelItem(
    title: 'Tips Menjaga Kesehatan Anak',
    description:
        'Cara efektif menjaga kesehatan dan daya tahan tubuh anak di masa pertumbuhan.',
    duration: '00:38',
    likes: 1540,
    comments: 92,
    author: 'Dr. Irfan Nafis',
    avatar: 'I',
    videoAsset: 'assets/video/Menu_makanan_stunting.mp4',
  ),
  _ReelItem(
    title: 'Menu tinggi protein untuk si kecil',
    description:
        'Resep cepat 10 menit: telur orak-arik bayam dengan keju, cocok untuk sarapan bergizi.',
    duration: '00:42',
    likes: 1240,
    comments: 87,
    author: 'Dr. Irfan Nafis',
    avatar: 'I',
    videoAsset: 'assets/video/mpasi_6_bulan.mp4',
  ),
  _ReelItem(
    title: 'Senam pagi balita',
    description:
        'Gerakan ringan 5 menit untuk melatih motorik kasar dan bikin badan hangat.',
    duration: '01:05',
    likes: 980,
    comments: 42,
    author: 'Dr. Irfan Nafis',
    avatar: 'I',
    videoAsset: 'assets/video/Menu_makanan_stunting.mp4',
  ),
  _ReelItem(
    title: 'Tips batasi gula',
    description:
        'Cara sederhana mengenali camilan anak yang rendah gula tapi tetap disukai.',
    duration: '00:36',
    likes: 760,
    comments: 31,
    author: 'Dr. Irfan Nafis',
    avatar: 'I',
    videoAsset: 'assets/video/mpasi_6_bulan.mp4',
  ),
  _ReelItem(
    title: 'Bekal sehat ke PAUD',
    description: 'Ide bekal praktis: nasi kepal ayam sayur dengan buah potong.',
    duration: '00:48',
    likes: 1120,
    comments: 55,
    author: 'Dr. Irfan Nafis',
    avatar: 'I',
    videoAsset: 'assets/video/Menu_makanan_stunting.mp4',
  ),
];

const List<String> _sampleComments = [
  'Suka banget tipsnya, terima kasih dok!',
  'Boleh bahas alergi susu sapi next?',
  'Resep ini gampang diikuti, anakku doyan.',
];
