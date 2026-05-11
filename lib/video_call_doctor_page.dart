import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class VideoCallDoctorPage extends StatefulWidget {
  final String doctorName;
  final String doctorSpecialist;
  final String? doctorPhoto;
  const VideoCallDoctorPage({
    Key? key,
    this.doctorName = 'Dr. Irfan Nufis M, Sp.A',
    this.doctorSpecialist = 'Spesialis Anak',
    this.doctorPhoto,
  }) : super(key: key);

  @override
  State<VideoCallDoctorPage> createState() => _VideoCallDoctorPageState();
}

class _VideoCallDoctorPageState extends State<VideoCallDoctorPage> {
  CameraController? _controller;
  List<CameraDescription>? _cameras;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    _cameras = await availableCameras();
    if (_cameras != null && _cameras!.isNotEmpty) {
      // Use front camera if available, else fallback to first camera
      final frontCamera = _cameras!.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.front,
        orElse: () => _cameras!.first,
      );
      _controller = CameraController(frontCamera, ResolutionPreset.medium);
      await _controller!.initialize();
    }
    setState(() {
      _loading = false;
    });
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                // Background: avatar dokter (simulasi video lawan)
                Positioned.fill(
                  child: Container(
                    color: Colors.black,
                    child:
                        widget.doctorPhoto != null &&
                            widget.doctorPhoto!.isNotEmpty
                        ? Image.network(widget.doctorPhoto!, fit: BoxFit.cover)
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircleAvatar(
                                radius: 64,
                                backgroundColor: Colors.blue[100],
                                child: Icon(
                                  Icons.person,
                                  color: Colors.blue,
                                  size: 64,
                                ),
                              ),
                              const SizedBox(height: 18),
                              Text(
                                widget.doctorName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                widget.doctorSpecialist,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 15,
                                ),
                              ),
                              const SizedBox(height: 16),
                              const Text(
                                'Sedang memanggil...',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // Kamera user (mini preview, pojok kanan atas)
                if (_controller != null && _controller!.value.isInitialized)
                  Positioned(
                    top: 32,
                    right: 18,
                    child: Container(
                      width: 110,
                      height: 160,
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.white, width: 2),
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.black,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: CameraPreview(_controller!),
                      ),
                    ),
                  ),

                // Kontrol bawah
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 48,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _circleIcon(Icons.volume_up),
                      const SizedBox(width: 32),
                      _circleIcon(Icons.videocam),
                      const SizedBox(width: 32),
                      _circleIcon(Icons.mic),
                      const SizedBox(width: 32),
                      GestureDetector(
                        onTap: () => Navigator.of(context).pop(),
                        child: _circleIcon(
                          Icons.call_end,
                          color: Colors.redAccent,
                          isEnd: true,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _circleIcon(
    IconData icon, {
    Color color = Colors.white,
    bool isEnd = false,
  }) {
    return Container(
      decoration: isEnd
          ? BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.redAccent.withOpacity(0.3),
                  blurRadius: 16,
                  spreadRadius: 2,
                  offset: const Offset(0, 4),
                ),
              ],
            )
          : null,
      child: CircleAvatar(
        radius: 32,
        backgroundColor: color,
        child: Icon(
          icon,
          color: color == Colors.white ? Colors.blue[800] : Colors.white,
          size: 32,
        ),
      ),
    );
  }
}
