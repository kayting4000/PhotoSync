import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/student_provider.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';

class StudentsScreen extends StatefulWidget {
  const StudentsScreen({super.key});

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
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Add Student',
                    style: TextStyle(
                        color: kTextPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                GlassTextField(
                    controller: studentIdController,
                    label: 'Student ID',
                    prefixIcon: Icons.badge_outlined),
                const SizedBox(height: 12),
                GlassTextField(
                    controller: firstNameController,
                    label: 'First Name',
                    prefixIcon: Icons.person_outline),
                const SizedBox(height: 12),
                GlassTextField(
                    controller: lastNameController,
                    label: 'Last Name',
                    prefixIcon: Icons.person_outline),
                const SizedBox(height: 12),
                GlassTextField(
                    controller: emailController,
                    label: 'Email',
                    prefixIcon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress),
                const SizedBox(height: 12),
                GlassTextField(
                    controller: courseController,
                    label: 'Course',
                    prefixIcon: Icons.school_outlined),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: kGlass,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kGlassBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<int>(
                      value: yearLevel,
                      isExpanded: true,
                      dropdownColor: const Color(0xFF1A1A3E),
                      style: const TextStyle(color: kTextPrimary),
                      items: List.generate(
                        4,
                        (i) => DropdownMenuItem(
                          value: i + 1,
                          child: Text('Year ${i + 1}'),
                        ),
                      ),
                      onChanged: (v) {
                        if (v != null) setState(() => yearLevel = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: const Center(
                            child: Text('Cancel',
                                style: TextStyle(color: kTextSecondary)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        onPressed: () async {
                          final student = Student(
                            studentId: studentIdController.text,
                            firstName: firstNameController.text,
                            lastName: lastNameController.text,
                            email: emailController.text,
                            course: courseController.text,
                            yearLevel: yearLevel,
                          );
                          final success = await context
                              .read<StudentProvider>()
                              .addStudent(student);
                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                  content: Text('Student added!'),
                                  backgroundColor: kAccent1),
                            );
                          }
                        },
                        child: const Text('Add',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/dashboard'),
                      child: GlassCard(
                        padding: const EdgeInsets.all(10),
                        borderRadius: 12,
                        child: const Icon(Icons.arrow_back_ios_new_rounded,
                            color: kTextPrimary, size: 18),
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Text('Students',
                        style: TextStyle(
                            color: kTextPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<StudentProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(color: kAccent1));
                    }
                    if (provider.students.isEmpty) {
                      return Center(
                        child: GlassCard(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.people_outline,
                                  size: 64, color: kTextSecondary),
                              SizedBox(height: 16),
                              Text('No students yet',
                                  style: TextStyle(
                                      color: kTextPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 8),
                              Text('Tap + to add a student',
                                  style: TextStyle(color: kTextSecondary)),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.students.length,
                      itemBuilder: (context, index) {
                        final student = provider.students[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: GlassCard(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                        colors: [kAccent1, kAccent2]),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      student.firstName[0].toUpperCase(),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(student.fullName,
                                          style: const TextStyle(
                                              color: kTextPrimary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${student.studentId} • ${student.course}',
                                          style: const TextStyle(
                                              color: kTextSecondary,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
                                  icon: const Icon(Icons.more_vert_rounded,
                                      color: kTextSecondary),
                                  color: const Color(0xFF1A1A3E),
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      child: const Text('Delete',
                                          style:
                                              TextStyle(color: kAccent3)),
                                      onTap: () => context
                                          .read<StudentProvider>()
                                          .deleteStudent(student.id!),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(colors: [kAccent1, kAccent2]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: kAccent1.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
