import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';

enum MessageType { text, image }

class ChatMessage extends StatelessWidget {
  const ChatMessage({
    this.text,
    this.imagePath,
    required this.isUser,
    required this.type,
    required Key key,
  }) : super(key: key);

  final String? text;
  final String? imagePath;
  final bool isUser;
  final MessageType type;

  @override
  Widget build(BuildContext context) {
    final isImage = type == MessageType.image;

    final maxWidth = MediaQuery.of(context).size.width * 0.72;
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        mainAxisAlignment: isUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isUser) ...[
            const CircleAvatar(
              backgroundColor: Color(0xFF0B8CFF),
              child: Text('A', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxWidth),
            child: Container(
              padding: const EdgeInsets.all(6.0),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF0B8CFF) : Colors.white,
                borderRadius: BorderRadius.circular(16.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12.0),
                child: isImage
                    ? GestureDetector(
                        onTap: () {
                          showDialog(
                            context: context,
                            builder: (_) => Dialog(
                              backgroundColor: Colors.transparent,
                              child: InteractiveViewer(
                                child: Image.file(
                                  File(imagePath!),
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    debugPrint('Error loading image: $error');
                                    return Container(
                                      width: 240,
                                      height: 240,
                                      color: Colors.grey.shade200,
                                      child: const Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.error_outline,
                                            color: Colors.red,
                                            size: 40,
                                          ),
                                          SizedBox(height: 8),
                                          Text(
                                            'Gagal memuat gambar',
                                            textAlign: TextAlign.center,
                                          ),
                                        ],
                                      ),
                                    );
                                  },
                                ),
                              ),
                            ),
                          );
                        },
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(
                            maxWidth: 180,
                            maxHeight: 180,
                          ),
                          child: Image.file(
                            File(imagePath!),
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              debugPrint('Error loading image: $error');
                              return Container(
                                width: 120,
                                height: 120,
                                color: Colors.grey.shade200,
                                child: const Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: Colors.red,
                                      size: 40,
                                    ),
                                    SizedBox(height: 8),
                                    Text(
                                      'Gagal memuat gambar',
                                      textAlign: TextAlign.center,
                                    ),
                                  ],
                                ),
                              );
                            },
                          ),
                        ),
                      )
                    : Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12.0,
                          vertical: 10.0,
                        ),
                        child: Text(
                          text!,
                          style: TextStyle(
                            color: isUser ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                      ),
              ),
            ),
          ),
          if (isUser) const SizedBox(width: 8),
        ],
      ),
    );
  }
}

class TypingIndicator extends StatelessWidget {
  const TypingIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 10.0),
      child: Row(
        children: [
          const CircleAvatar(
            backgroundColor: Color(0xFF0B8CFF),
            child: Text('A', style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 15.0,
              vertical: 10.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Text('Asisten sedang mengetik...'),
          ),
        ],
      ),
    );
  }
}

class NutritionAssistantPage extends StatefulWidget {
  const NutritionAssistantPage({super.key});

  @override
  State<NutritionAssistantPage> createState() => _NutritionAssistantPageState();
}

class _NutritionAssistantPageState extends State<NutritionAssistantPage> {
  final TextEditingController _textController = TextEditingController();
  final List<ChatMessage> _messages = [];
  final ImagePicker _picker = ImagePicker();
  bool _isBotTyping = false;

  @override
  void initState() {
    super.initState();
    _messages.insert(
      0,
      ChatMessage(
        key: ValueKey(DateTime.now().millisecondsSinceEpoch),
        text:
            'Halo! Ada yang bisa saya bantu terkait gizi? Anda juga bisa mengirim foto makanan.',
        isUser: false,
        type: MessageType.text,
      ),
    );
  }

  void _addBotResponse(ChatMessage response) {
    if (!mounted) return;
    setState(() {
      _isBotTyping = false;
      _messages.insert(0, response);
    });
  }

  void _handleSubmitted(String text) {
    if (text.isEmpty) return;
    _textController.clear();
    final message = ChatMessage(
      key: ValueKey(DateTime.now().millisecondsSinceEpoch),
      text: text,
      isUser: true,
      type: MessageType.text,
    );
    setState(() {
      _messages.insert(0, message);
      _isBotTyping = true;
    });

    Future.delayed(const Duration(milliseconds: 1500), () {
      final response = ChatMessage(
        key: ValueKey(DateTime.now().millisecondsSinceEpoch),
        text:
            'Baik, saya akan coba analisis pertanyaan Anda. Mohon tunggu sebentar ya.',
        isUser: false,
        type: MessageType.text,
      );
      _addBotResponse(response);
    });
  }

  Future<void> _sendImageMessage(XFile image) async {
    final message = ChatMessage(
      key: ValueKey(image.path),
      imagePath: image.path,
      isUser: true,
      type: MessageType.image,
    );
    setState(() {
      _messages.insert(0, message);
      _isBotTyping = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      final response = ChatMessage(
        key: ValueKey(DateTime.now().millisecondsSinceEpoch),
        text:
            'Terima kasih! Dari gambar yang Anda kirim, sepertinya ini adalah makanan yang lezat. Saya akan coba menganalisis kandungan gizinya.',
        isUser: false,
        type: MessageType.text,
      );
      _addBotResponse(response);
    });
  }

  Future<void> _handleImageSelection() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80,
      );
      if (image != null) {
        await _sendImageMessage(image);
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar dari galeri: ${e.message}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  Future<void> _handleCameraCapture() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 80,
      );
      if (image != null) {
        await _sendImageMessage(image);
      }
    } on PlatformException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengambil gambar dari kamera: ${e.message}'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Terjadi kesalahan: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FB),
      appBar: AppBar(
        iconTheme: const IconThemeData(color: Colors.white),
        backgroundColor: Colors.blue,
        elevation: 4.0,
        shadowColor: const Color(0x11000000),
        title: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
            Icon(Icons.medical_services_outlined, color: Colors.white),
            SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Asisten Gizi',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(
                horizontal: 10.0,
                vertical: 8.0,
              ),
              reverse: true,
              itemCount: _messages.length + (_isBotTyping ? 1 : 0),
              itemBuilder: (_, int index) {
                if (_isBotTyping && index == 0) {
                  return const TypingIndicator();
                }
                final messageIndex = _isBotTyping ? index - 1 : index;
                return _messages[messageIndex];
              },
            ),
          ),
          const Divider(height: 1.0),
          _buildTextComposer(),
        ],
      ),
    );
  }

  Widget _buildTextComposer() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: IconTheme(
        data: const IconThemeData(color: Colors.blue),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _handleImageSelection,
              tooltip: 'Pilih dari galeri',
            ),
            IconButton(
              icon: const Icon(Icons.camera_alt),
              onPressed: _handleCameraCapture,
              tooltip: 'Ambil foto dari kamera',
            ),
            Flexible(
              child: TextField(
                controller: _textController,
                onSubmitted: _handleSubmitted,
                decoration: InputDecoration(
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 10.0,
                    horizontal: 20.0,
                  ),
                  hintText: 'Tanyakan sesuatu...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30.0),
                    borderSide: BorderSide.none,
                  ),
                  filled: true,
                  fillColor: const Color(0xFFF5F7FB),
                ),
              ),
            ),
            const SizedBox(width: 8.0),
            Container(
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.12),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: IconButton(
                icon: const Icon(Icons.send, color: Colors.white),
                onPressed: () => _handleSubmitted(_textController.text),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
