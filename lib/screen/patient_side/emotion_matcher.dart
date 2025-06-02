import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class EmotionMatcher extends StatefulWidget {
  const EmotionMatcher({super.key});

  @override
  State<EmotionMatcher> createState() => _EmotionMatcherState();
}

class _EmotionMatcherState extends State<EmotionMatcher> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  final List<String> emojis = ['😊', '😢', '😠', '😮'];
  int currentEmojiIndex = 0;

  @override
  void initState() {
    super.initState();
    _initCamera();
  }

  Future<void> _initCamera() async {
    final cameras = await availableCameras();
    final frontCam = cameras.firstWhere((cam) => cam.lensDirection == CameraLensDirection.front);

    _cameraController = CameraController(frontCam, ResolutionPreset.medium);
    await _cameraController!.initialize();

    if (mounted) {
      setState(() {
        _isCameraInitialized = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  void _nextEmoji() {
    setState(() {
      currentEmojiIndex = (currentEmojiIndex + 1) % emojis.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _isCameraInitialized
          ? Center(
            child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
            const SizedBox(height: 20),
            Text(
              'Match this emoji!',
              style: TextStyle(fontSize: 24),
            ),
            Text(
              emojis[currentEmojiIndex],
              style: const TextStyle(fontSize: 80),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: Center(
                child: ClipOval(
                  child: SizedBox(
                    width: 250, // Adjust size as needed
                    height: 250,
                    child: CameraPreview(_cameraController!),
                  ),
                ),
              ),

            ),
            ElevatedButton(
              onPressed: _nextEmoji,
              child: const Text("Next Emoji"),
            ),
            const SizedBox(height: 20),
                    ],
                  ),
          )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
