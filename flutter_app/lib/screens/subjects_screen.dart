import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../providers/section_provider.dart';
import '../providers/student_provider.dart';
import '../models/subject.dart';
import '../models/section.dart';
import '../models/student.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  final Map<String, bool> _expandedSubjects = {};
  final Map<String, bool> _expandedSections = {};
  final Map<String, bool> _expandedStudents = {};

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().fetchSubjects();
      context.read<SectionProvider>().fetchSections();
      context.read<StudentProvider>().fetchStudents();
    });
  }

  void _toggleSubject(String subjectId) {
    setState(() {
      _expandedSubjects[subjectId] = !(_expandedSubjects[subjectId] ?? false);
    });
  }

  void _toggleSection(String sectionId) {
    setState(() {
      _expandedSections[sectionId] = !(_expandedSections[sectionId] ?? false);
    });
  }

  void _toggleStudent(String studentId) {
    setState(() {
      _expandedStudents[studentId] = !(_expandedStudents[studentId] ?? false);
    });
  }

  // ─── Add Subject Dialog ───────────────────────────────────────────────────
  void _showAddSubjectDialog() {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    int units = 3;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: SingleChildScrollView(
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Subject',
                      style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  GlassTextField(
                      controller: codeController,
                      label: 'Subject Code',
                      prefixIcon: Icons.tag_rounded),
                  const SizedBox(height: 12),
                  GlassTextField(
                      controller: nameController,
                      label: 'Subject Name',
                      prefixIcon: Icons.menu_book_rounded),
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
                        value: units,
                        isExpanded: true,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : lSurface,
                        style: TextStyle(color: context.textPrimary),
                        items: List.generate(
                          5,
                          (i) => DropdownMenuItem(
                            value: i + 1,
                            child: Text('${i + 1} Unit${i > 0 ? 's' : ''}'),
                          ),
                        ),
                        onChanged: (v) {
                          if (v != null) setState(() => units = v);
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
                          onTap: () => Navigator.pop(context),
                          child: const Center(
                            child: Text('Cancel',
                                style: TextStyle(color: kAccent1)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientButton(
                          onPressed: () async {
                            final subject = Subject(
                              code: codeController.text,
                              name: nameController.text,
                              units: units,
                            );
                            final provider = context.read<SubjectProvider>();
                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(context);
                            final success = await provider.addSubject(subject);
                            if (success && mounted) {
                              nav.pop();
                              messenger.showSnackBar(
                                const SnackBar(
                                    content: Text('Subject added!'),
                                    backgroundColor: kAccent2),
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
      ),
    );
  }

  // ─── Add Section Dialog ───────────────────────────────────────────────────
  void _showAddSectionDialog(String subjectId) {
    final labelController = TextEditingController();
    final roomController = TextEditingController();
    // Pre-fill with next available letter
    final sections = context.read<SectionProvider>().sections
        .where((s) => s.subjectId == subjectId).toList();
    final existingLabels = sections.map((s) => s.sectionLabel).toSet();
    String nextLabel = 'A';
    for (int i = 0; i < 26; i++) {
      final letter = String.fromCharCode(65 + i);
      if (!existingLabels.contains(letter)) {
        nextLabel = letter;
        break;
      }
    }
    labelController.text = nextLabel;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Section',
                  style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GlassTextField(
                  controller: labelController,
                  label: 'Section (A-Z)',
                  prefixIcon: Icons.label_rounded),
              const SizedBox(height: 12),
              GlassTextField(
                  controller: roomController,
                  label: 'Room Number',
                  prefixIcon: Icons.room_rounded),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onTap: () => Navigator.pop(context),
                      child: const Center(
                        child: Text('Cancel',
                            style: TextStyle(color: kAccent1)),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      onPressed: () async {
                        final section = Section(
                          subjectId: subjectId,
                          sectionLabel: labelController.text.toUpperCase(),
                          roomNumber: roomController.text,
                        );
                        final provider = context.read<SectionProvider>();
                        final messenger = ScaffoldMessenger.of(context);
                        final nav = Navigator.of(context);
                        final success = await provider.addSection(section);
                        if (success && mounted) {
                          nav.pop();
                          messenger.showSnackBar(
                            const SnackBar(
                                content: Text('Section added!'),
                                backgroundColor: kAccent2),
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
    );
  }

  // ─── Add Student Dialog ───────────────────────────────────────────────────
  void _showAddStudentDialog(String sectionId) {
    final firstNameController = TextEditingController();
    final miController = TextEditingController();
    final lastNameController = TextEditingController();
    final studentIdController = TextEditingController();
    final emailController = TextEditingController();
    final parentEmailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Student',
                    style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GlassTextField(
                    controller: firstNameController,
                    label: 'First Name',
                    prefixIcon: Icons.person_rounded),
                const SizedBox(height: 12),
                GlassTextField(
                    controller: miController,
                    label: 'Middle Initial',
                    prefixIcon: Icons.short_text_rounded),
                const SizedBox(height: 12),
                GlassTextField(
                    controller: lastNameController,
                    label: 'Last Name',
                    prefixIcon: Icons.person_rounded),
                const SizedBox(height: 12),
                GlassTextField(
                    controller: studentIdController,
                    label: 'Student ID Number',
                    prefixIcon: Icons.badge_rounded),
                const SizedBox(height: 12),
                GlassTextField(
                    controller: emailController,
                    label: 'Student Email',
                    prefixIcon: Icons.email_rounded),
                const SizedBox(height: 12),
                GlassTextField(
                    controller: parentEmailController,
                    label: 'Parent/Guardian Email',
                    prefixIcon: Icons.contact_mail_rounded),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onTap: () => Navigator.pop(context),
                        child: const Center(
                          child: Text('Cancel',
                              style: TextStyle(color: kAccent1)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        onPressed: () async {
                          final provider = context.read<StudentProvider>();
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(context);
                          final student = Student(
                            studentId: studentIdController.text,
                            firstName: firstNameController.text,
                            middleInitial: miController.text,
                            lastName: lastNameController.text,
                            email: emailController.text,
                            parentGuardianEmail: parentEmailController.text,
                            course: '',
                            yearLevel: 1,
                            sectionId: sectionId,
                          );
                          final success = await provider.addStudent(student);
                          if (success && mounted) {
                            nav.pop();
                            messenger.showSnackBar(
                              const SnackBar(
                                  content: Text('Student added!'),
                                  backgroundColor: kAccent2),
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

  // ─── Grade Colors ─────────────────────────────────────────────────────────
  Color _gradeColor(double percentage) {
    if (percentage >= 90) return const Color(0xFF4CAF50);
    if (percentage >= 75) return const Color(0xFF8BC34A);
    if (percentage >= 60) return const Color(0xFFFFC107);
    return const Color(0xFFF44336);
  }

  // ─── Grades Section for a Student ─────────────────────────────────────────
  Widget _buildStudentGrades(String studentId) {
    return Container(
      margin: const EdgeInsets.only(left: 16),
      child: GlassCard(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Grades',
                style: TextStyle(
                    color: kTextPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 13)),
            const SizedBox(height: 8),
            // Preliminary
            _buildGradeRow('Prelim', 85),
            const Divider(color: kGlassBorder, height: 1),
            _buildGradeRow('Midterm', 78),
            const Divider(color: kGlassBorder, height: 1),
            _buildGradeRow('Final', 92),
            const Divider(color: kGlassBorder, height: 1),
            // Grade Components
            const SizedBox(height: 6),
            const Text('Components',
                style: TextStyle(
                    color: kTextSecondary,
                    fontWeight: FontWeight.w600,
                    fontSize: 11)),
            const SizedBox(height: 4),
            _buildComponentRow('Assignment', 90, 100),
            _buildComponentRow('Quiz', 85, 100),
            _buildComponentRow('Oral Recitation', 88, 100),
            _buildComponentRow('Exam', 92, 100),
            const Divider(color: kGlassBorder, height: 1),
            const SizedBox(height: 4),
            // Total
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Total',
                    style: TextStyle(
                        color: kTextPrimary,
                        fontWeight: FontWeight.bold,
                        fontSize: 12)),
                Text('88.75%',
                    style: TextStyle(
                        color: _gradeColor(88.75),
                        fontWeight: FontWeight.bold,
                        fontSize: 13)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGradeRow(String label, double percentage) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: kTextSecondary, fontSize: 12)),
          Row(
            children: [
              Text('$percentage%',
                  style: TextStyle(
                      color: _gradeColor(percentage),
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
              const SizedBox(width: 6),
              SizedBox(
                width: 50,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(
                    value: percentage / 100,
                    minHeight: 4,
                    backgroundColor: kGlass,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        _gradeColor(percentage)),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildComponentRow(String label, int score, int maxScore) {
    final percentage = score / maxScore * 100;
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: const TextStyle(color: kTextSecondary, fontSize: 11)),
          Text('$score/$maxScore',
              style: TextStyle(
                  color: _gradeColor(percentage),
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/subjects'),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(),
                        child: const GlassCard(
                          padding: EdgeInsets.all(10),
                          borderRadius: 12,
                          child: Icon(Icons.menu_rounded,
                              color: kAccent1, size: 20),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text('Subjects',
                        style: TextStyle(
                            color: context.textPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Hierarchy Tree
              Expanded(
                child: Consumer3<SubjectProvider, SectionProvider,
                    StudentProvider>(
                  builder: (context, subjectProvider, sectionProvider,
                      studentProvider, _) {
                    if (subjectProvider.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(
                              color: kAccent1));
                    }

                    if (subjectProvider.subjects.isEmpty) {
                      return const Center(
                        child: GlassCard(
                          padding: EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.menu_book_outlined,
                                  size: 64, color: kAccent1),
                              SizedBox(height: 16),
                              Text('No subjects yet',
                                  style: TextStyle(
                                      color: kAccent1,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 8),
                              Text('Tap + to add a subject',
                                  style: TextStyle(color: kAccent1)),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      itemCount: subjectProvider.subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjectProvider.subjects[index];
                        final isExpanded =
                            _expandedSubjects[subject.id] ?? false;
                        final sections = sectionProvider.sections
                            .where((s) => s.subjectId == subject.id)
                            .toList();

                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8),
                          child: Column(
                            children: [
                              // ─── Subject Card ────────────────────────────────
                              GlassCard(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 14, vertical: 12),
                                onTap: () => _toggleSubject(subject.id!),
                                child: Row(
                                  children: [
                                    Container(
                                      width: 40,
                                      height: 40,
                                      decoration: BoxDecoration(
                                        gradient: const LinearGradient(
                                            colors: [
                                              Color(0xFF555555),
                                              Color(0xFF777777)
                                            ]),
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Center(
                                        child: Icon(
                                          isExpanded
                                              ? Icons.folder_open_rounded
                                              : Icons.folder_rounded,
                                          color: Colors.white,
                                          size: 20,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Text(subject.name,
                                              style: TextStyle(
                                                  color: context.textPrimary,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 14)),
                                          Text(
                                              '${subject.code} \u2022 ${subject.units} unit(s)',
                                              style: TextStyle(
                                                  color:
                                                      context.textSecondary,
                                                  fontSize: 11)),
                                        ],
                                      ),
                                    ),
                                    // Section Count
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: kAccent1.withOpacity(0.2),
                                        borderRadius:
                                            BorderRadius.circular(6),
                                      ),
                                      child: Text(
                                        '${sections.length} section(s)',
                                        style: const TextStyle(
                                            color: kAccent1,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 11),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    // Add Section Button
                                    GestureDetector(
                                      onTap: () {
                                        if (subject.id != null) {
                                          _showAddSectionDialog(subject.id!);
                                        }
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: kAccent1.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(8),
                                        ),
                                        child: const Icon(
                                          Icons.add_rounded,
                                          color: kAccent1,
                                          size: 18,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              // ─── Sections List ──────────────────────────────
                              if (isExpanded)
                                Padding(
                                  padding:
                                      const EdgeInsets.only(left: 12, top: 8),
                                  child: Column(
                                    children: sections.isEmpty
                                        ? [
                                            GlassCard(
                                              padding: const EdgeInsets.all(20),
                                              child: Row(
                                                children: [
                                                  const Icon(
                                                      Icons.info_outline_rounded,
                                                      color: kTextSecondary,
                                                      size: 18),
                                                  const SizedBox(width: 10),
                                                  Text(
                                                    'No sections yet. Tap + to add one.',
                                                    style: TextStyle(
                                                        color: context
                                                            .textSecondary,
                                                        fontSize: 12),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ]
                                        : sections.map((section) {
                                            final isSecExpanded =
                                                _expandedSections[
                                                        section.id] ??
                                                    false;
                                            final students = studentProvider
                                                .students
                                                .where((s) =>
                                                    s.sectionId ==
                                                    section.id)
                                                .toList();

                                            return Column(
                                              children: [
                                                // Section Card
                                                GlassCard(
                                                  padding:
                                                      const EdgeInsets.symmetric(
                                                          horizontal: 14,
                                                          vertical: 10),
                                                  onTap: () => _toggleSection(
                                                      section.id!),
                                                  child: Row(
                                                    children: [
                                                      const SizedBox(width: 16),
                                                      Container(
                                                        width: 32,
                                                        height: 32,
                                                        decoration:
                                                            BoxDecoration(
                                                          color: kAccent2
                                                              .withOpacity(0.2),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(8),
                                                        ),
                                                        child: Center(
                                                          child: Text(
                                                            section
                                                                .sectionLabel,
                                                            style: const TextStyle(
                                                                color:
                                                                    kAccent2,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                fontSize: 14),
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 10),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Text(
                                                              'Section ${section.sectionLabel}',
                                                              style: TextStyle(
                                                                  color: context
                                                                      .textPrimary,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .w600,
                                                                  fontSize:
                                                                      13),
                                                            ),
                                                            Text(
                                                              'Room ${section.roomNumber}',
                                                              style: TextStyle(
                                                                  color: context
                                                                      .textSecondary,
                                                                  fontSize:
                                                                      11),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                      // Student Count
                                                      Container(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 8,
                                                                vertical: 4),
                                                        decoration:
                                                            BoxDecoration(
                                                          color: kAccent2
                                                              .withOpacity(
                                                                  0.15),
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(6),
                                                        ),
                                                        child: Text(
                                                          '${students.length} student(s)',
                                                          style:
                                                              const TextStyle(
                                                            color: kAccent2,
                                                            fontWeight:
                                                                FontWeight.bold,
                                                            fontSize: 11,
                                                          ),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                          width: 8),
                                                      // Add Student
                                                      GestureDetector(
                                                        onTap: () {
                                                          if (section.id !=
                                                              null) {
                                                            _showAddStudentDialog(
                                                                section.id!);
                                                          }
                                                        },
                                                        child: Container(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(8),
                                                          decoration:
                                                              BoxDecoration(
                                                            color: kAccent1
                                                                .withOpacity(
                                                                    0.15),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          child: const Icon(
                                                            Icons
                                                                .person_add_rounded,
                                                            color: kAccent1,
                                                            size: 18,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                // ─── Students List ──────────────
                                                if (isSecExpanded)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 24,
                                                            top: 6,
                                                            bottom: 6),
                                                    child: Column(
                                                      children: students
                                                          .isEmpty
                                                          ? [
                                                              GlassCard(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        16),
                                                                child: Row(
                                                                  children: [
                                                                    const Icon(
                                                                        Icons
                                                                            .person_outline_rounded,
                                                                        color:
                                                                            kTextSecondary,
                                                                        size:
                                                                            16),
                                                                    const SizedBox(
                                                                        width:
                                                                            8),
                                                                    Text(
                                                                      'No students enrolled',
                                                                      style: TextStyle(
                                                                          color: context
                                                                              .textSecondary,
                                                                          fontSize:
                                                                              12),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ]
                                                          : students.map(
                                                              (student) {
                                                              final isStdExpanded =
                                                                  _expandedStudents[
                                                                          student
                                                                              .id] ??
                                                                      false;
                                                              return Padding(
                                                                padding:
                                                                    const EdgeInsets
                                                                        .only(
                                                                        bottom:
                                                                            6),
                                                                child: Column(
                                                                  children: [
                                                                    GlassCard(
                                                                      padding: const EdgeInsets
                                                                          .symmetric(
                                                                          horizontal:
                                                                              12,
                                                                          vertical:
                                                                              10),
                                                                      color: isStdExpanded
                                                                          ? kAccent1
                                                                              .withOpacity(0.1)
                                                                          : null,
                                                                      onTap: () => _toggleStudent(
                                                                          student
                                                                              .id!),
                                                                      child:
                                                                          Row(
                                                                        children: [
                                                                          Container(
                                                                            width:
                                                                                36,
                                                                            height:
                                                                                36,
                                                                            decoration:
                                                                                BoxDecoration(
                                                                              color: kAccent1.withOpacity(0.2),
                                                                              borderRadius: BorderRadius.circular(10),
                                                                            ),
                                                                            child:
                                                                                Center(
                                                                              child: Icon(
                                                                                isStdExpanded ? Icons.expand_more_rounded : Icons.person_rounded,
                                                                                color: kAccent1,
                                                                                size: 18,
                                                                              ),
                                                                            ),
                                                                          ),
                                                                          const SizedBox(
                                                                              width:
                                                                                  10),
                                                                          Expanded(
                                                                            child:
                                                                                Column(
                                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                                              children: [
                                                                                Text(
                                                                                  student.fullName,
                                                                                  style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 13),
                                                                                ),
                                                                                Text(
                                                                                  'ID: ${student.studentId}',
                                                                                  style: TextStyle(color: context.textSecondary, fontSize: 11),
                                                                                ),
                                                                              ],
                                                                            ),
                                                                          ),
                                                                          // Email icons
                                                                          if (student.email != null && student.email!.isNotEmpty)
                                                                            Tooltip(
                                                                              message: 'Student Email: ${student.email}',
                                                                              child: const Padding(
                                                                                padding: EdgeInsets.only(right: 4),
                                                                                child: Icon(Icons.email_rounded, color: kAccent2, size: 16),
                                                                              ),
                                                                            ),
                                                                          if (student.parentGuardianEmail != null && student.parentGuardianEmail!.isNotEmpty)
                                                                            Tooltip(
                                                                              message: 'Parent/Guardian Email: ${student.parentGuardianEmail}',
                                                                              child: Padding(
                                                                                padding: const EdgeInsets.only(right: 4),
                                                                                child: Icon(Icons.contact_mail_rounded, color: kAccent2.withOpacity(0.7), size: 16),
                                                                              ),
                                                                            ),
                                                                        ],
                                                                      ),
                                                                    ),
                                                                    // ─── Grades Section ─────────
                                                                    if (isStdExpanded)
                                                                      Padding(
                                                                        padding:
                                                                            const EdgeInsets.only(left: 16, top: 6),
                                                                        child:
                                                                            _buildStudentGrades(student.id!),
                                                                      ),
                                                                  ],
                                                                ),
                                                              );
                                                            }).toList(),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          }).toList(),
                                  ),
                                ),
                            ],
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
      // FAB to add subject
      floatingActionButton: Container(
        decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF666666), Color(0xFF444444)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 8)),
          ],
        ),
        child: FloatingActionButton(
          onPressed: _showAddSubjectDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}