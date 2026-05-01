import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:typed_data';
import 'package:image/image.dart' as img;
import '../theme/app_theme.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  File? _selectedImage;
  Uint8List? _imageBytes;
  int _detectedMarks = 0;
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        _imageBytes = await pickedFile.readAsBytes();
        setState(() {
          _selectedImage = File(pickedFile.path);
          _detectedMarks = 0;
        });
        _analyzeImage();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: kAccent3),
        );
      }
    }
  }

  void _analyzeImage() async {
    if (_imageBytes == null) return;
    setState(() => _isAnalyzing = true);
    try {
      final image = img.decodeImage(_imageBytes!);
      if (image == null) return;
      int markCount = 0;
      for (int y = 0; y < image.height; y++) {
        for (int x = 0; x < image.width; x++) {
          final pixel = image.getPixelSafe(x, y);
          final gray =
              (pixel.r.toInt() + pixel.g.toInt() + pixel.b.toInt()) ~/ 3;
          if (gray < 200) markCount++;
        }
      }
      final result =
          (markCount / (image.width * image.height / 100)).round().clamp(0, 100);
      if (mounted) setState(() => _detectedMarks = result);
    } catch (e) {
      debugPrint('Error analyzing image: $e');
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Color get _scoreColor {
    if (_detectedMarks >= 75) return const Color(0xFF43E97B);
    if (_detectedMarks >= 50) return const Color(0xFFF7971E);
    return kAccent3;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: GlassCard(
                        padding: const EdgeInsets.all(10),
                        borderRadius: 12,
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: kTextPrimary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('Test Paper Scanner',
                        style: TextStyle(
                            color: kTextPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 24),

                // Image preview
                GlassCard(
                  padding: EdgeInsets.zero,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: _selectedImage != null
                        ? Image.file(_selectedImage!,
                            height: 280,
                            width: double.infinity,
                            fit: BoxFit.cover)
                        : Container(
                            height: 280,
                            width: double.infinity,
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                colors: [kGlass, Color(0x0DFFFFFF)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
                                Icon(Icons.document_scanner_rounded,
                                    size: 64, color: kTextSecondary),
                                SizedBox(height: 16),
                                Text('No image selected',
                                    style: TextStyle(
                                        color: kTextSecondary, fontSize: 15)),
                                SizedBox(height: 8),
                                Text('Take a photo or pick from gallery',
                                    style: TextStyle(
                                        color: kTextSecondary, fontSize: 12)),
                              ],
                            ),
                          ),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                Row(
                  children: [
                    Expanded(
                      child: GradientButton(
                        onPressed: () => _pickImage(ImageSource.camera),
                        colors: const [kAccent1, kAccent2],
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.camera_alt_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Camera',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        onPressed: () => _pickImage(ImageSource.gallery),
                        colors: const [kAccent3, kAccent1],
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.photo_library_rounded,
                                color: Colors.white, size: 18),
                            SizedBox(width: 8),
                            Text('Gallery',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

                if (_selectedImage != null) ...[
                  const SizedBox(height: 24),
                  GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Analysis Results',
                            style: TextStyle(
                                color: kTextPrimary,
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 20),
                        if (_isAnalyzing)
                          const Center(
                            child: CircularProgressIndicator(color: kAccent1),
                          )
                        else ...[
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Detected Marks',
                                  style: TextStyle(color: kTextSecondary)),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [_scoreColor, kAccent2],
                                ).createShader(bounds),
                                child: Text(
                                  '$_detectedMarks%',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 28,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _detectedMarks / 100,
                              minHeight: 10,
                              backgroundColor: kGlass,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                  _scoreColor),
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: double.infinity,
                            child: GradientButton(
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Result saved!'),
                                    backgroundColor: kAccent1,
                                  ),
                                );
                              },
                              child: const Text('Save Result',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16)),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
