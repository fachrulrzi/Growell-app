import 'dart:io';
import 'package:flutter/material.dart';
import 'package:growell/post_card_widget.dart';
import 'package:growell/widget_to_image_converter.dart';
import 'package:share_plus/share_plus.dart';

class PostPreviewSheet extends StatefulWidget {
  final String imagePath;
  final Map<String, double> nutritionData;

  const PostPreviewSheet({
    super.key,
    required this.imagePath,
    required this.nutritionData,
  });

  @override
  State<PostPreviewSheet> createState() => _PostPreviewSheetState();
}

class _PostPreviewSheetState extends State<PostPreviewSheet> {
  final GlobalKey _cardKey = GlobalKey();
  bool _isGenerating = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Pratinjau Postingan',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          // This is the widget that will be converted to an image
          RepaintBoundary(
            key: _cardKey,
            child: PostCardWidget(
              imagePath: widget.imagePath,
              nutritionData: widget.nutritionData,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _isGenerating
                ? null
                : () async {
                    setState(() {
                      _isGenerating = true;
                    });
                    try {
                      final imagePath =
                          await WidgetToImageConverter.captureWidget(_cardKey);
                      if (imagePath != null) {
                        await Share.shareXFiles([XFile(imagePath)]);
                      } else {
                        throw Exception('Gagal membuat file gambar.');
                      }
                    } catch (e) {
                      if (!mounted) return;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Gagal membuat postingan: $e')),
                      );
                    } finally {
                      if (mounted) {
                        setState(() {
                          _isGenerating = false;
                        });
                      }
                    }
                  },
            icon: _isGenerating
                ? const SizedBox.shrink()
                : const Icon(Icons.share),
            label: _isGenerating
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 3,
                    ),
                  )
                : const Text('Bagikan ke Media Sosial'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0B8CFF),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
