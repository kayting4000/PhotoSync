import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/student_provider.dart';
import '../../models/student.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({Key? key}) : super(key: key);

  @override
  State<StudentsScreen> createState() => _StudentsScreenState();
}

class _StudentsScreenState extends State<StudentsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<StudentProvider>().fetchStudents();
    });
  }

  void _showAddDialog() {
    final studentIdController = TextEditingController();
    final firstNameController = TextEditingController();
    final lastNameController = TextEditingController();
    final emailController = TextEditingController();
    final courseController = TextEditingController();
    int yearLevel = 1;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Add Student'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: studentIdController,
                  decoration: const InputDecoration(labelText: 'Student ID'),
                ),
                TextField(
                  controller: firstNameController,
                  decoration: const InputDecoration(labelText: 'First Name'),
                ),
                TextField(
                  controller: lastNameController,
                  decoration: const InputDecoration(labelText: 'Last Name'),
                ),
                TextField(
                  controller: emailController,
                  decoration: const InputDecoration(labelText: 'Email'),
                  keyboardType: TextInputType.emailAddress,
                ),
                TextField(
                  controller: courseController,
                  decoration: const InputDecoration(labelText: 'Course'),
                ),
                const SizedBox(height: 16),
                DropdownButton<int>(
                  value: yearLevel,
                  isExpanded: true,
                  items: List.generate(
                    4,
                    (index) => DropdownMenuItem(
                      value: index + 1,
                      child: Text('Year ${index + 1}'),
                    ),
                  ),
                  onChanged: (value) {
                    if (value != null) {
                      setState(() => yearLevel = value);
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final student = Student(
                  studentId: studentIdController.text,
                  firstName: firstNameController.text,
                  lastName: lastNameController.text,
                  email: emailController.text,
                  course: courseController.text,
                  yearLevel: yearLevel,
                );

                final success =
                    await context.read<StudentProvider>().addStudent(student);
                if (success && mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Student added successfully')),
                  );
                }
              },
              child: const Text('Add'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Students'),
      ),
      body: Consumer<StudentProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.students.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline,
                      size: 64,
                      color: Theme.of(context).colorScheme.outline),
                  const SizedBox(height: 16),
                  Text(
                    'No students yet',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  const Text('Add a student to get started'),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: provider.students.length,
            itemBuilder: (context, index) {
              final student = provider.students[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: CircleAvatar(
                    child: Text(student.firstName[0].toUpperCase()),
                  ),
                  title: Text(student.fullName),
                  subtitle: Text('${student.studentId} • ${student.course}'),
                  trailing: PopupMenuButton(
                    itemBuilder: (context) => [
                      PopupMenuItem(
                        child: const Text('Edit'),
                        onTap: () {
                          // TODO: Implement edit functionality
                        },
                      ),
                      PopupMenuItem(
                        child: const Text('Delete'),
                        onTap: () {
                          context
                              .read<StudentProvider>()
                              .deleteStudent(student.id!);
                        },
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showAddDialog,
        child: const Icon(Icons.add),
      ),
    );
  }
}
