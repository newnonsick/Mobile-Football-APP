import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
// import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path/path.dart' as path;

class WidgetToImage {
  static Future<Uint8List> takeScreenshot(Widget child) async {
    final screenshotController = ScreenshotController();
    return await screenshotController.captureFromWidget(Material(child: child),
        pixelRatio: 4.0);
  }

  static Future<bool> saveImage(Uint8List byte) async {
    try {
      // Get storage directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory =
            await getExternalStorageDirectory(); // Use external storage for Android
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      if (directory == null) return false;

      // Create file path
      String fileName =
          'LiveScore_${DateTime.now().millisecondsSinceEpoch}.png';
      String filePath = path.join(directory.path, fileName);

      // Write file
      File file = File(filePath);
      await file.writeAsBytes(byte);

      print("Image saved at: $filePath");
      return true;
    } catch (e) {
      print("Error saving image: $e");
      return false;
    }
  }

  static Future<bool> shareImage(Uint8List byte) async {
    final directory = await getTemporaryDirectory();
    final imageFile = File('${directory.path}/image.png');
    await imageFile.writeAsBytes(byte, flush: true);
    ShareResult result = await Share.shareXFiles([XFile(imageFile.path)]);
    return result.status == ShareResultStatus.success;
  }
}
