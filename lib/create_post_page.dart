import 'dart:io';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

class CreatePostPage extends StatelessWidget {
  final String imagePath;
  final Map<String, double> nutritionData;

  const CreatePostPage({
    super.key,
    required this.imagePath,
    required this.nutritionData,
  });

  @override
  Widget build(BuildContext context) {
    final nutritionText = nutritionData.entries
        .map((e) => '- ${e.key}: ${e.value.toStringAsFixed(0)} g')
        .join('\n');
    final postText =
        'Lihat hasil deteksi gizi makanan anakku!\n\nEstimasi gizi:\n$nutritionText\n\n#GrowellApp #GiziAnak #NutrisiAnak';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Buat Postingan'),
        backgroundColor: const Color(0xFF0B8CFF),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Pratinjau Postingan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(
                children: [
                  Image.file(
                    File(imagePath),
                    fit: BoxFit.cover,
                    height: 300,
                    width: double.infinity,
                  ),
                  Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text(
                      postText,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Share.shareXFiles(
                  [XFile(imagePath)],
                  text: postText,
                );
              },
              icon: const Icon(Icons.share),
              label: const Text('Bagikan ke Media Sosial'),
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
      ),
    );
  }
}
