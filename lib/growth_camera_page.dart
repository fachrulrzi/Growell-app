import 'dart:async';
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';



class GrowthCameraPage extends StatefulWidget {
  const GrowthCameraPage({super.key});

  @override
  State<GrowthCameraPage> createState() => _GrowthCameraPageState();
}

class _GrowthCameraPageState extends State<GrowthCameraPage>
    with WidgetsBindingObserver {
  CameraController? _controller;
  Future<void>? _initFuture;
  String? _initError;
  _CaptureResult? _lastResult;
  bool _isProcessing = false;

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
    final oldController = _controller;
    _controller = null;
    oldController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) return;

    if (state == AppLifecycleState.inactive) {
      final oldController = _controller;
      _controller = null;
      oldController?.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initFuture = _initCamera(forceReinit: true);
      if (mounted) setState(() {});
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0B8CFF),
        foregroundColor: Colors.white,
        title: const Text('Pemantauan Pertumbuhan'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _tipCard(),
            const SizedBox(height: 14),
            _cameraPreview(),
            const SizedBox(height: 10),
            if (_isProcessing) const LinearProgressIndicator(minHeight: 4),
            if (_lastResult != null) ...[
              const SizedBox(height: 10),
              _resultCard(_lastResult!),
            ],
            const SizedBox(height: 14),
            _instructionList(),
            const SizedBox(height: 20),
            _actionButtons(context),
          ],
        ),
      ),
    );
  }

  Widget _tipCard() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, color: Color(0xFF0B8CFF)),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Tips Pengambilan Foto',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF0B8CFF),
                  ),
                ),
                SizedBox(height: 6),
                Text(
                  'Ambil foto anak Anda sebagai dokumentasi visual. Untuk data yang akurat, selalu gunakan fitur "Input Manual" setelah mengukur tinggi dan berat badan secara langsung.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.black87,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _cameraPreview() {
    const double previewHeight = 320;
    final borderRadius = BorderRadius.circular(14);
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
            return SizedBox(
              height: previewHeight,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      size: 48,
                      color: Colors.black45,
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        message,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.black54),
                      ),
                    ),
                  ],
                ),
              ),
            );
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

  Widget _instructionList() {
    final steps = [
      'Posisikan anak agar terlihat jelas di dalam kamera.',
      'Pastikan pencahayaan cukup untuk hasil foto yang baik.',
      'Jepret foto untuk mendokumentasikan pertumbuhan anak.',
      'Gunakan tombol "Input Manual" untuk memasukkan data tinggi dan berat badan.',
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Langkah Cepat',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 14),
        ),
        const SizedBox(height: 8),
        ...steps.map(
          (s) => Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              children: [
                const Icon(
                  Icons.check_circle,
                  size: 18,
                  color: Color(0xFF0B8CFF),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    s,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                      height: 1.3,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _actionButtons(BuildContext context) {
    Widget icon = const Icon(Icons.photo_camera);
    String label;
    VoidCallback? onPressed;

    if (_isProcessing) {
      label = 'Memproses...';
      onPressed = null;
      icon = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    } else if (_initError != null) {
      label = 'Coba Lagi';
      onPressed = () {
        setState(() {
          _initError = null;
          _initFuture = _initCamera(forceReinit: true);
        });
      };
    } else if (_isCameraReady) {
      label = 'Ambil Foto';
      onPressed = () {
        _capturePhoto(context);
      };
    } else {
      label = 'Kamera Memuat...';
      onPressed = null;
      icon = const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
      );
    }

    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: onPressed,
            icon: icon,
            label: Text(label),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B8CFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              disabledBackgroundColor: const Color(0xFF0B8CFF).withOpacity(0.5),
              disabledForegroundColor: Colors.white.withOpacity(0.8),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _isProcessing
                ? null
                : () {
                    _showManualInputForm(context);
                  },
            icon: const Icon(Icons.edit),
            label: const Text('Input Manual'),
            style: OutlinedButton.styleFrom(
              foregroundColor: const Color(0xFF0B8CFF),
              side: const BorderSide(color: Color(0xFF0B8CFF)),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _initCamera({bool forceReinit = false}) async {
    if (_isCameraReady && !forceReinit) return;

    WidgetsFlutterBinding.ensureInitialized();

    final status = await Permission.camera.request();
    if (!status.isGranted) {
      if (mounted) {
        setState(() {
          _initError = 'Izin kamera ditolak';
        });
      }
      throw 'Izin kamera ditolak';
    }

    final cameras = await availableCameras();
    if (cameras.isEmpty) {
      if (mounted) {
        setState(() {
          _initError = 'Kamera tidak ditemukan';
        });
      }
      throw 'Kamera tidak ditemukan';
    }

    _controller?.dispose();
    _controller = null;
    _controller = CameraController(
      cameras.first,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    try {
      await _controller!.initialize().timeout(const Duration(seconds: 10));
      if (!mounted) return;
      setState(() {
        _initError = null;
      });
    } on TimeoutException {
      if (mounted) {
        setState(() {
          _initError = 'Inisialisasi kamera timeout';
        });
      }
      rethrow;
    } on CameraException catch (e) {
      if (mounted) {
        setState(() {
          _initError = 'Kamera error: ${e.code}';
        });
      }
      rethrow;
    } catch (e) {
      if (mounted) {
        setState(() {
          _initError = 'Gagal inisialisasi kamera';
        });
      }
      rethrow;
    }
  }

  Future<void> _capturePhoto(BuildContext context) async {
    if (_isProcessing) return;

    // Pastikan inisialisasi selesai sebelum ambil foto
    try {
      await _initFuture;
    } catch (_) {}

    final controller = _controller;
    if (controller == null || !controller.value.isInitialized) {
      _showSnack(context, 'Kamera belum siap');
      return;
    }

    if (mounted) {
      setState(() {
        _isProcessing = true;
        _lastResult = null; // clear old result before processing
      });
    }

    XFile? file;
    try {
      file = await controller.takePicture();
    } catch (e) {
      if (mounted) {
        _showSnack(context, 'Gagal mengambil foto: $e');
      }
      if (mounted) {
        setState(() => _isProcessing = false);
      }
      return;
    }

    if (file == null) {
      if (mounted) {
        _showSnack(context, 'Foto tidak tersedia');
        setState(() => _isProcessing = false);
      }
      return;
    }

    try {
      await _processCapturedImage(file.path);
      if (mounted) {
        _showSnack(context, 'Foto berhasil diambil');
      }
    } catch (e) {
      if (mounted) {
        _showSnack(context, 'Gagal memproses foto: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessing = false);
      }
    }
  }

  Future<void> _showManualInputForm(BuildContext context) async {
    final heightController = TextEditingController();
    final weightController = TextEditingController();
    final notesController = TextEditingController();
    final formKey = GlobalKey<FormState>();
    DateTime selectedDate = DateTime.now();
    final dateController = TextEditingController(
      text: _formatDate(selectedDate),
    );

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 16,
            right: 16,
            top: 16,
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          ),
          child: StatefulBuilder(
            builder: (ctx, setState) {
              return Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Input Manual Pertumbuhan',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: heightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Tinggi Badan (cm)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Isi tinggi badan';
                        final value = double.tryParse(v);
                        if (value == null || value <= 0)
                          return 'Masukkan angka yang valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: weightController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Berat Badan (kg)',
                        border: OutlineInputBorder(),
                      ),
                      validator: (v) {
                        if (v == null || v.trim().isEmpty)
                          return 'Isi berat badan';
                        final value = double.tryParse(v);
                        if (value == null || value <= 0)
                          return 'Masukkan angka yang valid';
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: dateController,
                      readOnly: true,
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Pengukuran',
                        border: OutlineInputBorder(),
                        suffixIcon: Icon(Icons.calendar_today_rounded),
                      ),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: ctx,
                          initialDate: selectedDate,
                          firstDate: DateTime(2015),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() {
                            selectedDate = picked;
                            dateController.text = _formatDate(picked);
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'Catatan (opsional)',
                        border: OutlineInputBorder(),
                        alignLabelWithHint: true,
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () {
                          if (formKey.currentState?.validate() ?? false) {
                            Navigator.pop(ctx);
                            _showSnack(
                              context,
                              'Tersimpan: Tinggi ${heightController.text} cm, Berat ${weightController.text} kg (${_formatDate(selectedDate)})',
                            );
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF0B8CFF),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text('Simpan'),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );

    heightController.dispose();
    weightController.dispose();
    notesController.dispose();
    dateController.dispose();
  }

  String _formatDate(DateTime date) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'Mei',
      'Jun',
      'Jul',
      'Agu',
      'Sep',
      'Okt',
      'Nov',
      'Des',
    ];
    return '${date.day.toString().padLeft(2, '0')} ${months[date.month - 1]} ${date.year}';
  }

  void _showSnack(BuildContext context, String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  Future<void> _processCapturedImage(String path) async {
    // Simulate processing and generate dummy data
    await Future.delayed(const Duration(seconds: 1));

    final dummyHeight = 70.0 + (DateTime.now().second % 10);
    final dummyWeight = 8.0 + (DateTime.now().second % 5);

    setState(() {
      _lastResult = _CaptureResult(
        filePath: path,
        heightCm: dummyHeight,
        weightKg: dummyWeight,
        timestamp: DateTime.now(),
      );
    });
  }

  Widget _resultCard(_CaptureResult result) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Foto Telah Diambil',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
              ),
              Text(
                _formatDate(result.timestamp),
                style: const TextStyle(fontSize: 12, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(result.filePath),
                  width: 90,
                  height: 120,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'DATA PENGUKURAN (DUMMY)',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                        color: Colors.black54,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.height, color: Colors.blue.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${result.heightCm.toStringAsFixed(1)} cm',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Icon(Icons.monitor_weight_outlined,
                            color: Colors.green.shade700, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          '${result.weightKg.toStringAsFixed(1)} kg',
                          style: const TextStyle(
                              fontSize: 15, fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey.shade100,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Ini adalah data dummy. Gunakan "Input Manual" untuk data akurat.',
              textAlign: TextAlign.center,
              style:
                  TextStyle(fontSize: 12, color: Colors.black87, height: 1.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _CaptureResult {
  final String filePath;
  final double heightCm;
  final double weightKg;
  final DateTime timestamp;

  _CaptureResult({
    required this.filePath,
    required this.heightCm,
    required this.weightKg,
    required this.timestamp,
  });
}
