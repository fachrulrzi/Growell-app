import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';

class WidgetToImageConverter {
  static Future<String?> captureWidget(GlobalKey key) async {
    try {
      // Find the RenderRepaintBoundary from the GlobalKey
      final boundary =
          key.currentContext?.findRenderObject() as RenderRepaintBoundary?;

      if (boundary == null) {
        throw Exception('Could not find render boundary.');
      }

      // Render the boundary to an image
      final image = await boundary.toImage(pixelRatio: 3.0); // Higher pixel ratio for better quality

      // Convert the image to byte data in PNG format
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      if (byteData == null) {
        throw Exception('Could not get byte data from image.');
      }
      final pngBytes = byteData.buffer.asUint8List();

      // Save the byte data to a temporary file
      final tempDir = await getTemporaryDirectory();
      final tempPath =
          '${tempDir.path}/growell_post_${DateTime.now().millisecondsSinceEpoch}.png';
      final file = File(tempPath);
      await file.writeAsBytes(pngBytes);

      return tempPath;
    } catch (e) {
      // ignore: avoid_print
      print('Error capturing widget: $e');
      return null;
    }
  }
}
