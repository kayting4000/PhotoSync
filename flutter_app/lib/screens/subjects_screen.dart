import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().fetchSubjects();
    });
  }

  void _showAddDialog() {
    final codeController = TextEditingController();
    final nameController = TextEditingController();
    int units = 3;

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
                const Text('Add Subject',
                    style: TextStyle(
                        color: kTextPrimary,
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
                      dropdownColor: const Color(0xFF1A1A3E),
                      style: const TextStyle(color: kTextPrimary),
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
                        colors: const [kAccent2, kAccent1],
                        onPressed: () async {
                          final subject = Subject(
                            code: codeController.text,
                            name: nameController.text,
                            units: units,
                          );
                          final success = await context
                              .read<SubjectProvider>()
                              .addSubject(subject);
                          if (success && mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
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
    );
  }

  final List<List<Color>> _gradients = const [
    [Color(0xFF48CAE4), Color(0xFF0096C7)],
    [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
    [Color(0xFF43E97B), Color(0xFF38F9D7)],
    [Color(0xFFFF6584), Color(0xFFFF8FA3)],
    [Color(0xFFF7971E), Color(0xFFFFD200)],
  ];

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
                    const Text('Subjects',
                        style: TextStyle(
                            color: kTextPrimary,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<SubjectProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(color: kAccent2));
                    }
                    if (provider.subjects.isEmpty) {
                      return Center(
                        child: GlassCard(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Icon(Icons.menu_book_outlined,
                                  size: 64, color: kTextSecondary),
                              SizedBox(height: 16),
                              Text('No subjects yet',
                                  style: TextStyle(
                                      color: kTextPrimary,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 8),
                              Text('Tap + to add a subject',
                                  style: TextStyle(color: kTextSecondary)),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.subjects.length,
                      itemBuilder: (context, index) {
                        final subject = provider.subjects[index];
                        final grad = _gradients[index % _gradients.length];
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
                                    gradient: LinearGradient(colors: grad),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Center(
                                    child: Text(
                                      subject.code.length >= 2
                                          ? subject.code.substring(0, 2)
                                          : subject.code,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(subject.name,
                                          style: const TextStyle(
                                              color: kTextPrimary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Text(
                                          '${subject.code} • ${subject.units} unit(s)',
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
                                          style: TextStyle(color: kAccent3)),
                                      onTap: () => context
                                          .read<SubjectProvider>()
                                          .deleteSubject(subject.id!),
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
          onPressed: _showAddDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}
