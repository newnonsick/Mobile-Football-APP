import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class CamearaPage extends StatefulWidget {
  final List<CameraDescription> cameras;
  final Uint8List image;

  const CamearaPage({Key? key, required this.cameras, required this.image})
      : super(key: key);

  @override
  State<CamearaPage> createState() => _CamearaPageState();
}

class _CamearaPageState extends State<CamearaPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      // Get a specific camera from the list of available cameras.
      widget.cameras.first,
      // Define the resolution to use.
      ResolutionPreset.medium,
    );

    // Next, initialize the controller. This returns a Future.
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose of the controller when the widget is disposed.
    _controller.dispose();
    super.dispose();
  }

  Future<void> takePicture() async {
    if (!_controller.value.isInitialized) {
      return;
    }

    // Ensure that the camera is initialized.
    await _initializeControllerFuture;

    // Construct the path where the image should be saved using the path_provider package.
    final Directory extDir = await getApplicationDocumentsDirectory();
    final String dirPath = '${extDir.path}/images';
    await Directory(dirPath).create(recursive: true);
    final String filePath = '$dirPath/${DateTime.now()}.png';

    // Attempt to take a picture and log where it's been saved.
    XFile pictureFile = await _controller.takePicture();

    // Load the captured image as a File.
    File file = File(pictureFile.path);

    // Combine the captured image and the image passed from the constructor.
    ui.Image capturedImage = await loadImage(file);
    ui.Image overlayImage = await loadImage(widget.image);

    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder);

    final cameraSize =
        Size(capturedImage.width.toDouble(), capturedImage.height.toDouble());
    final overlaySize =
        Size(overlayImage.width.toDouble(), overlayImage.height.toDouble());

    canvas.drawImage(capturedImage, Offset.zero, Paint());

    final scale = cameraSize.shortestSide / overlaySize.shortestSide;
    final fittedSize = overlaySize * scale;
    final fittedOffset = Offset((cameraSize.width - fittedSize.width) / 2,
        (cameraSize.height - fittedSize.height) / 2);
    canvas.drawImageRect(
        overlayImage,
        Rect.fromLTRB(0, 0, overlaySize.width, overlaySize.height),
        Rect.fromLTWH(fittedOffset.dx, fittedOffset.dy, fittedSize.width,
            fittedSize.height),
        Paint());

    final combinedImage = await recorder
        .endRecording()
        .toImage(cameraSize.width.toInt(), cameraSize.height.toInt());
    final byteData =
        await combinedImage.toByteData(format: ui.ImageByteFormat.png);

    // Save the combined image to the filesystem.
    final combinedFilePath = '$dirPath/${DateTime.now()}_combined.png';
    final combinedFile = File(combinedFilePath);
    await combinedFile.writeAsBytes(byteData!.buffer.asUint8List());

    // Display the path of the saved image to the console.
    print('Saved combined image to $combinedFilePath');
  }

  Future<ui.Image> loadImage(dynamic source) async {
    final Completer<ui.Image> completer = Completer();
    ui.Image? img;
    if (source is File) {
      final Uint8List bytes = await source.readAsBytes();
      img = await decodeImageFromList(bytes);
    } else if (source is Uint8List) {
      img = await decodeImageFromList(source);
    }
    if (img != null) {
      completer.complete(img);
    }
    return completer.future;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Camera'),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: FutureBuilder<void>(
              future: _initializeControllerFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  // If the Future is complete, display the preview.
                  return CameraPreview(_controller);
                } else {
                  // Otherwise, display a loading indicator.
                  return const Center(child: CircularProgressIndicator());
                }
              },
            ),
          ),
          Positioned(
            bottom: 16,
            left: 16,
            child: ElevatedButton(
              onPressed: takePicture,
              child: const Icon(Icons.camera),
            ),
          ),
        ],
      ),
    );
  }
}
