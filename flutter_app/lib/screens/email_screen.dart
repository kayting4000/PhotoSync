import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/api_service.dart';
import '../providers/student_provider.dart';
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
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
    Provider.of<StudentProvider>(context, listen: false).fetchStudents();
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

      for (final student in students) {
        if (student.email == null || student.email!.isEmpty) continue;
        if (student.id == null) continue;

        try {
          final results = await api.get('/exam-results/?student_id=${student.id}');
          if (results.isNotEmpty) {
            final latest = results.first as Map<String, dynamic>;

            await api.post('/email/send-grade-report', {
              'student_id': student.id!,
              'exam_name': latest['exam_name'] ?? 'N/A',
              'subject_code': _selectedSubjectCode ?? _selectedSubject ?? '',
              'subject_name': _selectedSubjectName ?? '',
              'percentage': (latest['percentage'] ?? 0.0),
              'grade': latest['grade'] ?? 'N/A',
              'grade_point': (latest['grade_point'] ?? 0.0),
              'remarks': latest['remarks'] ?? 'N/A',
              'custom_message': _messageController.text.isNotEmpty
                  ? _messageController.text
                  : null,
            });
          } else {
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
            });
          }
          sentCount++;
        } catch (e) {
          continue;
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Emails sent to $sentCount students'),
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
    final tp = context.textPrimary;
    final ts = context.textSecondary;

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
                                    color: kAccent2, size: 20),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Text('Send Grade Reports',
                              style: TextStyle(
                                  color: tp,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Select Subject',
                                style: TextStyle(
                                    color: ts, fontSize: 13)),
                            const SizedBox(height: 10),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12),
                              decoration: BoxDecoration(
                                color: kGlass,
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: kGlassBorder),
                              ),
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  value: _selectedSubject,
                                  isExpanded: true,
                                  dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A3E) : lSurface,
                                  style: TextStyle(color: tp),
                                  hint: Text('Choose a subject',
                                      style: TextStyle(color: ts)),
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
                            Text('Message (Optional)',
                                style: TextStyle(
                                    color: ts, fontSize: 13)),
                            const SizedBox(height: 10),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(14),
                              child: TextField(
                                controller: _messageController,
                                maxLines: 4,
                                style: TextStyle(color: tp),
                                decoration: InputDecoration(
                                  hintText: 'Add a custom message...',
                                  hintStyle: TextStyle(color: ts),
                                  filled: true,
                                  fillColor: kGlass,
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: kGlassBorder),
                                  ),
                                  enabledBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: kGlassBorder),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(color: kAccent1, width: 1.5),
                                  ),
                                ),
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
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(Icons.mark_email_read_rounded,
                                              color: Colors.white, size: 18),
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
                            Row(
                              children: [
                                const Icon(Icons.preview_rounded, color: kAccent1, size: 18),
                                const SizedBox(width: 8),
                                Text('Email Preview',
                                    style: TextStyle(
                                        color: tp,
                                        fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Subject: Grade Report - ${_selectedSubjectName ?? 'Not selected'}',
                              style: TextStyle(color: ts, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'To: $studentsWithEmail students with email addresses',
                              style: TextStyle(color: ts, fontSize: 12),
                            ),
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