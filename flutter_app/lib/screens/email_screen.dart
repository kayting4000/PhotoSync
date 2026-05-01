import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../theme/app_theme.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({super.key});

  @override
  State<EmailScreen> createState() => _EmailScreenState();
}

class _EmailScreenState extends State<EmailScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> _subjects = [];
  String? _selectedSubject;
  String? _selectedSubjectName;
  bool _isLoading = true;
  bool _isSending = false;
  final _messageController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _fetchSubjects();
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _fetchSubjects() async {
    try {
      final subjects = await supabase.from('subjects').select();
      if (mounted) {
        setState(() {
          _subjects = subjects as List<dynamic>;
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
      for (final student in students) {
        if (student.email != null && student.email!.isNotEmpty) {
          await supabase.functions.invoke('send-email', body: {
            'to': student.email,
            'subject': 'Grade Report - $_selectedSubjectName',
            'message': _messageController.text,
          });
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Emails sent successfully!'),
              backgroundColor: kAccent1),
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
    return Scaffold(
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
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: GlassCard(
                              padding: const EdgeInsets.all(10),
                              borderRadius: 12,
                              child: const Icon(
                                  Icons.arrow_back_ios_new_rounded,
                                  color: kTextPrimary,
                                  size: 18),
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
                                            child: Text(s['name']),
                                          ))
                                      .toList(),
                                  onChanged: (value) {
                                    final subject = _subjects
                                        .firstWhere((s) => s['id'] == value);
                                    setState(() {
                                      _selectedSubject = value;
                                      _selectedSubjectName = subject['name'];
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
                            Row(
                              children: const [
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
                            const Text(
                              'Will be sent to all students with email addresses on file.',
                              style: TextStyle(
                                  color: kTextSecondary, fontSize: 12),
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
