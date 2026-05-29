import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../models/subject.dart';
import '../models/section.dart';
import '../providers/section_provider.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide_in.dart';

class SubjectSectionsScreen extends StatefulWidget {
  final Subject subject;
  const SubjectSectionsScreen({super.key, required this.subject});

  @override
  State<SubjectSectionsScreen> createState() => _SubjectSectionsScreenState();
}

class _SubjectSectionsScreenState extends State<SubjectSectionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SectionProvider>().fetchSections();
    });
  }

  void _showAddDialog() {
    final roomController = TextEditingController();
    String label = 'A';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('New Section',
                    style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: kGlass,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: kGlassBorder),
                  ),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: label,
                      isExpanded: true,
                      dropdownColor: Theme.of(context).brightness == Brightness.dark
                          ? const Color(0xFF1A1A3E)
                          : lSurface,
                      style: TextStyle(color: context.textPrimary),
                      items: ['A', 'B', 'C', 'D', 'E', 'F', 'G', 'H']
                          .map((l) => DropdownMenuItem(value: l, child: Text('Section $l')))
                          .toList(),
                      onChanged: (v) {
                        if (v != null) setState(() => label = v);
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                GlassTextField(
                    controller: roomController,
                    label: 'Room Number',
                    prefixIcon: Icons.location_on_outlined),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        onTap: () => Navigator.pop(ctx),
                        child: const Center(
                            child: Text('Cancel', style: TextStyle(color: kAccent2))),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GradientButton(
                        colors: const [kAccent2, kAccent1],
                        onPressed: () async {
                          final section = Section(
                            subjectId: widget.subject.id!,
                            sectionLabel: label,
                            roomNumber: roomController.text.trim(),
                          );
                          final provider = context.read<SectionProvider>();
                          final success = await provider.addSection(section);
                          if (success && mounted) {
                            Navigator.pop(ctx);
                            setState(() {});
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
                          child: Icon(Icons.arrow_back_rounded, color: kAccent2, size: 20),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(widget.subject.name,
                                style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Text(widget.subject.code,
                                style: TextStyle(
                                    color: context.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<SectionProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(color: kAccent2));
                    }
                    final sections = provider.sections
                        .where((s) => s.subjectId == widget.subject.id)
                        .toList();
                    if (sections.isEmpty) {
                      return Center(
                        child: GlassCard(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.folder_open_rounded,
                                  size: 64, color: kAccent1),
                              const SizedBox(height: 16),
                              const Text('No sections yet',
                                  style: TextStyle(
                                      color: kAccent1,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text('Tap + to add a section',
                                  style: TextStyle(color: context.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: sections.length,
                      itemBuilder: (context, index) {
                        final section = sections[index];
                        return FadeSlideIn(
                          delay: Duration(milliseconds: 60 * index),
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              onTap: () => context.push(
                                  '/subjects/${widget.subject.id}/sections/${section.id}/students',
                                  extra: {'subject': widget.subject, 'section': section}),
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
                                      child: Text(section.sectionLabel,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18)),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('Section ${section.sectionLabel}',
                                            style: TextStyle(
                                                color: context.textPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Text(section.roomNumber,
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
                                    color: Theme.of(context).brightness == Brightness.dark
                                        ? const Color(0xFF1A1A3E)
                                        : lSurface,
                                    itemBuilder: (_) => [
                                      PopupMenuItem(
                                        child: const Row(children: [
                                          Icon(Icons.delete_rounded,
                                              color: kAccent3, size: 18),
                                          SizedBox(width: 8),
                                          Text('Delete',
                                              style: TextStyle(color: kAccent3)),
                                        ]),
                                        onTap: () => context
                                            .read<SectionProvider>()
                                            .deleteSection(section.id!),
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
