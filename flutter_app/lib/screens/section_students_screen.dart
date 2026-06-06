import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../models/section.dart';
import '../models/student.dart';
import '../providers/student_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide_in.dart';

class SectionStudentsScreen extends StatefulWidget {
  final Subject subject;
  final Section section;
  const SectionStudentsScreen(
      {super.key, required this.subject, required this.section});

  @override
  State<SectionStudentsScreen> createState() => _SectionStudentsScreenState();
}

class _SectionStudentsScreenState extends State<SectionStudentsScreen> {
  List<Student> _allStudents = [];
  bool _isLoadingExisting = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context
          .read<StudentProvider>()
          .fetchStudents(sectionId: widget.section.id);
    });
  }

  /// Bottom sheet to choose between adding a new student or an existing one
  void _showAddStudentSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark
              ? const Color(0xFF1A0B2E)
              : lSurface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16, top: 8),
                decoration: BoxDecoration(
                  color: kGlassBorder,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              Text('Add Student',
                  style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              // Option 1: Create new
              GlassCard(
                padding: const EdgeInsets.all(16),
                onTap: () {
                  Navigator.pop(ctx);
                  _showCreateNewStudentDialog();
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [kAccent2, kAccent1]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.person_add_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Create New Student',
                              style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('Add a brand new student to this section',
                              style: TextStyle(color: context.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: context.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Option 2: Add existing
              GlassCard(
                padding: const EdgeInsets.all(16),
                onTap: () {
                  Navigator.pop(ctx);
                  _showAddExistingStudentDialog();
                },
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(Icons.group_add_rounded, color: Colors.white, size: 22),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Add Existing Student',
                              style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 15)),
                          const SizedBox(height: 2),
                          Text('Assign a student already in the system to this section',
                              style: TextStyle(color: context.textSecondary, fontSize: 12)),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded, color: context.textSecondary),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }

  /// Fetch all students and show a picker to add existing ones to this section
  void _showAddExistingStudentDialog() async {
    setState(() => _isLoadingExisting = true);

    // Fetch all students (no section filter) to find unassigned ones
    final allData = await ApiService().get('/students/');
    final sectionStudents = context.read<StudentProvider>().students;
    final sectionStudentIds = sectionStudents.map((s) => s.id).toSet();

    List<Student> existingStudents = allData
        .map((item) => Student.fromJson(item))
        .where((s) => !sectionStudentIds.contains(s.id))
        .toList();

    if (!mounted) return;
    setState(() => _isLoadingExisting = false);

    String? searchQuery;
    List<Student> filtered = List.from(existingStudents);

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setDialogState) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Add Existing Student',
                    style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                Text('Select a student to add to Section ${widget.section.sectionLabel}',
                    style: TextStyle(color: context.textSecondary, fontSize: 12)),
                const SizedBox(height: 16),
                // Search field
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: kGlass,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kGlassBorder),
                  ),
                  child: TextField(
                    style: TextStyle(color: context.textPrimary, fontSize: 14),
                    decoration: InputDecoration(
                      border: InputBorder.none,
                      hintText: 'Search students...',
                      hintStyle: TextStyle(color: context.textSecondary, fontSize: 13),
                      prefixIcon: Icon(Icons.search_rounded, color: context.textSecondary, size: 20),
                    ),
                    onChanged: (v) {
                      searchQuery = v.toLowerCase();
                      setDialogState(() {
                        if (searchQuery!.isEmpty) {
                          filtered = List.from(existingStudents);
                        } else {
                          filtered = existingStudents.where((s) =>
                            s.fullName.toLowerCase().contains(searchQuery!) ||
                            s.studentId.toLowerCase().contains(searchQuery!) ||
                            s.course.toLowerCase().contains(searchQuery!)
                          ).toList();
                        }
                      });
                    },
                  ),
                ),
                const SizedBox(height: 12),
                if (filtered.isEmpty)
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(Icons.people_outline_rounded, size: 40, color: context.textSecondary),
                        const SizedBox(height: 8),
                        Text(
                          existingStudents.isEmpty
                              ? 'All students are already in this section'
                              : 'No students match your search',
                          style: TextStyle(color: context.textSecondary, fontSize: 13),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                else
                  SizedBox(
                    height: 300,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: filtered.length,
                      itemBuilder: (ctx, index) {
                        final student = filtered[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 6),
                          child: GlassCard(
                            padding: const EdgeInsets.all(12),
                            onTap: () async {
                              final provider = context.read<StudentProvider>();
                              final updated = Student(
                                id: student.id,
                                studentId: student.studentId,
                                firstName: student.firstName,
                                lastName: student.lastName,
                                email: student.email,
                                course: student.course,
                                yearLevel: student.yearLevel,
                                sectionId: widget.section.id,
                              );
                              final success = await provider.updateStudent(student.id!, updated);
                              if (success && mounted) {
                                Navigator.pop(ctx);
                                provider.fetchStudents(sectionId: widget.section.id);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text('${student.fullName} added to Section ${widget.section.sectionLabel}'),
                                    backgroundColor: const Color(0xFF43E97B),
                                  ),
                                );
                              }
                            },
                            child: Row(
                              children: [
                                CircleAvatar(
                                  radius: 18,
                                  backgroundColor: kAccent1.withValues(alpha: 0.2),
                                  child: Text(
                                    student.firstName.isNotEmpty ? student.firstName[0].toUpperCase() : '?',
                                    style: TextStyle(color: kAccent1, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(student.fullName, style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
                                      const SizedBox(height: 2),
                                      Text('${student.studentId} • ${student.course} Y${student.yearLevel}',
                                          style: TextStyle(color: context.textSecondary, fontSize: 11)),
                                    ],
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF43E97B).withValues(alpha: 0.15),
                                    borderRadius: BorderRadius.circular(8),
                                    border: Border.all(color: const Color(0xFF43E97B).withValues(alpha: 0.3)),
                                  ),
                                  child: const Text('Add', style: TextStyle(color: Color(0xFF43E97B), fontSize: 11, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onTap: () => Navigator.pop(ctx),
                    child: Center(
                      child: Text('Cancel', style: TextStyle(color: context.textSecondary)),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showCreateNewStudentDialog() {
    final idController = TextEditingController();
    final firstController = TextEditingController();
    final lastController = TextEditingController();
    final emailController = TextEditingController();
    final courseController = TextEditingController();
    int yearLevel = 1;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add New Student',
                      style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  GlassTextField(
                      controller: idController,
                      label: 'Student ID',
                      prefixIcon: Icons.badge_rounded),
                  const SizedBox(height: 12),
                  GlassTextField(
                      controller: firstController,
                      label: 'First Name',
                      prefixIcon: Icons.person_rounded),
                  const SizedBox(height: 12),
                  GlassTextField(
                      controller: lastController,
                      label: 'Last Name',
                      prefixIcon: Icons.person_outline_rounded),
                  const SizedBox(height: 12),
                  GlassTextField(
                      controller: emailController,
                      label: 'Email (optional)',
                      prefixIcon: Icons.email_rounded),
                  const SizedBox(height: 12),
                  GlassTextField(
                      controller: courseController,
                      label: 'Course',
                      prefixIcon: Icons.school_rounded),
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
                        dropdownColor:
                            Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1A1A3E)
                                : lSurface,
                        style: TextStyle(color: context.textPrimary),
                        items: List.generate(
                          5,
                          (i) => DropdownMenuItem(
                              value: i + 1, child: Text('Year ${i + 1}')),
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
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onTap: () => Navigator.pop(ctx),
                          child: const Center(
                              child: Text('Cancel',
                                  style: TextStyle(color: kAccent2))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientButton(
                          colors: const [kAccent2, kAccent1],
                          onPressed: () async {
                            final student = Student(
                              studentId: idController.text.trim(),
                              firstName: firstController.text.trim(),
                              lastName: lastController.text.trim(),
                              email: emailController.text.trim().isEmpty
                                  ? null
                                  : emailController.text.trim(),
                              course: courseController.text.trim(),
                              yearLevel: yearLevel,
                              sectionId: widget.section.id,
                            );
                            final provider = context.read<StudentProvider>();
                            final nav = Navigator.of(ctx);
                            final success = await provider.addStudent(student);
                            if (success && mounted) {
                              nav.pop(ctx);
                              provider.fetchStudents(
                                  sectionId: widget.section.id);
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
                child: FadeSlideIn(
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => context.pop(),
                        child: const GlassCard(
                          padding: EdgeInsets.all(10),
                          borderRadius: 12,
                          child: Icon(Icons.arrow_back_rounded,
                              color: kAccent2, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                                'Section ${widget.section.sectionLabel}',
                                style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                '${widget.subject.name} • ${widget.section.roomNumber}',
                                style: TextStyle(
                                    color: context.textSecondary,
                                    fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<StudentProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(color: kAccent2));
                    }
                    final students = provider.students
                        .where((s) => s.sectionId == widget.section.id)
                        .toList();
                    if (students.isEmpty) {
                      return Center(
                        child: GlassCard(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.person_add_rounded,
                                  size: 64, color: kAccent2),
                              const SizedBox(height: 16),
                              const Text('No students yet',
                                  style: TextStyle(
                                      color: kAccent2,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text('Tap + to add a student',
                                  style:
                                      TextStyle(color: context.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: students.length,
                      itemBuilder: (context, index) {
                        final student = students[index];
                        return FadeSlideIn(
                          delay: Duration(milliseconds: 60 * index),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              onTap: () => context.push(
                                '/subjects/${widget.subject.id}/sections/${widget.section.id}/students/${student.id}',
                                extra: {
                                  'subject': widget.subject,
                                  'section': widget.section,
                                  'student': student,
                                },
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                          colors: [
                                            Color(0xFF6C63FF),
                                            Color(0xFF9B8FFF)
                                          ]),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(
                                        student.firstName.isNotEmpty
                                            ? student.firstName[0].toUpperCase()
                                            : '?',
                                        style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 20),
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
                                            style: TextStyle(
                                                color: context.textPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Text(
                                            '${student.studentId} • ${student.course} Y${student.yearLevel}',
                                            style: TextStyle(
                                                color: context.textSecondary,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  const Icon(Icons.chevron_right_rounded,
                                      color: kAccent2),
                                  PopupMenuButton(
                                    icon: const Icon(Icons.more_vert_rounded,
                                        color: kAccent2),
                                    color: Theme.of(context).brightness ==
                                            Brightness.dark
                                        ? const Color(0xFF1A1A3E)
                                        : lSurface,
                                    itemBuilder: (_) => [
                                      PopupMenuItem(
                                        child: const Row(children: [
                                          Icon(Icons.delete_rounded,
                                              color: kAccent3, size: 18),
                                          SizedBox(width: 8),
                                          Text('Delete',
                                              style:
                                                  TextStyle(color: kAccent3)),
                                        ]),
                                        onTap: () async {
                                          await provider
                                              .deleteStudent(student.id!);
                                          provider.fetchStudents(
                                              sectionId: widget.section.id);
                                        },
                                      ),
                                    ],
                                  ),
                                ],
                              ),
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
          gradient: const LinearGradient(colors: [kAccent2, kAccent1]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: kAccent2.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddStudentSheet,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
