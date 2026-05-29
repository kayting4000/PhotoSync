import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/exam_provider.dart';
import '../providers/subject_provider.dart';
import '../models/exam.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class ExamsScreen extends StatefulWidget {
  const ExamsScreen({super.key});

  @override
  State<ExamsScreen> createState() => _ExamsScreenState();
}

class _ExamsScreenState extends State<ExamsScreen> {
  String? _filterSubjectId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().fetchSubjects();
      context.read<ExamProvider>().fetchExams();
    });
  }

  String _typeLabel(String type) {
    switch (type) {
      case 'exam': return 'Exam';
      case 'quiz': return 'Quiz';
      case 'assignment': return 'Assignment';
      case 'performance_task': return 'Performance Task';
      default: return type[0].toUpperCase() + type.substring(1);
    }
  }

  Color _typeColor(String type) {
    switch (type) {
      case 'exam': return const Color(0xFF6C63FF);
      case 'quiz': return kAccent2;
      case 'assignment': return const Color(0xFF43E97B);
      case 'performance_task': return const Color(0xFFF7971E);
      default: return kAccent1;
    }
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    final itemsController = TextEditingController(text: '50');
    final pointsController = TextEditingController(text: '1.0');
    final passingController = TextEditingController();
    String componentType = 'exam';
    String? selectedSubjectId;

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
                  Text('Create Exam',
                      style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  // Subject dropdown
                  Consumer<SubjectProvider>(
                    builder: (context, subjectProvider, _) {
                      return Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: kGlass,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: kGlassBorder),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            value: selectedSubjectId,
                            isExpanded: true,
                            hint: Text('Select Subject',
                                style: TextStyle(color: context.textSecondary)),
                            dropdownColor: Theme.of(context).brightness == Brightness.dark
                                ? const Color(0xFF1A1A3E)
                                : lSurface,
                            style: TextStyle(color: context.textPrimary),
                            items: subjectProvider.subjects.map((s) =>
                                DropdownMenuItem<String>(
                                  value: s.id,
                                  child: Text('${s.code} ${s.name}',
                                      style: TextStyle(color: context.textPrimary)),
                                )).toList(),
                            onChanged: (v) => setState(() => selectedSubjectId = v),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                      controller: nameController,
                      label: 'Exam Name',
                      prefixIcon: Icons.label_rounded),
                  const SizedBox(height: 12),
                  // Type dropdown
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: kGlass,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kGlassBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: componentType,
                        isExpanded: true,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1A1A3E)
                            : lSurface,
                        style: TextStyle(color: context.textPrimary),
                        items: const [
                          DropdownMenuItem(value: 'exam', child: Text('Exam')),
                          DropdownMenuItem(value: 'quiz', child: Text('Quiz')),
                          DropdownMenuItem(value: 'assignment', child: Text('Assignment')),
                          DropdownMenuItem(value: 'performance_task', child: Text('Performance Task')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => componentType = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                      controller: itemsController,
                      label: 'Total Items',
                      prefixIcon: Icons.format_list_numbered_rounded,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  GlassTextField(
                      controller: pointsController,
                      label: 'Points per Item',
                      prefixIcon: Icons.star_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 12),
                  GlassTextField(
                      controller: passingController,
                      label: 'Passing Score (optional)',
                      prefixIcon: Icons.check_circle_outline_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onTap: () => Navigator.pop(context),
                          child: const Center(
                              child: Text('Cancel', style: TextStyle(color: kAccent2))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientButton(
                          colors: const [kAccent2, kAccent1],
                          onPressed: () async {
                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Enter exam name'),
                                      backgroundColor: Colors.red));
                              return;
                            }
                            if (selectedSubjectId == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Select a subject'),
                                      backgroundColor: Colors.red));
                              return;
                            }
                            final exam = Exam(
                              subjectId: selectedSubjectId!,
                              name: nameController.text.trim(),
                              componentType: componentType,
                              totalItems: int.tryParse(itemsController.text) ?? 50,
                              pointsPerItem: double.tryParse(pointsController.text) ?? 1.0,
                              passingScore: double.tryParse(passingController.text),
                            );
                            final provider = context.read<ExamProvider>();
                            final success = await provider.addExam(exam);
                            if (success && mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Exam created'),
                                      backgroundColor: kAccent2));
                            } else if (!success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(provider.errorMessage ?? 'Failed to create exam'),
                                      backgroundColor: Colors.red));
                            }
                          },
                          child: const Text('Create',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _showEditDialog(Exam exam) {
    final nameController = TextEditingController(text: exam.name);
    final itemsController = TextEditingController(text: exam.totalItems.toString());
    final pointsController = TextEditingController(text: exam.pointsPerItem.toString());
    final passingController = TextEditingController(text: exam.passingScore?.toString() ?? '');
    String componentType = exam.componentType;

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
                  Text('Edit Exam',
                      style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  GlassTextField(
                      controller: nameController,
                      label: 'Exam Name',
                      prefixIcon: Icons.label_rounded),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: kGlass,
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(color: kGlassBorder),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: componentType,
                        isExpanded: true,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark
                            ? const Color(0xFF1A1A3E)
                            : lSurface,
                        style: TextStyle(color: context.textPrimary),
                        items: const [
                          DropdownMenuItem(value: 'exam', child: Text('Exam')),
                          DropdownMenuItem(value: 'quiz', child: Text('Quiz')),
                          DropdownMenuItem(value: 'assignment', child: Text('Assignment')),
                          DropdownMenuItem(value: 'performance_task', child: Text('Performance Task')),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => componentType = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassTextField(
                      controller: itemsController,
                      label: 'Total Items',
                      prefixIcon: Icons.format_list_numbered_rounded,
                      keyboardType: TextInputType.number),
                  const SizedBox(height: 12),
                  GlassTextField(
                      controller: pointsController,
                      label: 'Points per Item',
                      prefixIcon: Icons.star_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 12),
                  GlassTextField(
                      controller: passingController,
                      label: 'Passing Score (optional)',
                      prefixIcon: Icons.check_circle_outline_rounded,
                      keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: GlassCard(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          onTap: () => Navigator.pop(context),
                          child: const Center(
                              child: Text('Cancel', style: TextStyle(color: kAccent2))),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: GradientButton(
                          colors: const [kAccent2, kAccent1],
                          onPressed: () async {
                            final updated = Exam(
                              id: exam.id,
                              subjectId: exam.subjectId,
                              name: nameController.text.trim(),
                              componentType: componentType,
                              totalItems: int.tryParse(itemsController.text) ?? exam.totalItems,
                              pointsPerItem: double.tryParse(pointsController.text) ?? exam.pointsPerItem,
                              passingScore: double.tryParse(passingController.text),
                            );
                            final provider = context.read<ExamProvider>();
                            final success = await provider.updateExam(exam.id!, updated);
                            if (success && mounted) {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Exam updated'),
                                      backgroundColor: kAccent2));
                            } else if (!success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                      content: Text(provider.errorMessage ?? 'Failed to update exam'),
                                      backgroundColor: Colors.red));
                            }
                          },
                          child: const Text('Save',
                              style: TextStyle(
                                  color: Colors.white, fontWeight: FontWeight.bold)),
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
    final tp = context.textPrimary;
    final ts = context.textSecondary;
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/exams'),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
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
                    Text('Exams & Quizzes',
                        style: AppTypography.subheading.copyWith(
                          color: tp,
                          fontSize: 22,
                        )),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              // Subject filter
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Consumer<SubjectProvider>(
                  builder: (context, subjectProvider, _) {
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: kGlass,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: kGlassBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String?>(
                          value: _filterSubjectId,
                          isExpanded: true,
                          hint: Text('All Subjects',
                              style: TextStyle(color: ts)),
                          dropdownColor: Theme.of(context).brightness == Brightness.dark
                              ? const Color(0xFF1A1A3E)
                              : lSurface,
                          style: TextStyle(color: tp),
                          items: [
                            DropdownMenuItem<String?>(
                              value: null,
                              child: Text('All Subjects',
                                  style: TextStyle(color: ts)),
                            ),
                            ...subjectProvider.subjects.map((s) =>
                                DropdownMenuItem<String?>(
                                  value: s.id,
                                  child: Text('${s.code} ${s.name}',
                                      style: TextStyle(color: tp)),
                                )),
                          ],
                          onChanged: (v) => setState(() => _filterSubjectId = v),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Consumer<ExamProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(color: kAccent1));
                    }
                    var exams = provider.exams;
                    if (_filterSubjectId != null) {
                      exams = exams.where((e) => e.subjectId == _filterSubjectId).toList();
                    }
                    if (exams.isEmpty) {
                      return Center(
                        child: GlassCard(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.quiz_rounded,
                                  size: 64, color: kAccent1.withValues(alpha: 0.5)),
                              const SizedBox(height: 16),
                              Text('No exams yet',
                                  style: TextStyle(
                                      color: kAccent1,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text('Tap + to create an exam or quiz',
                                  style: TextStyle(color: ts)),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: exams.length,
                      itemBuilder: (context, index) {
                        final exam = exams[index];
                        final typeColor = _typeColor(exam.componentType);
                        final maxScore = (exam.totalItems * exam.pointsPerItem).toStringAsFixed(1);
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
                                    color: typeColor.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(14),
                                    border: Border.all(color: typeColor.withValues(alpha: 0.3)),
                                  ),
                                  child: Center(
                                    child: Text(
                                      exam.componentType[0].toUpperCase(),
                                      style: TextStyle(
                                          color: typeColor,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(exam.name,
                                          style: AppTypography.bodyBold.copyWith(
                                              color: tp, fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 8, vertical: 2),
                                            decoration: BoxDecoration(
                                              color: typeColor.withValues(alpha: 0.15),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(_typeLabel(exam.componentType),
                                                style: TextStyle(
                                                    color: typeColor,
                                                    fontSize: 11,
                                                    fontWeight: FontWeight.w600)),
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                              '${exam.totalItems} items • $maxScore pts',
                                              style: AppTypography.caption.copyWith(
                                                  color: ts, fontSize: 12)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
                                  icon: Icon(Icons.more_vert_rounded,
                                      color: typeColor),
                                  color: Theme.of(context).brightness == Brightness.dark
                                      ? const Color(0xFF1A1A3E)
                                      : lSurface,
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      child: const Text('Edit',
                                          style: TextStyle(color: kAccent1)),
                                      onTap: () => _showEditDialog(exam),
                                    ),
                                    PopupMenuItem(
                                      child: const Text('Delete',
                                          style: TextStyle(color: kAccent3)),
                                      onTap: () async {
                                        await provider.deleteExam(exam.id!);
                                        if (mounted) {
                                          ScaffoldMessenger.of(context).showSnackBar(
                                              const SnackBar(
                                                  content: Text('Exam deleted'),
                                                  backgroundColor: kAccent3));
                                        }
                                      },
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
      floatingActionButton: PremiumFAB(
        onPressed: _showAddDialog,
        icon: Icons.add_rounded,
      ),
    );
  }
}