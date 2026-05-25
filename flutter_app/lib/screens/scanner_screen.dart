import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../config.dart';
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
  /// Multi-page support: each page is a separate image file
  final List<File> _pageImages = [];
  String? _visualizedImageUrl;
  int _detectedCount = 0;
  bool _isAnalyzing = false;
  bool _isUploading = false;
  String? _uploadedUrl;
  final ImagePicker _picker = ImagePicker();

  // Student & Exam selection
  String? _selectedStudentId;
  String? _selectedExamId;
  List<dynamic> _subjects = [];
  String? _selectedSubjectId;
  String? _selectedPaperType;
  static const List<String> _paperTypes = ['All', 'Exam', 'Quiz', 'Assignment', 'Other'];

  String get _backendUrl => '${AppConfig.baseUrl}/scanner/scan';

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        Provider.of<StudentProvider>(context, listen: false).fetchStudents();
        Provider.of<ExamProvider>(context, listen: false).fetchExams();
      }
    });
  }

  Future<void> _fetchSubjects() async {
    try {
      final api = ApiService();
      final subjects = await api.get('/subjects/');
      if (mounted) {
        setState(() {
          _subjects = subjects;
        });
      }
    } catch (e) {
      // silently fail
    }
  }

  /// Pick an image and add it as a new page
  Future<void> _addPage(ImageSource source) async {
    try {
      if (_pageImages.length >= 5) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 5 pages allowed'),
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
          _pageImages.add(File(pickedFile.path));
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: kAccent3),
        );
      }
    }
  }

  /// Remove a page by index
  void _removePage(int index) {
    setState(() {
      _pageImages.removeAt(index);
    });
  }

  /// Scan all pages together — sends each page to Roboflow and aggregates results
  Future<void> _scanAllPages() async {
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
    if (_pageImages.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _detectedCount = 0;
      _visualizedImageUrl = null;
    });

    int totalDetected = 0;
    String? firstVisualization;

    try {
      for (int i = 0; i < _pageImages.length; i++) {
        final imageBytes = await _pageImages[i].readAsBytes();
        final base64Image = base64Encode(imageBytes);
        debugPrint('Scanning page ${i + 1}/${_pageImages.length}...');

        final response = await http.post(
          Uri.parse(_backendUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'image_base64': base64Image,
            'page_number': i + 1,
            'total_pages': _pageImages.length,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final pageCount = (data['count'] ?? 0) as int;
          totalDetected += pageCount;
          // Keep the first visualization
          if (firstVisualization == null) {
            firstVisualization = data['visualization_url'];
          }
          debugPrint('  Page ${i + 1}: $pageCount checkmarks detected');
        } else {
          throw Exception('Page ${i + 1} error: ${response.statusCode}');
        }
      }

      if (mounted) {
        setState(() {
          _detectedCount = totalDetected;
          _visualizedImageUrl = firstVisualization;
        });
      }

      // Auto-save all pages to the student record
      await _saveAllPages(totalDetected);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan failed: $e'), backgroundColor: kAccent3),
        );
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  /// Upload all pages as a multi-page scan to the student's record
  Future<void> _saveAllPages(int totalDetected) async {
    if (_selectedStudentId == null || _selectedExamId == null) return;
    setState(() => _isUploading = true);

    try {
      final api = ApiService();
      // Upload each page individually
      List<String> uploadedUrls = [];
      for (int i = 0; i < _pageImages.length; i++) {
        final result = await api.uploadScan(
          studentId: _selectedStudentId!,
          examId: _selectedExamId!,
          imageFile: _pageImages[i],
          pageNumber: i + 1,
          totalPages: _pageImages.length,
        );
        if (result['file_url'] != null) {
          uploadedUrls.add(result['file_url'] as String);
        }
      }

      // Also save the aggregated result to the exam result record
      if (uploadedUrls.isNotEmpty) {
        await api.post('/exam-results/update-or-create', {
          'student_id': _selectedStudentId,
          'exam_id': _selectedExamId,
          'correct_answers': totalDetected,
          'total_score': _pageImages.length * 20.0, // estimate
          'percentage': (totalDetected / (_pageImages.length * 20.0) * 100).clamp(0, 100),
        });
      }

      if (mounted) {
        setState(() {
          _uploadedUrl = uploadedUrls.isNotEmpty ? uploadedUrls.first : null;
          _isUploading = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${_pageImages.length} page(s) saved — $totalDetected checkmarks detected'),
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
    final tp = context.textPrimary;
    final ts = context.textSecondary;
    final isDark = context.isDark;

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
                                color: kAccent2, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('Test Paper Scanner',
                          style: TextStyle(
                              color: tp,
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
                const SizedBox(height: 16),

                // Page count indicator
                FadeSlideIn(
                  delay: const Duration(milliseconds: 50),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0x1AFFFFFF) : const Color(0x1A6C63FF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: isDark ? const Color(0x33FFFFFF) : const Color(0x306C63FF),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.description_rounded, color: kAccent1, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${_pageImages.isEmpty ? 'No' : _pageImages.length} page${_pageImages.length != 1 ? 's' : ''} selected',
                          style: TextStyle(
                            color: tp,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        if (_pageImages.length > 0 && _pageImages.length < 5) ...[
                          const SizedBox(width: 6),
                          Text(
                            '(max 5)',
                            style: TextStyle(color: ts, fontSize: 11),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Student & Exam selection ─────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Select Student',
                            style: TextStyle(color: ts, fontSize: 13)),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedStudentId,
                          hint: 'Choose a student',
                          items: students
                              .map((s) => DropdownMenuItem(
                                    value: s.id,
                                    child: Text(s.fullName, style: TextStyle(color: tp)),
                                  ))
                              .toList(),
                          onChanged: (v) => setState(() => _selectedStudentId = v),
                        ),
                        const SizedBox(height: 16),
                        Text('Select Subject (for exam filter)',
                            style: TextStyle(color: ts, fontSize: 13)),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedSubjectId,
                          hint: 'Choose a subject',
                          items: _subjects
                              .map((s) => DropdownMenuItem(
                                    value: s['id'] as String,
                                    child: Text(s['name'] ?? '', style: TextStyle(color: tp)),
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
                        Text('Paper Type',
                            style: TextStyle(color: ts, fontSize: 13)),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedPaperType,
                          hint: 'All types',
                          items: _paperTypes
                              .map((type) => DropdownMenuItem(
                                    value: type == 'All' ? null : type.toLowerCase(),
                                    child: Text(type, style: TextStyle(color: tp)),
                                  ))
                              .toList(),
                          onChanged: (v) {
                            setState(() {
                              _selectedPaperType = v;
                              _selectedExamId = null;
                            });
                          },
                        ),
                        const SizedBox(height: 16),
                        Text('Select Semester',
                            style: TextStyle(color: ts, fontSize: 13)),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedExamId,
                          hint: 'Choose a semester',
                          items: const [
                             DropdownMenuItem(value: 'preliminary', child: Text('Preliminary Term', style: TextStyle(color: kAccent2))),
                             DropdownMenuItem(value: 'midsemester', child: Text('Mid-Semester Term', style: TextStyle(color: kAccent2))),
                             DropdownMenuItem(value: 'final', child: Text('Final Term', style: TextStyle(color: kAccent2))),
                           ],
                          onChanged: (v) => setState(() => _selectedExamId = v),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // ─── Page Thumbnail Gallery ──────────────────────────────
                if (_pageImages.isNotEmpty) ...[
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.collections_bookmark_rounded, color: kAccent2, size: 18),
                            const SizedBox(width: 8),
                            Text('Pages',
                                style: TextStyle(color: tp, fontSize: 14, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text('${_pageImages.length} page${_pageImages.length != 1 ? 's' : ''}',
                                style: TextStyle(color: ts, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _pageImages.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image(
                                      image: FileImage(_pageImages[index]),
                                      width: 80,
                                      height: 100,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) =>
                                        Container(
                                          width: 80,
                                          height: 100,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[300],
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          child: const Icon(Icons.image_not_supported_rounded, color: Colors.grey),
                                        ),
                                    ),
                                  ),
                                  // Page number badge
                                  Positioned(
                                    top: 4,
                                    left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: kAccent1.withValues(alpha: 0.85),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '${index + 1}',
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ),
                                  // Delete button
                                  Positioned(
                                    top: 4,
                                    right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removePage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(
                                          color: Colors.black54,
                                          shape: BoxShape.circle,
                                        ),
                                        child: const Icon(Icons.close_rounded,
                                            color: Colors.white, size: 14),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                ],

                // ─── Add Page & Scan Buttons ────────────────────────────
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              onPressed: _pageImages.length >= 5 ? null : () => _addPage(ImageSource.camera),
                              colors: const [kAccent1, kAccent2],
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_rounded,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('Add Page',
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
                              onPressed: _pageImages.length >= 5 ? null : () => _addPage(ImageSource.gallery),
                              colors: const [kAccent3, kAccent1],
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_library_rounded,
                                      color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('From Gallery',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_pageImages.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: GradientButton(
                            onPressed: (_isAnalyzing || _isUploading)
                                ? null
                                : _scanAllPages,
                            colors: const [Color(0xFF43E97B), Color(0xFF38F9D7)],
                            child: _isAnalyzing
                                ? const SizedBox(
                                    height: 20,
                                    width: 20,
                                    child: CircularProgressIndicator(
                                        strokeWidth: 2, color: Colors.white),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(Icons.auto_awesome_rounded,
                                          color: Colors.white, size: 18),
                                      const SizedBox(width: 8),
                                      Text(
                                        'Scan ${_pageImages.length > 1 ? 'All ${_pageImages.length} Pages' : 'Page'}',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 15),
                                      ),
                                    ],
                                  ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // ─── AI Analysis Progress ───────────────────────────────
                if (_isAnalyzing) ...[
                  const SizedBox(height: 20),
                  const GlassCard(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: kAccent1),
                        SizedBox(height: 16),
                        Text('Analyzing pages with Roboflow AI...',
                            style: TextStyle(color: kAccent2)),
                      ],
                    ),
                  ),
                ],

                if (_isUploading) ...[
                  const SizedBox(height: 20),
                  const GlassCard(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: kAccent1),
                        SizedBox(height: 16),
                        Text('Saving pages to student record...',
                            style: TextStyle(color: kAccent2)),
                      ],
                    ),
                  ),
                ],

                // ─── Results ───────────────────────────────────────────
                if (!_isAnalyzing && !_isUploading && _pageImages.isNotEmpty && _detectedCount > 0) ...[
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.auto_awesome_rounded,
                                  color: kAccent2, size: 18),
                              const SizedBox(width: 8),
                              Text('AI Detection Results',
                                  style: TextStyle(
                                      color: tp,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Checkmarks Detected',
                                  style: TextStyle(color: ts)),
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
                          const SizedBox(height: 8),
                          Text(
                            'Across ${_pageImages.length} page${_pageImages.length != 1 ? 's' : ''}',
                            style: TextStyle(color: ts, fontSize: 12),
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
                                    child: Text('All pages saved to student record',
                                        style: TextStyle(
                                            color: kAccent1,
                                            fontSize: 12)),
                                  ),
                                  Text(
                                    '✓ Saved',
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

                // Empty state
                if (_pageImages.isEmpty && !_isAnalyzing) ...[
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 150),
                    child: GlassCard(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Icon(Icons.document_scanner_rounded,
                              size: 48, color: kAccent2.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text('Tap the buttons above to add pages',
                              style: TextStyle(color: ts, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Supports 1–5 page exam papers',
                              style: TextStyle(color: ts, fontSize: 12)),
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final tp = context.textPrimary;
    final ts = context.textSecondary;
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
          dropdownColor: isDark ? const Color(0xFF1A1A3E) : lSurface,
          style: TextStyle(color: tp),
          hint: Text(hint, style: TextStyle(color: ts)),
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