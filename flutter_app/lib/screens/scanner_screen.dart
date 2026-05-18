import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/student_provider.dart';
import '../providers/exam_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/app_drawer.dart';

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
  bool _isUploading = false;
  String? _uploadedUrl;
  final ImagePicker _picker = ImagePicker();

  // Student & Exam selection
  String? _selectedStudentId;
  String? _selectedExamId;
  bool _subjectsLoading = true;
  List<dynamic> _subjects = [];
  String? _selectedSubjectId;

  static const _backendUrl = 'http://10.0.2.2:8000/scanner/scan';

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
    Provider.of<StudentProvider>(context, listen: false).fetchStudents();
    Provider.of<ExamProvider>(context, listen: false).fetchExams();
  }

  Future<void> _fetchSubjects() async {
    try {
      final api = ApiService();
      final subjects = await api.get('/subjects/');
      if (mounted) {
        setState(() {
          _subjects = subjects;
          _subjectsLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _subjectsLoading = false);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      if (_selectedStudentId == null || _selectedExamId == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Please select a student and exam first'),
              backgroundColor: kAccent3,
            ),
          );
        }
        return;
      }

      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _visualizedImageUrl = null;
          _detectedCount = 0;
          _uploadedUrl = null;
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

      final response = await http.post(
        Uri.parse(_backendUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'image_base64': base64Image}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _detectedCount = data['count'] ?? 0;
            _visualizedImageUrl = data['visualization_url'];
          });
        }
        // Auto-save the scanned image to the student's record
        await _saveScannedImage(imagePath);
      } else {
        throw Exception('Backend error: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Analysis failed: $e'), backgroundColor: kAccent3),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  Future<void> _saveScannedImage(String imagePath) async {
    setState(() => _isUploading = true);
    try {
      final api = ApiService();
      final result = await api.uploadScan(
        studentId: _selectedStudentId!,
        examId: _selectedExamId!,
        imageFile: File(imagePath),
      );
      if (mounted) {
        setState(() {
          _uploadedUrl = result['file_url'];
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Test paper saved to student record (${result['compression_ratio']} compression)'),
            backgroundColor: kAccent1,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isUploading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Save failed: $e'),
            backgroundColor: kAccent3,
          ),
        );
      }
    }
  }

  Color get _scoreColor {
    if (_detectedCount >= 15) return const Color(0xFF43E97B);
    if (_detectedCount >= 8) return const Color(0xFFF7971E);
    return kAccent3;
  }

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentProvider>().students;
    final exams = context.watch<ExamProvider>().exams;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/scanner'),
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
                      Builder(
                        builder: (context) => GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: const GlassCard(
                            padding: EdgeInsets.all(10),
                            borderRadius: 12,
                            child: Icon(Icons.menu_rounded,
                                color: kTextPrimary, size: 20),
                          ),
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
                const FadeSlideIn(
                  delay: Duration(milliseconds: 100),
                  child: Text(
                    'Powered by Roboflow AI',
                    style: TextStyle(color: kAccent2, fontSize: 12),
                  ),
                ),
                const SizedBox(height: 20),

                // ─── Student & Exam selection ─────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Student',
                            style: TextStyle(color: kTextSecondary, fontSize: 13)),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedStudentId,
                          hint: 'Choose a student',
                          items: students
                              .map((s) => DropdownMenuItem(
                                    value: s.id,
                                    child: Text(s.fullName, style: const TextStyle(color: kTextPrimary)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedStudentId = v),
                        ),
                        const SizedBox(height: 16),
                        const Text('Select Subject (for exam filter)',
                            style: TextStyle(color: kTextSecondary, fontSize: 13)),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedSubjectId,
                          hint: 'Choose a subject',
                          items: _subjects
                              .map((s) => DropdownMenuItem(
                                    value: s['id'] as String,
                                    child: Text(s['name'] ?? '', style: const TextStyle(color: kTextPrimary)),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedSubjectId = v;
                              _selectedExamId = null;
                            });
                            if (v != null) {
                              Provider.of<ExamProvider>(context, listen: false)
                                  .fetchExams(subjectId: v);
                            }
                          },
                        ),
                        const SizedBox(height: 16),
                        const Text('Select Exam',
                            style: TextStyle(color: kTextSecondary, fontSize: 13)),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedExamId,
                          hint: 'Choose an exam',
                          items: exams
                              .map((e) => DropdownMenuItem(
                                    value: e.id,
                                    child: Text(e.name, style: const TextStyle(color: kTextPrimary)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedExamId = v),
                        ),
                      ],
                    ),
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
                                  child: const Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
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
                          onPressed: (_isAnalyzing || _isUploading)
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
                          onPressed: (_isAnalyzing || _isUploading)
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
                  const GlassCard(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: kAccent1),
                        SizedBox(height: 16),
                        Text('Analyzing with Roboflow AI...',
                            style: TextStyle(color: kTextSecondary)),
                      ],
                    ),
                  ),
                ],

                if (_isUploading) ...[
                  const SizedBox(height: 24),
                  const GlassCard(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: kAccent1),
                        SizedBox(height: 16),
                        Text('Saving scanned test paper to student record...',
                            style: TextStyle(color: kTextSecondary)),
                      ],
                    ),
                  ),
                ],

                if (!_isAnalyzing && !_isUploading && _selectedImage != null) ...[
                  const SizedBox(height: 24),
                  FadeSlideIn(
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Row(
                            children: [
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
                          if (_uploadedUrl != null) ...[
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: const Color(0x1A6C63FF),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                    color: const Color(0x406C63FF)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.cloud_done_rounded,
                                      color: kAccent1, size: 16),
                                  const SizedBox(width: 8),
                                  const Expanded(
                                    child: Text('Test paper saved to student record',
                                        style: TextStyle(
                                            color: kAccent1,
                                            fontSize: 12)),
                                  ),
                                  Text(
                                    _detectedCount > 0 ? '✓ Auto-saved' : 'Saved',
                                    style: const TextStyle(
                                        color: kAccent2, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 20),
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

  Widget _buildDropdown({
    required String? value,
    required String hint,
    required List<DropdownMenuItem<String>> items,
    required ValueChanged<String?> onChanged,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: kGlass,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: kGlassBorder),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: const Color(0xFF1A1A3E),
          style: const TextStyle(color: kTextPrimary),
          hint: Text(hint, style: const TextStyle(color: kTextSecondary)),
          items: items.isEmpty
              ? [
                  DropdownMenuItem(
                    value: null,
                    enabled: false,
                    child: Text('No items available',
                        style: TextStyle(color: Colors.grey[500], fontSize: 13)),
                  ),
                ]
              : items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}