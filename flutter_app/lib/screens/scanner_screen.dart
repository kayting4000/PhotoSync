import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';
import '../config.dart';
import '../services/api_service.dart';
import '../providers/student_provider.dart';
import '../providers/exam_provider.dart';
import '../providers/subject_provider.dart';
import '../models/exam.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/app_drawer.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  /// Multi-page support: each page stored as raw bytes (cross-platform)
  final List<Uint8List> _pageBytes = [];
  int _detectedCount = 0;
  bool _isAnalyzing = false;
  final bool _isUploading = false;
  final ImagePicker _picker = ImagePicker();

  // Student & Exam selection
  String? _selectedStudentId;
  String? _selectedExamId;

  // Scan review state
  bool _scanComplete = false;
  bool _resultSaved = false;
  bool _scanFailed = false;
  String _scanErrorMessage = '';
  double _percentage = 0;
  String _grade = '';
  String _remarks = '';

  // Edit state
  int _editCorrectAnswers = 0;
  int _editTotalItems = 50;

  String get _backendUrl => '${AppConfig.baseUrl}/scanner/scan';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        context.read<StudentProvider>().fetchStudents();
        context.read<ExamProvider>().fetchExams();
        context.read<SubjectProvider>().fetchSubjects();
      }
    });
  }

  /// Reset the scan state for a fresh scan
  void _resetScan() {
    setState(() {
      _detectedCount = 0;
      _scanComplete = false;
      _resultSaved = false;
      _scanFailed = false;
      _scanErrorMessage = '';
      _percentage = 0;
      _grade = '';
      _remarks = '';
    });
  }

  /// Get the selected Exam object from the provider
  Exam? get _selectedExam {
    final exams = context.read<ExamProvider>().exams;
    if (_selectedExamId == null) return null;
    try {
      return exams.firstWhere((e) => e.id == _selectedExamId);
    } catch (_) {
      return null;
    }
  }

  /// Pick an image and add it as a new page
  Future<void> _addPage(ImageSource source) async {
    try {
      if (_pageBytes.length >= 5) {
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

      // Reset previous scan results when adding new pages
      if (_scanComplete) _resetScan();

      final pickedFile = await _picker.pickImage(
        source: source,
        imageQuality: 85,
      );
      if (pickedFile != null) {
        final bytes = await pickedFile.readAsBytes();
        setState(() {
          _pageBytes.add(bytes);
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

  void _removePage(int index) {
    setState(() {
      _pageBytes.removeAt(index);
    });
    if (_scanComplete) _resetScan();
  }

  /// Show dialog to create a new exam
  void _showCreateExamDialog() {
    final subjects = context.read<SubjectProvider>().subjects;
    if (subjects.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please create a subject first'),
          backgroundColor: kAccent3,
        ),
      );
      return;
    }

    String? selectedSubjectId = subjects.first.id;
    final nameController = TextEditingController();
    final totalItemsController = TextEditingController(text: '50');
    final passingScoreController = TextEditingController(text: '30');
    String componentType = 'exam';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [kAccent1, kAccent2]),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(Icons.add_circle_rounded, color: Colors.white, size: 20),
                      ),
                      const SizedBox(width: 12),
                      Text('New Exam',
                          style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text('Subject', style: TextStyle(color: kAccent2, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: kGlass,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kGlassBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedSubjectId,
                        isExpanded: true,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1A1A3E)
                            : lSurface,
                        style: TextStyle(color: context.textPrimary),
                        items: subjects.map((s) => DropdownMenuItem(
                          value: s.id,
                          child: Text(s.name, style: TextStyle(color: context.textPrimary)),
                        )).toList(),
                        onChanged: (v) => setDialogState(() => selectedSubjectId = v),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassTextField(
                      controller: nameController,
                      label: 'Exam Name',
                      prefixIcon: Icons.assignment_rounded),
                  const SizedBox(height: 12),
                  const Text('Component Type', style: TextStyle(color: kAccent2, fontSize: 13)),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: kGlass,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kGlassBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: componentType,
                        isExpanded: true,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1A1A3E)
                            : lSurface,
                        style: TextStyle(color: context.textPrimary),
                        items: const [
                          DropdownMenuItem(value: 'exam', child: Text('Exam', style: TextStyle(color: kAccent2))),
                          DropdownMenuItem(value: 'quiz', child: Text('Quiz', style: TextStyle(color: kAccent2))),
                          DropdownMenuItem(value: 'assignment', child: Text('Assignment', style: TextStyle(color: kAccent2))),
                          DropdownMenuItem(value: 'oral', child: Text('Oral', style: TextStyle(color: kAccent2))),
                        ],
                        onChanged: (v) => setDialogState(() => componentType = v!),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  GlassTextField(
                      controller: totalItemsController,
                      label: 'Total Items',
                      prefixIcon: Icons.numbers_rounded,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  GlassTextField(
                      controller: passingScoreController,
                      label: 'Passing Score',
                      prefixIcon: Icons.check_circle_outline_rounded,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onTap: () => Navigator.pop(context),
                          child: const Center(
                              child: Text('Cancel', style: TextStyle(color: kAccent2))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientButton(
                          colors: const [kAccent2, kAccent1],
                          onPressed: () async {
                            final name = nameController.text.trim();
                            final totalItems = int.tryParse(totalItemsController.text.trim()) ?? 50;
                            final passingScore = double.tryParse(passingScoreController.text.trim());
                            if (name.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Exam name is required'), backgroundColor: kAccent3),
                              );
                              return;
                            }
                            if (selectedSubjectId == null) return;

                            final exam = Exam(
                              subjectId: selectedSubjectId!,
                              name: name,
                              componentType: componentType,
                              totalItems: totalItems,
                              passingScore: passingScore,
                            );

                            final provider = context.read<ExamProvider>();
                            final success = await provider.addExam(exam);
                            if (success && mounted) {
                              Navigator.pop(context);
                              // Select the newly created exam
                              final exams = provider.exams;
                              if (exams.isNotEmpty) {
                                setState(() => _selectedExamId = exams.last.id);
                              }
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Exam created successfully!'),
                                  backgroundColor: kAccent2,
                                ),
                              );
                            }
                          },
                          child: const Text('Create',
                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  /// Show dialog to edit scan result before saving
  void _showEditResultDialog() {
    final exam = _selectedExam;
    final maxItems = exam?.totalItems ?? 100;

    _editCorrectAnswers = _detectedCount;
    _editTotalItems = maxItems;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [kAccent1, kAccent2]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.edit_rounded, color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Text('Edit Score',
                        style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 20,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 20),
                Text('Correct Answers Detected',
                    style: TextStyle(color: context.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: kGlass,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kGlassBorder),
                  ),
                  child: TextField(
                    controller: TextEditingController(text: _editCorrectAnswers.toString()),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: context.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    onChanged: (v) {
                      final val = int.tryParse(v) ?? 0;
                      setDialogState(() => _editCorrectAnswers = val);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                Text('Total Items',
                    style: TextStyle(color: context.textSecondary, fontSize: 13)),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: kGlass,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kGlassBorder),
                  ),
                  child: TextField(
                    controller: TextEditingController(text: _editTotalItems.toString()),
                    keyboardType: TextInputType.number,
                    style: TextStyle(color: context.textPrimary, fontSize: 24, fontWeight: FontWeight.bold),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                    ),
                    onChanged: (v) {
                      final val = int.tryParse(v) ?? 50;
                      setDialogState(() => _editTotalItems = val);
                    },
                  ),
                ),
                const SizedBox(height: 16),
                // Preview of computed result
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: kGlass,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kGlassBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Result Preview',
                              style: TextStyle(color: context.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '${_editCorrectAnswers.clamp(0, _editTotalItems)} / $_editTotalItems',
                            style: TextStyle(
                              color: context.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('Percentage',
                              style: TextStyle(color: context.textSecondary, fontSize: 12)),
                          const SizedBox(height: 4),
                          Text(
                            '${((_editCorrectAnswers.clamp(0, _editTotalItems) / _editTotalItems) * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: _editCorrectAnswers >= _editTotalItems * 0.6
                                  ? const Color(0xFF43E97B)
                                  : kAccent3,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onTap: () => Navigator.pop(context),
                        child: const Center(
                            child: Text('Cancel', style: TextStyle(color: kAccent2))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        colors: const [kAccent1, kAccent2],
                        onPressed: () {
                          setState(() {
                            _detectedCount = _editCorrectAnswers.clamp(0, _editTotalItems);
                            _computePercentage(_editTotalItems);
                          });
                          Navigator.pop(context);
                        },
                        child: const Text('Apply',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Compute percentage and grade from detected count and total items
  void _computePercentage(int totalItems) {
    final pct = (_detectedCount / totalItems * 100).clamp(0, 100).toDouble();
    _percentage = pct;

    // Grade assignment matching backend logic
    if (pct >= 96) {
      _grade = '1.0';
      _remarks = 'Passed';
    } else if (pct >= 92) {
      _grade = '1.25';
      _remarks = 'Passed';
    } else if (pct >= 88) {
      _grade = '1.5';
      _remarks = 'Passed';
    } else if (pct >= 84) {
      _grade = '1.75';
      _remarks = 'Passed';
    } else if (pct >= 80) {
      _grade = '2.0';
      _remarks = 'Passed';
    } else if (pct >= 76) {
      _grade = '2.25';
      _remarks = 'Passed';
    } else if (pct >= 72) {
      _grade = '2.5';
      _remarks = 'Passed';
    } else if (pct >= 68) {
      _grade = '2.75';
      _remarks = 'Passed';
    } else if (pct >= 60) {
      _grade = '3.0';
      _remarks = 'Passed';
    } else {
      _grade = '5.0';
      _remarks = 'Failed';
    }
  }

  /// Scan all pages — sends each to Roboflow
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
    if (_pageBytes.isEmpty) return;

    // Reset previous results
    _resetScan();

    setState(() {
      _isAnalyzing = true;
      _detectedCount = 0;
    });

    int totalDetected = 0;

    try {
      for (int i = 0; i < _pageBytes.length; i++) {
        final base64Image = base64Encode(_pageBytes[i]);
        debugPrint('Scanning page ${i + 1}/${_pageBytes.length}...');

        final response = await http.post(
          Uri.parse(_backendUrl),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'image_base64': base64Image,
            'page_number': i + 1,
            'total_pages': _pageBytes.length,
          }),
        );

        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final pageCount = (data['count'] ?? 0) as int;
          totalDetected += pageCount;
          debugPrint('  Page ${i + 1}: $pageCount checkmarks detected');
        } else {
          throw Exception('Page ${i + 1} error: ${response.statusCode}');
        }
      }

      if (mounted) {
        final exam = _selectedExam;
        final totalItems = exam?.totalItems ?? 100;

        setState(() {
          _detectedCount = totalDetected;
          _scanComplete = true;
          _computePercentage(totalItems);
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isAnalyzing = false;
          _scanFailed = true;
          _scanErrorMessage = e.toString().replaceAll('Exception: ', '');
        });
      }
    } finally {
      if (mounted) setState(() => _isAnalyzing = false);
    }
  }

  /// Save the scan result to backend
  Future<void> _saveResult() async {
    if (_selectedStudentId == null || _selectedExamId == null) return;

    final exam = _selectedExam;
    final totalItems = exam?.totalItems ?? 100;

    setState(() => _isAnalyzing = true);

    try {
      await ApiService().post('/results/', {
        'student_id': _selectedStudentId!,
        'exam_id': _selectedExamId!,
        'correct_answers': _detectedCount,
        'total_score': totalItems,
        'percentage': _percentage,
      });

      if (mounted) {
        setState(() {
          _resultSaved = true;
          _isAnalyzing = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Result saved: ${_percentage.toStringAsFixed(1)}% ($_detectedCount correct out of $totalItems)'),
            backgroundColor: const Color(0xFF43E97B),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isAnalyzing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to save: $e'), backgroundColor: kAccent3),
        );
      }
    }
  }

  /// Navigate to grades screen
  void _goToGrades() {
    context.push('/grades');
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
    final tp = context.textPrimary;
    final ts = context.textSecondary;
    final isDark = context.isDark;
    final exam = _selectedExam;
    final totalItems = exam?.totalItems ?? 100;

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
                            child: Icon(Icons.menu_rounded, color: kAccent2, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Text('Test Paper Scanner',
                          style: TextStyle(color: tp, fontSize: 22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const FadeSlideIn(
                  delay: Duration(milliseconds: 100),
                  child: Text('Powered by Roboflow AI', style: TextStyle(color: kAccent2, fontSize: 12)),
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
                      border: Border.all(color: isDark ? const Color(0x33FFFFFF) : const Color(0x306C63FF)),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.description_rounded, color: kAccent1, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          '${_pageBytes.isEmpty ? 'No' : _pageBytes.length} page${_pageBytes.length != 1 ? 's' : ''} selected',
                          style: TextStyle(color: tp, fontWeight: FontWeight.w600, fontSize: 13),
                        ),
                        if (_pageBytes.isNotEmpty && _pageBytes.length < 5) ...[
                          const SizedBox(width: 6),
                          Text('(max 5)', style: TextStyle(color: ts, fontSize: 11)),
                        ],
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Student & Exam selection
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  child: GlassCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Select Student', style: TextStyle(color: kAccent2, fontSize: 13)),
                        const SizedBox(height: 8),
                        _buildDropdown(
                          value: _selectedStudentId,
                          hint: 'Choose a student',
                          items: students.map((s) => DropdownMenuItem(
                            value: s.id,
                            child: Text(s.fullName, style: TextStyle(color: tp)),
                          )).toList(),
                          onChanged: (v) {
                            setState(() => _selectedStudentId = v);
                            if (_scanComplete) _resetScan();
                          },
                        ),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('Select Exam', style: TextStyle(color: kAccent2, fontSize: 13)),
                                  const SizedBox(height: 8),
                                  _buildDropdown(
                                    value: _selectedExamId,
                                    hint: 'Choose an exam',
                                    items: exams.map((e) => DropdownMenuItem(
                                      value: e.id,
                                      child: Text(
                                        '${e.name} (${e.totalItems} items)',
                                        style: TextStyle(color: tp, fontSize: 13),
                                      ),
                                    )).toList(),
                                    onChanged: (v) {
                                      setState(() => _selectedExamId = v);
                                      if (_scanComplete) _resetScan();
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Create Exam button
                            GestureDetector(
                              onTap: _showCreateExamDialog,
                              child: Container(
                                padding: const EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [kAccent2, kAccent1]),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: const Icon(Icons.add_rounded, color: Colors.white, size: 20),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Page thumbnails
                if (_pageBytes.isNotEmpty) ...[
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 120),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.collections_bookmark_rounded, color: kAccent2, size: 18),
                            const SizedBox(width: 8),
                            Text('Pages', style: TextStyle(color: tp, fontSize: 14, fontWeight: FontWeight.w600)),
                            const Spacer(),
                            Text('${_pageBytes.length} page${_pageBytes.length != 1 ? 's' : ''}', style: TextStyle(color: ts, fontSize: 12)),
                          ],
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 100,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: _pageBytes.length,
                            separatorBuilder: (_, __) => const SizedBox(width: 10),
                            itemBuilder: (context, index) {
                              return Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(12),
                                    child: Image.memory(
                                      _pageBytes[index],
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
                                  Positioned(top: 4, left: 4,
                                    child: Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                      decoration: BoxDecoration(
                                        color: kAccent1.withValues(alpha: 0.85),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Text('${index + 1}',
                                        style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                  ),
                                  Positioned(top: 4, right: 4,
                                    child: GestureDetector(
                                      onTap: () => _removePage(index),
                                      child: Container(
                                        padding: const EdgeInsets.all(2),
                                        decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
                                        child: const Icon(Icons.close_rounded, color: Colors.white, size: 14),
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

                // Buttons
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: GradientButton(
                              onPressed: _pageBytes.length >= 5 ? null : () => _addPage(ImageSource.camera),
                              colors: const [kAccent1, kAccent2],
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.camera_alt_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('Add Page', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: GradientButton(
                              onPressed: _pageBytes.length >= 5 ? null : () => _addPage(ImageSource.gallery),
                              colors: const [kAccent3, kAccent1],
                              child: const Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.photo_library_rounded, color: Colors.white, size: 18),
                                  SizedBox(width: 8),
                                  Text('From Gallery', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (_pageBytes.isNotEmpty && !_resultSaved) ...[
                        const SizedBox(height: 12),
                        SizedBox(
                          width: double.infinity,
                          child: GradientButton(
                            onPressed: (_isAnalyzing || _isUploading) ? null : _scanAllPages,
                            colors: const [Color(0xFF43E97B), Color(0xFF38F9D7)],
                            child: _isAnalyzing
                              ? const SizedBox(height: 20, width: 20,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                                    const SizedBox(width: 8),
                                    Text(
                                      'Scan ${_pageBytes.length > 1 ? 'All ${_pageBytes.length} Pages' : 'Page'}',
                                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15),
                                    ),
                                  ],
                                ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ),

                // Analysis progress
                if (_isAnalyzing) ...[
                  const SizedBox(height: 20),
                  const GlassCard(
                    child: Column(
                      children: [
                        CircularProgressIndicator(color: kAccent1),
                        SizedBox(height: 16),
                        Text('Analyzing pages with Roboflow AI...', style: TextStyle(color: kAccent2)),
                      ],
                    ),
                  ),
                ],

                // ─── RESULTS REVIEW CARD ───────────────────────────────
                if (_scanComplete && _detectedCount > 0 && !_isAnalyzing) ...[
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    child: GlassCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  gradient: const LinearGradient(colors: [kAccent1, kAccent2]),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.auto_awesome_rounded, color: Colors.white, size: 18),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: Text('AI Detection Results',
                                    style: TextStyle(color: tp, fontSize: 16, fontWeight: FontWeight.w600)),
                              ),
                              if (_resultSaved)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF43E97B).withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF43E97B).withValues(alpha: 0.4)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.check_circle_rounded, color: Color(0xFF43E97B), size: 14),
                                      SizedBox(width: 4),
                                      Text('Saved', style: TextStyle(color: Color(0xFF43E97B), fontSize: 11, fontWeight: FontWeight.bold)),
                                    ],
                                  ),
                                ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Score fraction (BIG)
                          Center(
                            child: Column(
                              children: [
                                ShaderMask(
                                  shaderCallback: (bounds) =>
                                      LinearGradient(colors: [_scoreColor, kAccent2]).createShader(bounds),
                                  child: Text(
                                    '$_detectedCount / $totalItems',
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 40,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'items detected correctly',
                                  style: TextStyle(color: ts, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),

                          // Percentage bar
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: _percentage / 100,
                              minHeight: 10,
                              backgroundColor: kGlass,
                              valueColor: AlwaysStoppedAnimation<Color>(_scoreColor),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Percentage and Grade row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _StatItem(
                                label: 'Percentage',
                                value: '${_percentage.toStringAsFixed(1)}%',
                                color: _percentage >= 60 ? const Color(0xFF43E97B) : kAccent3,
                              ),
                              _StatItem(
                                label: 'Grade',
                                value: _grade,
                                color: _grade == '5.0' ? kAccent3 : kAccent1,
                              ),
                              _StatItem(
                                label: 'Remarks',
                                value: _remarks,
                                color: _remarks == 'Passed' ? const Color(0xFF43E97B) : kAccent3,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),

                          // Exam info
                          if (exam != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: kGlass,
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: kGlassBorder),
                              ),
                              child: Row(
                                children: [
                                  const Icon(Icons.assignment_rounded, color: kAccent2, size: 16),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      exam.name,
                                      style: TextStyle(color: tp, fontSize: 13),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                  Text(
                                    '${exam.totalItems} items',
                                    style: TextStyle(color: ts, fontSize: 12),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Action buttons
                          if (!_resultSaved) ...[
                            Row(
                              children: [
                                Expanded(
                                  child: GradientButton(
                                    onPressed: _showEditResultDialog,
                                    colors: const [kAccent2, kAccent1],
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                                        SizedBox(width: 6),
                                        Text('Edit Score',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: GradientButton(
                                    onPressed: _saveResult,
                                    colors: const [Color(0xFF43E97B), Color(0xFF38F9D7)],
                                    child: const Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.check_circle_rounded, color: Colors.white, size: 16),
                                        SizedBox(width: 6),
                                        Text('Accept & Save',
                                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: GlassCard(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                onTap: () {
                                  _pageBytes.clear();
                                  _resetScan();
                                },
                                child: const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.refresh_rounded, color: kAccent2, size: 16),
                                      SizedBox(width: 6),
                                      Text('Rescan (Clear & Start Over)',
                                          style: TextStyle(color: kAccent2, fontWeight: FontWeight.w600, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ] else ...[
                            // After save - View Grades button
                            SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                onPressed: _goToGrades,
                                colors: const [kAccent1, kAccent2],
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.bar_chart_rounded, color: Colors.white, size: 18),
                                    SizedBox(width: 8),
                                    Text('View Grades',
                                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 15)),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            SizedBox(
                              width: double.infinity,
                              child: GlassCard(
                                padding: const EdgeInsets.symmetric(vertical: 12),
                                onTap: () {
                                  _pageBytes.clear();
                                  _resetScan();
                                },
                                child: const Center(
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.document_scanner_rounded, color: kAccent2, size: 16),
                                      SizedBox(width: 6),
                                      Text('Scan Another Paper',
                                          style: TextStyle(color: kAccent2, fontWeight: FontWeight.w600, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ),
                ],

                // ─── SCAN FAILED CARD ─────────────────────────────────
                if (_scanFailed && !_isAnalyzing) ...[
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    child: GlassCard(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: kAccent3.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: kAccent3.withValues(alpha: 0.3)),
                            ),
                            child: const Icon(Icons.error_outline_rounded, color: kAccent3, size: 48),
                          ),
                          const SizedBox(height: 14),
                          Text('Scan Failed',
                              style: TextStyle(
                                  color: tp,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              _scanErrorMessage.isNotEmpty
                                  ? _scanErrorMessage
                                  : 'Could not scan the image. The AI model may not have detected any checkmarks.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: ts, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Tips for better scanning
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: kGlass,
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: kGlassBorder),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('Tips for better scanning:',
                                    style: TextStyle(color: tp, fontSize: 12, fontWeight: FontWeight.w600)),
                                const SizedBox(height: 6),
                                Text('• Use clear, well-lit images',
                                    style: TextStyle(color: ts, fontSize: 11)),
                                Text('• Ensure checkmarks are clearly visible',
                                    style: TextStyle(color: ts, fontSize: 11)),
                                Text('• Avoid blurry or angled photos',
                                    style: TextStyle(color: ts, fontSize: 11)),
                                Text('• Make sure the paper fills the frame',
                                    style: TextStyle(color: ts, fontSize: 11)),
                              ],
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: GradientButton(
                                  onPressed: _scanAllPages,
                                  colors: const [kAccent2, kAccent1],
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.refresh_rounded, color: Colors.white, size: 16),
                                      SizedBox(width: 6),
                                      Text('Try Again',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  onTap: () {
                                    _showEditResultDialog();
                                    setState(() => _scanFailed = false);
                                  },
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.edit_rounded, color: context.textSecondary, size: 16),
                                        const SizedBox(width: 6),
                                        Text('Enter Manually',
                                            style: TextStyle(color: context.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              onTap: () {
                                _pageBytes.clear();
                                _resetScan();
                              },
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_camera_rounded, color: kAccent2, size: 16),
                                    SizedBox(width: 6),
                                    Text('Retake Image',
                                        style: TextStyle(color: kAccent2, fontWeight: FontWeight.w600, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // ─── ZERO DETECTIONS CARD ──────────────────────────────
                if (_scanComplete && _detectedCount == 0 && !_isAnalyzing && !_scanFailed) ...[
                  const SizedBox(height: 20),
                  FadeSlideIn(
                    child: GlassCard(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF7971E).withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: const Color(0xFFF7971E).withValues(alpha: 0.3)),
                            ),
                            child: const Icon(Icons.search_off_rounded, color: Color(0xFFF7971E), size: 48),
                          ),
                          const SizedBox(height: 14),
                          Text('No Checkmarks Detected',
                              style: TextStyle(
                                  color: tp,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 8),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'The AI scanned your ${_pageBytes.length > 1 ? '${_pageBytes.length} pages' : 'page'} but could not detect any checkmarks. You can still manually enter the score or try scanning again.',
                              textAlign: TextAlign.center,
                              style: TextStyle(color: ts, fontSize: 13),
                            ),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: GradientButton(
                                  onPressed: _showEditResultDialog,
                                  colors: const [kAccent2, kAccent1],
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.edit_rounded, color: Colors.white, size: 16),
                                      SizedBox(width: 6),
                                      Text('Enter Score Manually',
                                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  onTap: _scanAllPages,
                                  child: Center(
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(Icons.refresh_rounded, color: context.textSecondary, size: 16),
                                        const SizedBox(width: 6),
                                        Text('Rescan',
                                            style: TextStyle(color: context.textSecondary, fontWeight: FontWeight.w600, fontSize: 13)),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          SizedBox(
                            width: double.infinity,
                            child: GlassCard(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              onTap: () {
                                _pageBytes.clear();
                                _resetScan();
                              },
                              child: const Center(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.photo_camera_rounded, color: kAccent2, size: 16),
                                    SizedBox(width: 6),
                                    Text('Retake Image',
                                        style: TextStyle(color: kAccent2, fontWeight: FontWeight.w600, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                // Empty state
                if (_pageBytes.isEmpty && !_isAnalyzing && !_scanComplete) ...[
                  const SizedBox(height: 16),
                  FadeSlideIn(
                    delay: const Duration(milliseconds: 150),
                    child: GlassCard(
                      child: Column(
                        children: [
                          const SizedBox(height: 20),
                          Icon(Icons.document_scanner_rounded, size: 48, color: kAccent2.withValues(alpha: 0.5)),
                          const SizedBox(height: 12),
                          Text('Tap the buttons above to add pages', style: TextStyle(color: ts, fontSize: 13)),
                          const SizedBox(height: 4),
                          Text('Supports 1-5 page exam papers', style: TextStyle(color: ts, fontSize: 12)),
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
      decoration: BoxDecoration(color: kGlass, borderRadius: BorderRadius.circular(14), border: Border.all(color: kGlassBorder)),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          dropdownColor: isDark ? const Color(0xFF1A1A3E) : Colors.white,
          style: TextStyle(color: tp),
          hint: Text(hint, style: TextStyle(color: ts)),
          items: items.isEmpty
              ? [DropdownMenuItem(value: null, enabled: false, child: Text('No items available', style: TextStyle(color: Colors.grey[500], fontSize: 13)))]
              : items,
          onChanged: onChanged,
        ),
      ),
    );
  }
}

/// Reusable stat item for the results card
class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: kTextSecondary, fontSize: 10)),
      ],
    );
  }
}