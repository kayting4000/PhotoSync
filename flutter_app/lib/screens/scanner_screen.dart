import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../theme/app_theme.dart';
import '../widgets/fade_slide_in.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  File? _selectedImage;
  String? _visualizedImageUrl;
  int _detectedCount = 0;
  bool _isAnalyzing = false;
  final ImagePicker _picker = ImagePicker();

  static const _apiKey = 'mYatQOHngAdvI15dZUFk';
  static const _workspaceName = 'kayting-habibun-najal';
  static const _workflowId = 'detect-count-and-visualize-2';

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _visualizedImageUrl = null;
          _detectedCount = 0;
        });
        await _analyzeWithRoboflow(pickedFile.path);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: kAccent3),
        );
      }
    }
  }

  Future<void> _analyzeWithRoboflow(String imagePath) async {
    setState(() => _isAnalyzing = true);
    try {
      final imageBytes = await File(imagePath).readAsBytes();
      final base64Image = base64Encode(imageBytes);

      final url = Uri.parse(
        'https://serverless.roboflow.com/$_workspaceName/workflows/$_workflowId',
      );

      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $_apiKey',
        },
        body: jsonEncode({
          'api_key': _apiKey,
          'inputs': {
            'image': {
              'type': 'base64',
              'value': base64Image,
            },
          },
          'use_cache': true,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _parseResults(data);
      } else {
        throw Exception('API error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Analysis failed: $e'),
            backgroundColor: kAccent3,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  void _parseResults(dynamic data) {
    try {
      int count = 0;
      String? vizUrl;

      // Try to extract count and visualization from workflow output
      if (data is List && data.isNotEmpty) {
        final result = data[0];
        // Count from predictions
        if (result['predictions'] != null) {
          final preds = result['predictions'];
          if (preds['predictions'] != null) {
            count = (preds['predictions'] as List).length;
          }
        }
        // Visualized image URL
        if (result['visualization'] != null) {
          vizUrl = result['visualization']['url'];
        }
      } else if (data is Map) {
        final outputs = data['outputs'] ?? data;
        if (outputs['count'] != null) {
          count = outputs['count'] is int
              ? outputs['count']
              : int.tryParse(outputs['count'].toString()) ?? 0;
        }
        if (outputs['visualization'] != null) {
          vizUrl = outputs['visualization']['url'] ??
              outputs['visualization'].toString();
        }
      }

      if (mounted) {
        setState(() {
          _detectedCount = count;
          _visualizedImageUrl = vizUrl;
        });
      }
    } catch (e) {
      debugPrint('Parse error: $e');
    }
  }

  Color get _scoreColor {
    if (_detectedCount >= 15) return const Color(0xFF43E97B);
    if (_detectedCount >= 8) return const Color(0xFFF7971E);
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
                FadeSlideIn(
                  child: Row(
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
                ),
                const SizedBox(height: 8),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: const Text(
                    'Powered by Roboflow AI',
                    style: TextStyle(color: kAccent2, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),

                // Image preview
                FadeSlideIn(
                  delay: const Duration(milliseconds: 150),
                  child: GlassCard(
                    padding: EdgeInsets.zero,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: _visualizedImageUrl != null
                          ? Image.network(
                              _visualizedImageUrl!,
                              height: 280,
                              width: double.infinity,
                              fit: BoxFit.cover,
                              loadingBuilder: (_, child, progress) =>
                                  progress == null
                                      ? child
                                      : const SizedBox(
                                          height: 280,
                                          child: Center(
                                            child: CircularProgressIndicator(
                                                color: kAccent1),
                                          ),
                                        ),
                            )
                          : _selectedImage != null
                              ? Image.file(_selectedImage!,
                                  height: 280,
                                  width: double.infinity,
                                  fit: BoxFit.cover)
                              : Container(
                                  height: 280,
                                  width: double.infinity,
                                  color: const Color(0x1AFFFFFF),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.document_scanner_rounded,
                                          size: 64, color: kTextSecondary),
                                      SizedBox(height: 16),
                                      Text('No image selected',
                                          style: TextStyle(
                                              color: kTextSecondary,
                                              fontSize: 15)),
                                      SizedBox(height: 8),
                                      Text('Take a photo or pick from gallery',
                                          style: TextStyle(
                                              color: kTextSecondary,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // Buttons
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: Row(
                    children: [
                      Expanded(
                        child: GradientButton(
                          onPressed: _isAnalyzing
                              ? null
                              : () => _pickImage(ImageSource.camera),
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
                          onPressed: _isAnalyzing
                              ? null
                              : () => _pickImage(ImageSource.gallery),
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
                ),

                if (_isAnalyzing) ...[
                  const SizedBox(height: 24),
                  GlassCard(
                    child: Column(
                      children: const [
                        CircularProgressIndicator(color: kAccent1),
                        SizedBox(height: 16),
                        Text('Analyzing with Roboflow AI...',
                            style: TextStyle(color: kTextSecondary)),
                      ],
                    ),
                  ),
                ],

                if (!_isAnalyzing && _selectedImage != null) ...[
                  const SizedBox(height: 24),
                  FadeSlideIn(
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: const [
                              Icon(Icons.auto_awesome_rounded,
                                  color: kAccent2, size: 18),
                              SizedBox(width: 8),
                              Text('AI Detection Results',
                                  style: TextStyle(
                                      color: kTextPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Checkmarks Detected',
                                  style: TextStyle(color: kTextSecondary)),
                              ShaderMask(
                                shaderCallback: (bounds) => LinearGradient(
                                  colors: [_scoreColor, kAccent2],
                                ).createShader(bounds),
                                child: Text(
                                  '$_detectedCount',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 36,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          if (_visualizedImageUrl != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0x1A43E97B),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0x4043E97B)),
                              ),
                              child: const Row(
                                children: [
                                  Icon(Icons.check_circle_rounded,
                                      color: Color(0xFF43E97B), size: 16),
                                  SizedBox(width: 8),
                                  Text('Visualization ready — see image above',
                                      style: TextStyle(
                                          color: Color(0xFF43E97B),
                                          fontSize: 12)),
                                ],
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
                      ),
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
