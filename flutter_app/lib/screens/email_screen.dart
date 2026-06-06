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
  List<dynamic> _sections = [];
  List<dynamic> _exams = [];
  String? _selectedSubject;
  String? _selectedSubjectName;
  String? _selectedSubjectCode;
  String? _selectedSection;
  String? _selectedExam;
  String _mode = 'bulk_all'; // 'bulk_all', 'bulk_section', 'individual'
  bool _isLoading = true;
  bool _isSending = false;
  final _messageController = TextEditingController();
  String _individualEmail = '';
  String _individualName = '';

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
      final data = await api.get('/subjects/');

      // normalize dynamic response to List
      List items;
      if (data is List) {
        items = data;
      } else if (data is Map && data['items'] is List) {
        items = data['items'] as List;
      } else {
        items = [];
      }

      if (mounted) {
        setState(() {
          _subjects = items;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _fetchSections() async {
    try {
      final sections = await api.get('/sections/');
      if (mounted) setState(() => _sections = sections);
    } catch (_) {}
  }

  Future<void> _fetchExams(String subjectId) async {
    try {
      final exams = await api.get('/exams/?subject_id=$subjectId');
      if (mounted) setState(() => _exams = exams);
    } catch (_) {}
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
          final res = await api.get('/exam-results/?student_id=${student.id}');
          List results;
          if (res is List) {
            results = res;
          } else if (res is Map && res['items'] is List) {
            results = res['items'] as List;
          } else {
            results = [];
          }

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
          // continue on per-student failures
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
          SnackBar(content: Text('Error: $e'), backgroundColor: kAccent3),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // Send grade email to a single student
  Future<void> _sendIndividualEmail() async {
    if (_individualEmail.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter recipient email'), backgroundColor: kAccent3),
      );
      return;
    }
    setState(() => _isSending = true);
    try {
      // Find the student by email (across all students) to get their ID
      final students = context.read<StudentProvider>().students;
      final student = students.firstWhere(
        (s) => s.email != null && s.email!.toLowerCase() == _individualEmail.toLowerCase(),
        orElse: () => students.first,
      );
      String? studentId = student.id;
      if (studentId == null) {
        // Fetch students if not in provider yet
        await context.read<StudentProvider>().fetchStudents();
        final all = context.read<StudentProvider>().students;
        final found = all.firstWhere(
          (s) => s.email != null && s.email!.toLowerCase() == _individualEmail.toLowerCase(),
          orElse: () => all.isNotEmpty ? all.first : all.first,
        );
        studentId = found.id;
      }
      if (studentId == null) throw 'Student not found';

      Map<String, dynamic>? latestResult;
      try {
        final results = await api.get('/results/?student_id=$studentId');
        if (results.isNotEmpty) latestResult = results.first as Map<String, dynamic>;
      } catch (_) {}

      await api.post('/email/send-grade-report', {
        'student_id': studentId,
        'exam_name': latestResult?['exam_name'] ?? 'N/A',
        'subject_code': _selectedSubjectCode ?? _selectedSubject ?? '',
        'subject_name': _selectedSubjectName ?? '',
        'percentage': (latestResult?['percentage'] ?? 0.0),
        'grade': latestResult?['grade'] ?? 'N/A',
        'grade_point': (latestResult?['grade_point'] ?? 0.0),
        'remarks': latestResult?['remarks'] ?? 'N/A',
        'custom_message': _messageController.text.isNotEmpty
            ? _messageController.text
            : null,
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Email sent to $_individualEmail'),
            backgroundColor: const Color(0xFF43E97B),
          ),
        );
        _messageController.clear();
        setState(() {
          _individualEmail = '';
          _individualName = '';
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: kAccent3),
        );
      }
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  // Send to all students in a specific section
  Future<void> _sendSectionBulk() async {
    if (_selectedSubject == null || _selectedSection == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select subject and section'), backgroundColor: kAccent3),
      );
      return;
    }
    setState(() => _isSending = true);
    try {
      // Get students for this section
      final allStudents = await api.get('/students/?section_id=$_selectedSection');
      int sentCount = 0;
      for (final s in allStudents) {
        if (s['email'] == null || (s['email'] as String).isEmpty) continue;
        try {
          final results = await api.get('/results/?student_id=${s['id']}');
          Map<String, dynamic>? latest;
          if (results.isNotEmpty) latest = results.first as Map<String, dynamic>;
          await api.post('/email/send-grade-report', {
            'student_id': s['id'],
            'exam_name': latest?['exam_name'] ?? 'N/A',
            'subject_code': _selectedSubjectCode ?? _selectedSubject ?? '',
            'subject_name': _selectedSubjectName ?? '',
            'percentage': (latest?['percentage'] ?? 0.0),
            'grade': latest?['grade'] ?? 'N/A',
            'grade_point': (latest?['grade_point'] ?? 0.0),
            'remarks': latest?['remarks'] ?? 'N/A',
            'custom_message': _messageController.text.isNotEmpty
                ? _messageController.text
                : null,
          });
          sentCount++;
        } catch (_) {}
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Sent $sentCount emails to section'),
            backgroundColor: const Color(0xFF43E97B),
          ),
        );
        _messageController.clear();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: $e'), backgroundColor: kAccent3),
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
                      const SizedBox(height: 16),

                      // Mode selector tabs
                      Row(
                        children: [
                          _buildModeChip('bulk_all', Icons.group_rounded, 'All Students'),
                          const SizedBox(width: 8),
                          _buildModeChip('bulk_section', Icons.class_rounded, 'By Section'),
                          const SizedBox(width: 8),
                          _buildModeChip('individual', Icons.person_rounded, 'Individual'),
                        ],
                      ),
                      const SizedBox(height: 16),

                      GlassCard(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Select Subject',
                                style: TextStyle(color: ts, fontSize: 13)),
                            const SizedBox(height: 10),
                            _buildSubjectDropdown(),

                            // Section selector (only for section mode)
                            if (_mode == 'bulk_section') ...[
                              const SizedBox(height: 16),
                              Text('Select Section',
                                  style: TextStyle(color: ts, fontSize: 13)),
                              const SizedBox(height: 10),
                              _buildSectionDropdown(),
                            ],

                            // Individual email input
                            if (_mode == 'individual') ...[
                              const SizedBox(height: 16),
                              Text('Recipient Details',
                                  style: TextStyle(color: ts, fontSize: 13)),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: kGlass,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: kGlassBorder),
                                ),
                                child: TextField(
                                  style: TextStyle(color: tp),
                                  onChanged: (v) => _individualName = v,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Recipient name (optional)',
                                    hintStyle: TextStyle(color: ts, fontSize: 13),
                                    prefixIcon: Icon(Icons.person_rounded, color: ts, size: 18),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12),
                                decoration: BoxDecoration(
                                  color: kGlass,
                                  borderRadius: BorderRadius.circular(14),
                                  border: Border.all(color: kGlassBorder),
                                ),
                                child: TextField(
                                  style: TextStyle(color: tp),
                                  keyboardType: TextInputType.emailAddress,
                                  onChanged: (v) => _individualEmail = v,
                                  decoration: InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'recipient@email.com',
                                    hintStyle: TextStyle(color: ts, fontSize: 13),
                                    prefixIcon: Icon(Icons.email_rounded, color: ts, size: 18),
                                  ),
                                ),
                              ),
                            ],

                            const SizedBox(height: 20),
                            Text('Message (Optional)',
                                style: TextStyle(color: ts, fontSize: 13)),
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
                                onPressed: _isSending
                                    ? null
                                    : _mode == 'individual'
                                        ? _sendIndividualEmail
                                        : _mode == 'bulk_section'
                                            ? _sendSectionBulk
                                            : _sendEmails,
                                colors: _mode == 'individual'
                                    ? const [Color(0xFF43E97B), Color(0xFF38F9D7)]
                                    : const [Color(0xFFF7971E), Color(0xFFFFD200)],
                                child: _isSending
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2, color: Colors.white),
                                      )
                                    : Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            _mode == 'individual'
                                                ? Icons.send_rounded
                                                : Icons.mark_email_read_rounded,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            _mode == 'individual'
                                                ? 'Send to Individual'
                                                : _mode == 'bulk_section'
                                                    ? 'Send to Section'
                                                    : 'Send to All',
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
                                        color: tp, fontWeight: FontWeight.w600)),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Subject: Grade Report - ${_selectedSubjectName ?? 'Not selected'}',
                              style: TextStyle(color: ts, fontSize: 13),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              _mode == 'individual'
                                  ? 'To: ${_individualEmail.isEmpty ? '(enter email above)' : _individualEmail}'
                                  : _mode == 'bulk_section'
                                      ? 'To: ${_studentsInSelectedSection} students in section'
                                      : 'To: $studentsWithEmail students with email addresses',
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

  int get _studentsInSelectedSection {
    if (_selectedSection == null) return 0;
    return context
        .read<StudentProvider>()
        .students
        .where((s) => s.sectionId == _selectedSection)
        .length;
  }

  Widget _buildModeChip(String mode, IconData icon, String label) {
    final isSelected = _mode == mode;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          setState(() {
            _mode = mode;
            if (mode == 'bulk_section' && _sections.isEmpty) {
              _fetchSections();
            }
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            gradient: isSelected
                ? const LinearGradient(colors: [kAccent1, kAccent2])
                : null,
            color: isSelected ? null : kGlass,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected ? Colors.transparent : kGlassBorder,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  color: isSelected ? Colors.white : context.textSecondary,
                  size: 18),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      color: isSelected ? Colors.white : context.textSecondary,
                      fontSize: 11,
                      fontWeight: FontWeight.w600)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSubjectDropdown() {
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
          value: _selectedSubject,
          isExpanded: true,
          dropdownColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A3E)
              : lSurface,
          style: TextStyle(color: tp),
          hint: Text('Choose a subject', style: TextStyle(color: ts)),
          items: _subjects
              .map((s) => DropdownMenuItem(
                    value: s['id'] as String,
                    child: Text(s['name'] ?? ''),
                  ))
              .toList(),
          onChanged: (value) {
            final subject =
                _subjects.firstWhere((s) => s['id'] == value);
            setState(() {
              _selectedSubject = value;
              _selectedSubjectName = subject['name'];
              _selectedSubjectCode = subject['code'] ?? subject['name'];
            });
            _fetchExams(value!);
          },
        ),
      ),
    );
  }

  Widget _buildSectionDropdown() {
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
          value: _selectedSection,
          isExpanded: true,
          dropdownColor: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A1A3E)
              : lSurface,
          style: TextStyle(color: tp),
          hint: Text('Choose a section', style: TextStyle(color: ts)),
          items: _sections.map((s) {
            return DropdownMenuItem(
              value: s['id'] as String,
              child: Text('Section ${s['section_label']} • ${s['room_number'] ?? ''}'),
            );
          }).toList(),
          onChanged: (value) {
            setState(() => _selectedSection = value);
          },
        ),
      ),
    );
  }
}
