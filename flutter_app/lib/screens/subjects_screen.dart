import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../models/subject.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import '../widgets/fade_slide_in.dart';
import '../api.dart'; // add this near the top with other imports

class SubjectsScreen extends StatefulWidget {
  const SubjectsScreen({super.key});

  @override
  State<SubjectsScreen> createState() => _SubjectsScreenState();
}

class _SubjectsScreenState extends State<SubjectsScreen> {
  // Add these state fields
  bool _isLoading = false;
  List<Map<String, dynamic>> subjectsList = [];

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
                Text('New Subject',
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
                      dropdownColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1A1A3E)
                          : lSurface,
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
                            child: Text('Cancel', style: TextStyle(color: kAccent2))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        colors: const [kAccent2, kAccent1],
                        onPressed: () async {
                          final subject = Subject(
                            code: codeController.text.trim(),
                            name: nameController.text.trim(),
                            units: units,
                          );
                          final provider = context.read<SubjectProvider>();
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(context);
                          final success = await provider.addSubject(subject);
                          if (success && mounted) {
                            nav.pop();
                            messenger.showSnackBar(const SnackBar(
                                content: Text('Subject created!'),
                                backgroundColor: kAccent2));
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
    );
  }

  void _showEditDialog(Subject subject) {
    final codeController = TextEditingController(text: subject.code);
    final nameController = TextEditingController(text: subject.name);
    int units = subject.units;

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
                Text('Edit Subject',
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
                      dropdownColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1A1A3E)
                          : lSurface,
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
                            child: Text('Cancel', style: TextStyle(color: kAccent2))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        colors: const [kAccent1, kAccent2],
                        onPressed: () async {
                          final updated = Subject(
                            code: codeController.text.trim(),
                            name: nameController.text.trim(),
                            units: units,
                          );
                          final provider = context.read<SubjectProvider>();
                          final messenger = ScaffoldMessenger.of(context);
                          final nav = Navigator.of(context);
                          final success =
                              await provider.updateSubject(subject.id!, updated);
                          if (success && mounted) {
                            nav.pop();
                            messenger.showSnackBar(const SnackBar(
                                content: Text('Subject updated!'),
                                backgroundColor: kAccent1));
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
      drawer: const AppDrawer(currentRoute: '/subjects'),
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: FadeSlideIn(
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: const GlassCard(
                            padding: EdgeInsets.all(10),
                            borderRadius: 12,
                            child: Icon(Icons.menu_rounded, color: kAccent2, size: 20),
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
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: FadeSlideIn(
                  delay: const Duration(milliseconds: 80),
                  child: Text('Tap a subject to view its sections',
                      style: TextStyle(color: context.textSecondary, fontSize: 12)),
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
                            children: [
                              const Icon(Icons.folder_open_rounded,
                                  size: 64, color: kAccent2),
                              const SizedBox(height: 16),
                              const Text('No subjects yet',
                                  style: TextStyle(
                                      color: kAccent2,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text('Tap + to create your first subject',
                                  style: TextStyle(color: context.textSecondary)),
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
                        return FadeSlideIn(
                          delay: Duration(milliseconds: 60 * index),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              onTap: () => context.push(
                                  '/subjects/${subject.id}/sections',
                                  extra: subject),
                              child: Row(
                                children: [
                                  Container(
                                    width: 48,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: grad),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: const Center(
                                      child: Icon(Icons.folder_rounded,
                                          color: Colors.white, size: 26),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(subject.name,
                                            style: TextStyle(
                                                color: context.textPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Text(
                                            '${subject.code} • ${subject.units} unit(s)',
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
                                          Icon(Icons.edit_rounded,
                                              color: kAccent2, size: 18),
                                          SizedBox(width: 8),
                                          Text('Edit',
                                              style: TextStyle(color: kAccent2)),
                                        ]),
                                        onTap: () => _showEditDialog(subject),
                                      ),
                                      PopupMenuItem(
                                        child: const Row(children: [
                                          Icon(Icons.delete_rounded,
                                              color: kAccent3, size: 18),
                                          SizedBox(width: 8),
                                          Text('Delete',
                                              style: TextStyle(color: kAccent3)),
                                        ]),
                                        onTap: () => context
                                            .read<SubjectProvider>()
                                            .deleteSubject(subject.id!),
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
          onPressed: _showAddDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }

  Future<void> _createSubjectAndRefresh(String name) async {
    if (name.trim().isEmpty) return;
    setState(() { _isLoading = true; });
    try {
      final res = await createSubject(name);
      // guard against widget disposed while awaiting
      if (!mounted) return;
      if (res['success'] == true && res['subject'] != null) {
        setState(() {
          // keep local list in sync for UI – adapt if you use Provider instead
          subjectsList.insert(0, Map<String, dynamic>.from(res['subject']));
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Subject created'), backgroundColor: Colors.green),
        );
      } else {
        final msg = res['detail'] ?? 'Unknown server response';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Create failed: $e')));
    } finally {
      if (!mounted) return;
      setState(() { _isLoading = false; });
    }
  }
}

class _CloudTexturePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Guard: if size is zero, don't paint (avoids NaN from modulo/division)
    if (size.isEmpty || size.width == 0.0 || size.height == 0.0) {
      return;
    }
    final paint = Paint()..style = PaintingStyle.fill;
    // Soft white cloud-like patches
    for (int i = 0; i < 8; i++) {
      final x = (i * 0.137 + 0.3) * size.width;
      final y = (i * 0.124 + 0.1) * size.height;
      final radius = size.width * (0.15 + i * 0.02);
      paint.color = Colors.white.withValues(alpha: 0.06);
      canvas.drawOval(Rect.fromCenter(center: Offset(x % size.width, y % size.height), width: size.width * 0.4, height: size.height * 0.12), paint);
    }
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
