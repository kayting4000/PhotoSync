import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/student_provider.dart';
import '../providers/exam_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final api = ApiService();
  List<dynamic> _subjects = [];
  String? _selectedSubject;
  String? _selectedSubjectName;
  String? _selectedSubjectCode;
  bool _isLoading = true;
  bool _isSending = false;
  bool _includeScan = false;
  final _messageController = TextEditingController();
  Map<String, bool> _studentHasScan = {};

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
    Provider.of<StudentProvider>(context, listen: false).fetchStudents();
    Provider.of<ExamProvider>(context, listen: false).fetchExams();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchSubjects() async {
    try {
      final subjects = await api.get('/subjects/');
      if (mounted) {
        setState(() {
          _subjects = subjects;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _checkScannedPapers() async {
    if (!_includeScan) return;
    final students = context.read<StudentProvider>().students;
    final exams = context.read<ExamProvider>().exams;
    final Map<String, bool> scanStatus = {};

    for (final student in students) {
      if (student.id == null) continue;
      // Check if any exam result has a scanned image for this student
      for (final exam in exams) {
        if (exam.id == null) continue;
        try {
          final result = await api.getScannedResult(student.id!, exam.id!);
          if (result['has_scan'] == true) {
            scanStatus[student.id!] = true;
            break;
          }
        } catch (_) {
          // No scan found, skip
        }
      }
      if (!scanStatus.containsKey(student.id)) {
        scanStatus[student.id!] = false;
      }
    }

    if (mounted) {
      setState(() => _studentHasScan = scanStatus);
    }
  }

  Future<void> _sendEmails() async {
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please select a subject'),
            backgroundColor: kAccent3),
      );
      return;
    }

    setState(() => _isSending = true);
    try {
      final students = context.read<StudentProvider>().students;
      int sentCount = 0;
      int scanCount = 0;

      for (final student in students) {
        if (student.email == null || student.email!.isEmpty) continue;
        if (student.id == null) continue;

        // Get the latest exam result for this student to get grade info
        try {
          final results = await api.get('/exam-results/?student_id=${student.id}');
          if (results.isNotEmpty) {
            final latest = results.first as Map<String, dynamic>;

            await api.sendGradeReport(
              studentId: student.id!,
              examName: latest['exam_name'] ?? 'N/A',
              subjectCode: _selectedSubjectCode ?? _selectedSubject ?? '',
              subjectName: _selectedSubjectName ?? '',
              percentage: (latest['percentage'] ?? 0.0).toDouble(),
              grade: latest['grade'] ?? 'N/A',
              gradePoint: (latest['grade_point'] ?? 0.0).toDouble(),
              remarks: latest['remarks'] ?? 'N/A',
              customMessage: _messageController.text.isNotEmpty
                  ? _messageController.text
                  : null,
              includeScan: _includeScan,
            );
            sentCount++;
            if (_includeScan && (_studentHasScan[student.id] ?? false)) {
              scanCount++;
            }
          } else {
            // Send without result data if no results yet
            await api.post('/email/send-grade-report', {
              'student_id': student.id!,
              'exam_name': 'N/A',
              'subject_code': _selectedSubjectCode ?? _selectedSubject ?? '',
              'subject_name': _selectedSubjectName ?? '',
              'percentage': 0.0,
              'grade': 'N/A',
              'grade_point': 0.0,
              'remarks': 'No results',
              'custom_message': _messageController.text.isNotEmpty
                  ? _messageController.text
                  : null,
              'include_scan': _includeScan,
            });
            sentCount++;
          }
        } catch (e) {
          // Skip students that fail
          continue;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              scanCount > 0
                  ? 'Emails sent to $sentCount students ($scanCount with scanned test papers)'
                  : 'Emails sent to $sentCount students',
            ),
            backgroundColor: kAccent1,
          ),
        );
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Error: $e'), backgroundColor: kAccent3),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final students = context.watch<StudentProvider>().students;
    final studentsWithEmail = students.where((s) => s.email != null && s.email!.isNotEmpty).length;
    final studentsWithScan = _studentHasScan.values.where((v) => v).length;

    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/email'),
      body: AppBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: kAccent1))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
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
                          const Text('Send Grade Reports',
                              style: TextStyle(
                                  color: kTextPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Select Subject',
                                style: TextStyle(
                                    color: kTextSecondary, fontSize: 13)),
                            const SizedBox(height: 10),
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: kGlass,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: kGlassBorder),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSubject,
                                  isExpanded: true,
                                  dropdownColor: const Color(0xFF1A1A3E),
                                  style:
                                      const TextStyle(color: kTextPrimary),
                                  hint: const Text('Choose a subject',
                                      style:
                                          TextStyle(color: kTextSecondary)),
                                  items: _subjects
                                      .map((s) => DropdownMenuItem(
                                            value: s['id'] as String,
                                            child: Text(s['name'] ?? ''),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    final subject = _subjects
                                        .firstWhere((s) => s['id'] == value);
                                    setState(() {
                                      _selectedSubject = value;
                                      _selectedSubjectName = subject['name'];
                                      _selectedSubjectCode = subject['code'] ?? subject['name'];
                                    });
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text('Message (Optional)',
                                style: TextStyle(
                                    color: kTextSecondary, fontSize: 13)),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: TextField(
                                controller: _messageController,
                                maxLines: 4,
                                style:
                                    const TextStyle(color: kTextPrimary),
                                decoration: InputDecoration(
                                  hintText: 'Add a custom message...',
                                  hintStyle: const TextStyle(
                                      color: kTextSecondary),
                                  filled: true,
                                  fillColor: kGlass,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: kGlassBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: kGlassBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                        color: kAccent1, width: 1.5),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // ─── Include scanned test paper toggle ────────
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: const Color(0x0D6C63FF),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: kGlassBorder),
                              ),
                              child: Row(
                                children: [
                                  GestureDetector(
                                    onTap: () async {
                                      setState(() {
                                        _includeScan = !_includeScan;
                                      });
                                      if (_includeScan) {
                                        await _checkScannedPapers();
                                      }
                                    },
                                    child: Container(
                                      width: 24,
                                      height: 24,
                                      decoration: BoxDecoration(
                                        color: _includeScan
                                            ? kAccent1
                                            : kGlass,
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: _includeScan
                                              ? kAccent1
                                              : kGlassBorder,
                                        ),
                                      ),
                                      child: _includeScan
                                          ? const Icon(Icons.check,
                                              color: Colors.white, size: 18)
                                          : null,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  const Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Include Scanned Test Papers',
                                            style: TextStyle(
                                                color: kTextPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 14)),
                                        SizedBox(height: 2),
                                        Text(
                                          'Attach the student\'s scanned test paper image to the email',
                                          style: TextStyle(
                                              color: kTextSecondary,
                                              fontSize: 12),
                                        ),
                                      ],
                                    ),
                                  ),
                                  if (_includeScan) ...[
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: const Color(0x1A43E97B),
                                        borderRadius:
                                            BorderRadius.circular(8),
                                      ),
                                      child: Text(
                                        '$studentsWithScan with scans',
                                        style: const TextStyle(
                                          color: Color(0xFF43E97B),
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            const SizedBox(height: 24),
                            SizedBox(
                              width: double.infinity,
                              child: GradientButton(
                                onPressed: _isSending ? null : _sendEmails,
                                colors: const [
                                  Color(0xFFF7971E),
                                  Color(0xFFFFD200)
                                ],
                                child: _isSending
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: Colors.white),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                              Icons.mark_email_read_rounded,
                                              color: Colors.white,
                                              size: 18),
                                          SizedBox(width: 8),
                                          Text('Send Emails',
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16)),
                                        ],
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Preview card
                      GlassCard(
                        color: const Color(0x0D6C63FF),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Row(
                              children: [
                                Icon(Icons.preview_rounded,
                                    color: kAccent1, size: 18),
                                SizedBox(width: 8),
                                Text('Email Preview',
                                    style: TextStyle(
                                        color: kTextPrimary,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Subject: Grade Report - ${_selectedSubjectName ?? 'Not selected'}',
                              style: const TextStyle(
                                  color: kTextSecondary, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'To: $studentsWithEmail students with email addresses',
                              style: const TextStyle(
                                  color: kTextSecondary, fontSize: 12),
                            ),
                            if (_includeScan) ...[
                              const SizedBox(height: 4),
                              Text(
                                'Scanned test papers: $studentsWithScan students have scans attached',
                                style: const TextStyle(
                                    color: kAccent2, fontSize: 12),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}