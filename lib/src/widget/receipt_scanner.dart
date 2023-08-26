import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';
import 'package:path_provider/path_provider.dart';

class ReceiptScanner extends StatefulWidget {
  const ReceiptScanner({Key? key}) : super(key: key);

  @override
  State<ReceiptScanner> createState() => _ReceiptScannerState();
}

class _ReceiptScannerState extends State<ReceiptScanner> {

  File? _imageFile;
  String?  _text;

  CameraController? _controller;

  @override
  void initState() {
    initCamera();
    super.initState();
  }


  initCamera() async {
    final cameras = await availableCameras();
    _controller = CameraController(
      cameras[0],
      ResolutionPreset.ultraHigh,
    );
    await _controller?.initialize();
    _controller!.setFlashMode(FlashMode.off);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const Text('Receipt Scanner'),
          TextButton(
            onPressed: () {
              setState(() {
                _imageFile = null;
              });
            },
            child: const Text('Try'),
          ),
          if(_controller != null &&  _controller!.value.isInitialized) ...[
            SizedBox(height: 500,
              child: AspectRatio(
                aspectRatio: _controller!.value.aspectRatio,
                child: CameraPreview(_controller!),
              ),
            ),
            TextButton(
              onPressed: () async {
                  print('start');
                  print('take picture');
                  final image = await _controller!.takePicture();
                  print(image);
                  print('save picture');
                  final Directory directory = await getApplicationDocumentsDirectory();
                  final DateTime now = DateTime.now();
                  final path = '${directory.path}/${now.year}-${now.month}-${now.day}.${image.mimeType?.split('/').last ?? 'jpg'}';

                  await image.saveTo(path);
                  print(' save $path ${image.path}');
                  final inputImage = InputImage.fromFilePath(image.path);
                  print(inputImage.filePath);
                  final textRecognizer = TextRecognizer();
                  textRecognizer.processImage(inputImage).then((value) {
                    _text = value.blocks.map((e) => e.lines.map((e) => e.text).join("\n")).join('\n\n');
                    setState(() {});
                  });
                  setState(() {
                    _imageFile = File(image.path);
                  });


              },
              child: const Text('Take Picture'),
            ),
          ],
          if (_imageFile != null) Column(
            children: [
              Image.file(_imageFile!),
              Text(_text ?? 'No text'),
            ],
          ),
        ],
      ),
    );
  }
}
