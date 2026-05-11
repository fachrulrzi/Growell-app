import 'package:flutter/material.dart';

class CallDoctorPage extends StatefulWidget {
  const CallDoctorPage({Key? key}) : super(key: key);

  @override
  State<CallDoctorPage> createState() => _CallDoctorPageState();
}

class _CallDoctorPageState extends State<CallDoctorPage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
    _animation = Tween<double>(begin: 0.7, end: 1.1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[800],
      appBar: AppBar(
        backgroundColor: Colors.blue[800],
        elevation: 0,
        title: const Text('Panggilan Suara'),
        centerTitle: true,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _animation,
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Colors.white,
                child: Icon(Icons.person, size: 80, color: Colors.blue[800]),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Dr. Irfan Nufis M, Sp.A',
              style: TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Spesialis Anak',
              style: TextStyle(color: Colors.white70, fontSize: 17),
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.wifi_calling_3, color: Colors.white70, size: 18),
                SizedBox(width: 6),
                Text('Sedang memanggil...', style: TextStyle(color: Colors.white70, fontSize: 16)),
              ],
            ),
            const SizedBox(height: 38),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _circleIcon(Icons.volume_up),
                const SizedBox(width: 28),
                _circleIcon(Icons.mic),
                const SizedBox(width: 28),
                GestureDetector(
                  onTap: () => Navigator.of(context).pop(),
                  child: _circleIcon(Icons.call_end, color: Colors.redAccent, isEnd: true),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  static Widget _circleIcon(IconData icon, {Color color = Colors.white, bool isEnd = false}) {
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
        child: Icon(icon, color: color == Colors.white ? Colors.blue[800] : Colors.white, size: 32),
      ),
    );
  }
}
