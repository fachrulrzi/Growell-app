import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:growell/post_preview_sheet.dart';
import 'package:permission_handler/permission_handler.dart';
import 'data/nutrition_store.dart';
import 'ibi_page.dart';

class NutritionCapturePage extends StatefulWidget {
  const NutritionCapturePage({super.key});

  @override
  State<NutritionCapturePage> createState() => _NutritionCapturePageState();
}

class _NutritionCapturePageState extends State<NutritionCapturePage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initFuture;
  String? _initError;
  bool _isProcessing = false;
  bool _previewPaused = false;
  XFile? _photo;
  DateTime? _capturedAt;
  Map<String, double>? _results;

  bool get _isCameraReady =>
      (_controller?.value.isInitialized ?? false) &&
      !(_controller?.value.isTakingPicture ?? false);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initFuture = _initCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _controller?.dispose();
    _controller = null;
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      controller.dispose();
      _controller = null;
    } else if (state == AppLifecycleState.resumed) {
      _initFuture = _initCamera(forceReinit: true);
      _previewPaused = false;
      setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    final timestamp = _capturedAt == null
        ? '-'
        : _formatTimestamp(_capturedAt!);
    final hasResult = _results != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('Input Gizi Harian'),
        backgroundColor: const Color(0xFF0B8CFF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildInstruction(),
            const SizedBox(height: 16),
            _buildCameraCard(timestamp, hasResult),
            const SizedBox(height: 10),
            if (_isProcessing) const LinearProgressIndicator(minHeight: 4),
            const SizedBox(height: 10),
            if (hasResult) _buildResultCard(_results!),
            if (hasResult) const SizedBox(height: 16),
            if (hasResult)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  ElevatedButton(
                    onPressed: _isProcessing ? null : _onSaveAndView,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0B8CFF),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Simpan & Lihat Perkembangan'),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton(
                    onPressed: _isProcessing ? null : _onShareAsPost,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF0B8CFF),
                      side: const BorderSide(color: Color(0xFF0B8CFF), width: 1.5),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text('Bagikan sebagai Postingan'),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstruction() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F3FF),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.info_outline, color: Color(0xFF0B8CFF), size: 32),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analisis Gizi Makanan',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey.shade800,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Foto makanan anak Anda untuk mendapatkan estimasi gizi secara instan.',
                  style: TextStyle(fontSize: 13, height: 1.5, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCameraCard(String timestamp, bool hasResult) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Foto Makanan Anak',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          _cameraPreview(timestamp),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _isCameraReady && !_isProcessing
                      ? _takePicture
                      : null,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Foto Makanan'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF0B8CFF),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              IconButton(
                onPressed: _reloadCamera,
                icon: const Icon(Icons.refresh),
                tooltip: 'Reload kamera',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _cameraPreview(String timestamp) {
    const double previewHeight = 320;
    final borderRadius = BorderRadius.circular(12);
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: borderRadius,
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const SizedBox(
              height: previewHeight,
              child: Center(child: CircularProgressIndicator()),
            );
          }

          if (snapshot.hasError || _initError != null) {
            final message = _initError ?? 'Gagal memulai kamera';
            return SizedBox(height: previewHeight, child: _errorState(message));
          }

          if (_isCameraReady) {
            final aspect = _controller!.value.aspectRatio;
            final double widthForHeight = previewHeight * aspect;
            return ClipRRect(
              borderRadius: borderRadius,
              child: SizedBox(
                height: previewHeight,
                width: double.infinity,
                child: FittedBox(
                  fit: BoxFit.cover,
                  child: SizedBox(
                    width: widthForHeight,
                    height: previewHeight,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        CameraPreview(_controller!),
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: _timestampBadge(timestamp),
                          ),
                        ),
                        if (_photo != null)
                          Container(
                            color: Colors.black.withOpacity(0.35),
                            child: Center(
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: const [
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.white,
                                    size: 48,
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    'Foto tersimpan',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          }

          return const SizedBox(
            height: previewHeight,
            child: Center(
              child: Text(
                'Kamera belum siap',
                style: TextStyle(color: Colors.black54),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _errorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.black45),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.black54),
            ),
          ],
        ),
      ),
    );
  }

  Widget _timestampBadge(String timestamp) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        'Timestamp: $timestamp',
        style: const TextStyle(color: Colors.white, fontSize: 11),
      ),
    );
  }

  Widget _buildResultCard(Map<String, double> result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estimasi Gizi (Simulasi)',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          const Divider(),
          const SizedBox(height: 4),
          ...result.entries.map((e) => _buildNutritionRow(e.key, e.value)),
          const SizedBox(height: 12),
          const Text(
            'Catatan: Deteksi ini adalah simulasi. Diperlukan integrasi dengan model AI untuk hasil yang akurat.',
            style: TextStyle(fontSize: 12, color: Colors.black54, fontStyle: FontStyle.italic),
          ),
        ],
      ),
    );
  }

  Widget _buildNutritionRow(String name, double value) {
    final unit = name.contains('kcal') ? 'kcal' : 'g';
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            name.replaceAll(' (kcal)', ''),
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            '${value.toStringAsFixed(0)} $unit',
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Future<void> _takePicture() async {
    if (!_isCameraReady || _controller == null) return;
    setState(() {
      _isProcessing = true;
    });
    try {
      final photo = await _controller!.takePicture();
      try {
        await _controller?.pausePreview();
        _previewPaused = true;
      } catch (_) {}
      setState(() {
        _photo = photo;
        _capturedAt = DateTime.now();
      });
      await _simulateCapture();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal mengambil foto: $e')));
    } finally {
      if (mounted) {
        setState(() {
          _isProcessing = false;
        });
      }
    }
  }

  void _reloadCamera() {
    setState(() {
      _photo = null;
      _capturedAt = null;
      _results = null;
      _previewPaused = false;
      _initFuture = _initCamera(forceReinit: true);
    });
  }

  Future<void> _simulateCapture() async {
    // Simulasi analisis gizi setelah foto diambil
    await Future.delayed(const Duration(milliseconds: 900));
    if (!mounted) return;
    setState(() {
      _results = {
        'Karbohidrat': 45,
        'Protein': 18,
        'Lemak': 12,
        'Serat': 7,
        'Kalori (kcal)': 320,
      };
    });
  }

  Future<void> _onSaveAndView() async {
    if (_results == null) return;

    try {
      final r = DailyNutritionRecord(
        date: _capturedAt ?? DateTime.now(),
        karbohidrat: (_results!['Karbohidrat'] ?? 0).toDouble(),
        protein: (_results!['Protein'] ?? 0).toDouble(),
        lemak: (_results!['Lemak'] ?? 0).toDouble(),
        serat: (_results!['Serat'] ?? 0).toDouble(),
        kalori: (_results!['Kalori (kcal)'] ?? 0).toDouble(),
      );

      NutritionStore.instance.addRecord(r);

      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data gizi tersimpan')));

      // Navigate to IBI page to show progression
      await Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => const IbiPage()));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Gagal menyimpan data: $e')));
    }
  }

  void _onShareAsPost() {
    if (_photo == null || _results == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ambil foto dan tunggu hasil analisis gizi dulu.'),
        ),
      );
      return;
    }
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => PostPreviewSheet(
        imagePath: _photo!.path,
        nutritionData: _results!,
      ),
    );
  }

  Future<void> _requestPermission() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      throw Exception('Izin kamera ditolak');
    }
  }

  Future<void> _initCamera({bool forceReinit = false}) async {
    try {
      await _requestPermission();
      if (forceReinit) {
        await _controller?.dispose();
        _controller = null;
      }
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw Exception('Tidak ada kamera tersedia');
      }
      _controller = CameraController(
        cameras.first,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await _controller!.initialize();
      _initError = null;
    } catch (e) {
      _initError = e.toString();
    }
    if (mounted) setState(() {});
  }

  String _formatTimestamp(DateTime dt) {
    String two(int v) => v.toString().padLeft(2, '0');
    return '${dt.year}-${two(dt.month)}-${two(dt.day)} ${two(dt.hour)}:${two(dt.minute)}';
  }
}
