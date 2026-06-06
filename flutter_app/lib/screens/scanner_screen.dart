import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:provider/provider.dart';

import '../services/api_service.dart';
import '../providers/student_provider.dart';
import '../providers/exam_provider.dart';
import '../config.dart';

class ScannerScreen extends StatefulWidget {
  const ScannerScreen({super.key});

  @override
  State<ScannerScreen> createState() => _ScannerScreenState();
}

class _ScannerScreenState extends State<ScannerScreen> {
  final List<Uint8List> _pageBytes = [];
  final ImagePicker _picker = ImagePicker();
  final api = ApiService();

  String? _selectedStudentId;
  String? _selectedExamId;
  String? _selectedSubjectId;

  List<dynamic> _subjects = [];

  bool _isAnalyzing = false;
  int _detectedCount = 0;

  @override
  void initState() {
    super.initState();
    _fetchSubjects();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<StudentProvider>(context, listen: false).fetchStudents();
      Provider.of<ExamProvider>(context, listen: false).fetchExams();
    });
  }

  Future<void> _fetchSubjects() async {
    try {
      final res = await api.get('/subjects/');

      if (!mounted) return;

      setState(() {
        _subjects = res is List ? res : (res['items'] ?? []);
      });
    } catch (e) {
      debugPrint('Failed to load subjects: $e');
    }
  }

  Future<void> _scanAllPages() async {
    if (_pageBytes.isEmpty) return;

    setState(() {
      _isAnalyzing = true;
      _detectedCount = 0;
    });

    int total = 0;

    try {
      for (int i = 0; i < _pageBytes.length; i++) {
        final base64Image = base64Encode(_pageBytes[i]);

        final res = await api.post('/scanner/scan', {
          'image_base64': base64Image,
          'page_number': i + 1,
          'total_pages': _pageBytes.length,
        });

        final countNum = (res['count'] ?? 0);
        if (countNum is num) {
          total += countNum.toInt();
        }
      }

      if (!mounted) return;
      setState(() => _detectedCount = total);
    } catch (e) {
      debugPrint('Scan error: $e');
    } finally {
      // avoid 'return' inside finally; only update state if mounted
      if (mounted) {
        setState(() => _isAnalyzing = false);
      }
    }
  }

  Future<void> _addPage(ImageSource source) async {
    try {
      final XFile? picked = await _picker.pickImage(source: source, imageQuality: 80);
      if (picked == null) return;

      final bytes = await picked.readAsBytes();
      if (!mounted) return;

      setState(() {
        _pageBytes.add(bytes);
      });
    } catch (e) {
      debugPrint('Failed to pick image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentProvider>().students;
    final exams = context.watch<ExamProvider>().exams;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.blue),
              child: Text('Menu', style: TextStyle(color: Colors.white, fontSize: 18)),
            ),
            ListTile(
              title: const Text('Scanner'),
              selected: true,
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Dashboard'),
              onTap: () => Navigator.pushReplacementNamed(context, '/dashboard'),
            ),
            ListTile(
              title: const Text('Close'),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Test Paper Scanner",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              DropdownButton<String>(
                value: _selectedStudentId,
                hint: const Text("Select Student"),
                isExpanded: true,
                items: students.map((s) {
                  return DropdownMenuItem(
                    value: s.id,
                    child: Text(s.fullName),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedStudentId = v),
              ),

              const SizedBox(height: 10),

              DropdownButton<String>(
                value: _selectedSubjectId,
                hint: const Text("Select Subject"),
                isExpanded: true,
                items: _subjects.map((s) {
                  return DropdownMenuItem(
                    value: s['id'].toString(),
                    child: Text("${s['code']} ${s['name']}"),
                  );
                }).toList(),
                onChanged: (v) {
                  setState(() {
                    _selectedSubjectId = v;
                    _selectedExamId = null;
                  });

                  if (v != null) {
                    context.read<ExamProvider>().fetchExams(subjectId: v);
                  }
                },
              ),

              const SizedBox(height: 10),

              DropdownButton<String>(
                value: _selectedExamId,
                hint: const Text("Select Exam"),
                isExpanded: true,
                items: exams.map((e) {
                  return DropdownMenuItem(
                    value: e.id,
                    child: Text(e.name),
                  );
                }).toList(),
                onChanged: (v) => setState(() => _selectedExamId = v),
              ),

              const SizedBox(height: 20),

              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _addPage(ImageSource.camera),
                      child: const Text("Camera"),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _addPage(ImageSource.gallery),
                      child: const Text("Gallery"),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              ElevatedButton(
                onPressed: _isAnalyzing ? null : _scanAllPages,
                child: _isAnalyzing
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                    : Text("Scan Pages ($_detectedCount)"),
              ),

              const SizedBox(height: 20),

              Text("Detected: $_detectedCount"),
            ],
          ),
        ),
      ),
    );
  }
}