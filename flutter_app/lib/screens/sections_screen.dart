import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/section_provider.dart';
import '../providers/subject_provider.dart';
import '../models/section.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class SectionsScreen extends StatefulWidget {
  const SectionsScreen({super.key});

  @override
  State<SectionsScreen> createState() => _SectionsScreenState();
}

class _SectionsScreenState extends State<SectionsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SectionProvider>().fetchSections();
      context.read<SubjectProvider>().fetchSubjects();
    });
  }

  void _showAddDialog() {
    final roomNumberController = TextEditingController();
    String selectedSubjectId = '';
    String selectedSectionLabel = 'A';

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
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Consumer<SubjectProvider>(
                      builder: (context, subjectProvider, _) {
                        if (subjectProvider.isLoading) {
                          return const Center(
                            child: Padding(
                              padding: EdgeInsets.symmetric(vertical: 16),
                              child: CircularProgressIndicator(color: kAccent1),
                            ),
                          );
                        }

                        if (subjectProvider.subjects.isEmpty) {
                          return Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.08),
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: kAccent1.withOpacity(0.3)),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('No subjects available',
                                    style: TextStyle(
                                        color: context.textPrimary,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 8),
                                Text('Create a subject first before adding a section.',
                                    style: TextStyle(color: context.textSecondary)),
                              ],
                            ),
                          );
                        }

                        return Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: kAccent1.withOpacity(0.3)),
                          ),
                          child: DropdownButton<String>(
                            isExpanded: true,
                            underline: const SizedBox(),
                            hint: const Text('Select Subject', style: TextStyle(color: kAccent1)),
                            value: selectedSubjectId.isEmpty ? null : selectedSubjectId,
                            dropdownColor: const Color(0xFF1A1A1A),
                            items: [
                              DropdownMenuItem(
                                value: '',
                                child: Text('Select Subject', style: TextStyle(color: kAccent1.withOpacity(0.9))),
                              ),
                              ...subjectProvider.subjects.map(
                                (subject) => DropdownMenuItem(
                                  value: subject.id ?? '',
                                  child: Text(
                                    '${subject.code} - ${subject.name}',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                            onChanged: (value) {
                              setState(() {
                                selectedSubjectId = value ?? '';
                              });
                            },
                          ),
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kAccent1.withOpacity(0.3)),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        value: selectedSectionLabel,
                        dropdownColor: const Color(0xFF1A1A1A),
                        items: ['A', 'B', 'C', 'D', 'E']
                            .map((label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSectionLabel = value ?? 'A';
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassTextField(
                        controller: roomNumberController,
                        label: 'Room Number',
                        prefixIcon: Icons.location_on_outlined,
                        autofocus: true),
                  ],
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
                        if (selectedSubjectId.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please select a subject'),
                                backgroundColor: Color(0xFF444444)),
                          );
                          return;
                        }
                        if (roomNumberController.text.trim().isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Please enter a room number'),
                                backgroundColor: Color(0xFF444444)),
                          );
                          return;
                        }
                        final section = Section(
                          subjectId: selectedSubjectId,
                          sectionLabel: selectedSectionLabel,
                          roomNumber: roomNumberController.text.trim(),
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
                        } else if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(provider.errorMessage ?? 'Failed to add section'),
                              backgroundColor: const Color(0xFF444444),
                            ),
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

  void _showEditDialog(Section section) {
    final roomNumberController = TextEditingController(text: section.roomNumber);
    String selectedSectionLabel = section.sectionLabel;

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Edit Section',
                  style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              StatefulBuilder(
                builder: (context, setState) => Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: kAccent1.withOpacity(0.3)),
                      ),
                      child: DropdownButton<String>(
                        isExpanded: true,
                        underline: const SizedBox(),
                        value: selectedSectionLabel,
                        dropdownColor: const Color(0xFF1A1A1A),
                        items: ['A', 'B', 'C', 'D', 'E']
                            .map((label) => DropdownMenuItem(
                                  value: label,
                                  child: Text(label, style: const TextStyle(color: Colors.white)),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            selectedSectionLabel = value ?? 'A';
                          });
                        },
                      ),
                    ),
                    const SizedBox(height: 16),
                    GlassTextField(
                        controller: roomNumberController,
                        label: 'Room Number',
                        prefixIcon: Icons.location_on_outlined,
                        autofocus: true),
                  ],
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
                        final updated = Section(
                          id: section.id,
                          subjectId: section.subjectId,
                          sectionLabel: selectedSectionLabel,
                          roomNumber: roomNumberController.text,
                        );
                        final provider = context.read<SectionProvider>();
                        final messenger = ScaffoldMessenger.of(context);
                        final nav = Navigator.of(context);
                        final success =
                            await provider.updateSection(section.id!, updated);
                        if (success && mounted) {
                          nav.pop();
                          messenger.showSnackBar(
                            const SnackBar(
                                content: Text('Section updated!'),
                                backgroundColor: kAccent2),
                          );
                        } else if (mounted) {
                          messenger.showSnackBar(
                            SnackBar(
                              content: Text(provider.errorMessage ?? 'Failed to update section'),
                              backgroundColor: const Color(0xFF444444),
                            ),
                          );
                        }
                      },
                      child: const Text('Save',
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

  @override
  Widget build(BuildContext context) {
    final tp = context.textPrimary;
    final ts = context.textSecondary;
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/sections'),
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
                    Text('Sections',
                        style: TextStyle(
                            color: tp,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<SectionProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(color: kAccent1));
                    }
                    if (provider.sections.isEmpty) {
                      return const Center(
                        child: GlassCard(
                          padding: EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.group_outlined,
                                  size: 64, color: kAccent1),
                              SizedBox(height: 16),
                              Text('No sections yet',
                                  style: TextStyle(
                                      color: kAccent1,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 8),
                              Text('Tap + to create a section',
                                  style: TextStyle(color: kAccent1)),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.sections.length,
                      itemBuilder: (context, index) {
                        final section = provider.sections[index];
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
                                        colors: [Color(0xFF666666), Color(0xFF444444)]),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: const Center(
                                    child: Icon(Icons.group_rounded,
                                        color: Colors.white, size: 24),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text('Section ${section.sectionLabel}',
                                          style: TextStyle(
                                              color: tp,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 15)),
                                      const SizedBox(height: 4),
                                      Text(section.roomNumber,
                                          style: TextStyle(
                                              color: ts,
                                              fontSize: 12)),
                                    ],
                                  ),
                                ),
                                PopupMenuButton(
                                  icon: const Icon(Icons.more_vert_rounded,
                                      color: kAccent1),
                                  color: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : lSurface,
                                  itemBuilder: (_) => [
                                    PopupMenuItem(
                                      child: const Text('Edit',
                                          style:
                                              TextStyle(color: kAccent1)),
                                      onTap: () => _showEditDialog(section),
                                    ),
                                    PopupMenuItem(
                                      child: const Text('Delete',
                                          style:
                                              TextStyle(color: kAccent3)),
                                      onTap: () => context
                                          .read<SectionProvider>()
                                          .deleteSection(section.id!),
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
          gradient: const LinearGradient(colors: [Color(0xFF666666), Color(0xFF444444)]),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
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