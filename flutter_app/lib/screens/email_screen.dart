import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:provider/provider.dart';
import '../../providers/student_provider.dart';

class EmailScreen extends StatefulWidget {
  const EmailScreen({Key? key}) : super(key: key);

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
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error fetching subjects: $e');
    }
  }

  Future<void> _sendEmails() async {
    if (_selectedSubject == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a subject')),
      );
      return;
    }

    setState(() => _isSending = true);

    try {
      final students = context.read<StudentProvider>().students;

      for (final student in students) {
        if (student.email != null && student.email!.isNotEmpty) {
          await supabase.functions.invoke(
            'send-email',
            body: {
              'to': student.email,
              'subject':
                  'Grade Report - $_selectedSubjectName',
              'message': _messageController.text,
            },
          );
        }
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Emails sent successfully')),
        );
        _messageController.clear();
        setState(() => _isSending = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error sending emails: $e')),
        );
        setState(() => _isSending = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Send Grade Reports'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Send Email Reports',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 24),
                  const Text('Select Subject'),
                  const SizedBox(height: 8),
                  DropdownButton<String>(
                    isExpanded: true,
                    value: _selectedSubject,
                    hint: const Text('Choose a subject'),
                    items: _subjects
                        .map((subject) => DropdownMenuItem(
                              value: subject['id'],
                              child: Text(subject['name']),
                              onTap: () {
                                setState(() {
                                  _selectedSubjectName = subject['name'];
                                });
                              },
                            ))
                        .toList(),
                    onChanged: (value) {
                      setState(() => _selectedSubject = value);
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text('Message (Optional)'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText:
                          'Add a custom message to include in the email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    maxLines: 4,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSending ? null : _sendEmails,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: _isSending
                          ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            )
                          : const Text('Send Emails'),
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surfaceContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email Preview',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Subject: Grade Report - $_selectedSubjectName',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'This email will be sent to all students with email addresses on file.',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}
