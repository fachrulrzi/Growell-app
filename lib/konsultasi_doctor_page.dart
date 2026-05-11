import 'package:flutter/material.dart';
import 'call_doctor_page.dart';
import 'video_call_doctor_page.dart';

class KonsultasiDoctorPage extends StatefulWidget {
  final String doctorName;
  final String doctorSpecialist;
  final String? doctorPhoto;
  const KonsultasiDoctorPage({
    Key? key,
    required this.doctorName,
    required this.doctorSpecialist,
    this.doctorPhoto,
  }) : super(key: key);

  @override
  State<KonsultasiDoctorPage> createState() => _KonsultasiDoctorPageState();
}

class _KonsultasiDoctorPageState extends State<KonsultasiDoctorPage> {
  final List<ChatMessage> _messages = [
    ChatMessage(text: 'Halo, ada yang bisa saya bantu?', isBot: true),
    ChatMessage(text: 'Halo dok, saya ingin konsultasi.', isBot: false),
    ChatMessage(
      text: 'Silakan, keluhan apa yang ingin disampaikan?',
      isBot: true,
    ),
  ];
  final TextEditingController _controller = TextEditingController();

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isEmpty) return;
    setState(() {
      _messages.add(ChatMessage(text: text, isBot: false));
      _controller.clear();
      // Simulasi balasan bot
      Future.delayed(const Duration(milliseconds: 800), () {
        setState(() {
          _messages.add(
            ChatMessage(
              text: 'Pesan Anda sudah diterima, dokter akan segera membalas.',
              isBot: true,
            ),
          );
        });
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(80),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Back button
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.of(context).maybePop(),
                    padding: const EdgeInsets.all(6),
                    constraints: const BoxConstraints(),
                  ),
                  const SizedBox(width: 6),
                  // Avatar
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white,
                    child: const Icon(
                      Icons.person,
                      color: Colors.blue,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Name + specialist
                  Expanded(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.doctorName,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 17,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          widget.doctorSpecialist,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Action buttons
                  Container(
                    margin: const EdgeInsets.only(left: 8, right: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const CallDoctorPage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.phone,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    margin: const EdgeInsets.only(right: 4),
                    decoration: BoxDecoration(
                      color: Colors.white24,
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const VideoCallDoctorPage(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.videocam,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: const Color(0xFFF7F9FB),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 18,
                ),
                itemCount: _messages.length,
                itemBuilder: (context, index) {
                  final msg = _messages[index];
                  return Align(
                    alignment: msg.isBot
                        ? Alignment.centerLeft
                        : Alignment.centerRight,
                    child: Container(
                      margin: EdgeInsets.only(
                        top: 4,
                        bottom: 4,
                        left: msg.isBot ? 0 : 40,
                        right: msg.isBot ? 40 : 0,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: msg.isBot ? Colors.white : Colors.blue[400],
                        borderRadius: BorderRadius.only(
                          topLeft: const Radius.circular(18),
                          topRight: const Radius.circular(18),
                          bottomLeft: Radius.circular(msg.isBot ? 4 : 18),
                          bottomRight: Radius.circular(msg.isBot ? 18 : 4),
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.06),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Text(
                        msg.text,
                        style: TextStyle(
                          color: msg.isBot ? Colors.black87 : Colors.white,
                          fontSize: 15.5,
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 18),
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: const Color(0xFFF1F3F6),
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: TextField(
                        controller: _controller,
                        decoration: const InputDecoration(
                          hintText: 'Ketik pesan...',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 12,
                          ),
                        ),
                        onSubmitted: (_) => _sendMessage(),
                        minLines: 1,
                        maxLines: 4,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.blue.withOpacity(0.15),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.send, color: Colors.white),
                      onPressed: _sendMessage,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isBot;
  ChatMessage({required this.text, required this.isBot});
}
