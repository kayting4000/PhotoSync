import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/subject_provider.dart';
import '../providers/section_provider.dart';
// Removed unused import: '../providers/student_provider.dart'
import '../models/section.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class HierarchyScreen extends StatefulWidget {
  const HierarchyScreen({super.key});

  @override
  State<HierarchyScreen> createState() => _HierarchyScreenState();
}

class _HierarchyScreenState extends State<HierarchyScreen> {
  final Map<String, bool> _expandedSubjects = {};
  String? _selectedSectionId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SubjectProvider>().fetchSubjects();
      context.read<SectionProvider>().fetchSections();
    });
  }

  void _toggleSubject(String subjectId) {
    setState(() {
      _expandedSubjects[subjectId] = !(_expandedSubjects[subjectId] ?? false);
    });
  }

  void _selectSection(String sectionId) {
    setState(() {
      _selectedSectionId = _selectedSectionId == sectionId ? null : sectionId;
    });
  }

  void _showAddStudentDialog(Section section) {
    final nameController = TextEditingController();
    final idController = TextEditingController();
    final emailController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add Student to Section ${section.sectionLabel}',
                  style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GlassTextField(
                  controller: nameController,
                  label: 'Student Name',
                  prefixIcon: Icons.person_rounded),
              const SizedBox(height: 12),
              GlassTextField(
                  controller: idController,
                  label: 'Student ID',
                  prefixIcon: Icons.badge_rounded),
              const SizedBox(height: 12),
              GlassTextField(
                  controller: emailController,
                  label: 'Email',
                  prefixIcon: Icons.email_rounded),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/hierarchy'),
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
                    Text('Course Structure',
                        style: AppTypography.subheading.copyWith(
                            color: context.textPrimary,
                            fontSize: 22)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Tree View
              Expanded(
                child: Consumer2<SubjectProvider, SectionProvider>(
                  builder: (context, subjectProvider, sectionProvider, _) {
                    if (subjectProvider.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(color: kAccent1));
                    }

                    if (subjectProvider.subjects.isEmpty) {
                      return Center(
                        child: GlassCard(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.folder_outlined,
                                  size: 64, color: kAccent1),
                              const SizedBox(height: 16),
                              Text('No subjects yet',
                                  style: TextStyle(
                                      color: context.textPrimary,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600)),
                              const SizedBox(height: 8),
                              Text('Create a subject to get started',
                                  style: TextStyle(
                                      color: context.textSecondary)),
                            ],
                          ),
                        ),
                      );
                    }

                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      itemCount: subjectProvider.subjects.length,
                      itemBuilder: (context, index) {
                        final subject = subjectProvider.subjects[index];
                        final isExpanded =
                            _expandedSubjects[subject.id] ?? false;
                        final sections = sectionProvider.sections
                            .where((s) => s.subjectId == subject.id)
                            .toList();

                        return Column(
                          children: [
                            // Subject Item (Folder)
                            GlassCard(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 10),
                              onTap: () => _toggleSubject(subject.id!),
                              child: Row(
                                children: [
                                  // Expand/Collapse Icon
                                  Container(
                                    width: 32,
                                    height: 32,
                                    decoration: BoxDecoration(
                                      color: kAccent1.withValues(alpha: 0.2),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        isExpanded
                                            ? Icons.expand_more_rounded
                                            : Icons.chevron_right_rounded,
                                        color: kAccent1,
                                        size: 20,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Folder Icon
                                  Icon(
                                    isExpanded
                                        ? Icons.folder_open_rounded
                                        : Icons.folder_rounded,
                                    color: kAccent2,
                                    size: 24,
                                  ),
                                  const SizedBox(width: 12),
                                  // Subject Name
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
                                        Text(subject.code,
                                            style: TextStyle(
                                                color: context.textSecondary,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  // Count Badge
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: kAccent1.withOpacity(0.2),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '${sections.length}',
                                      style: const TextStyle(
                                          color: kAccent1,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // Sections (Expanded when subject is expanded)
                            if (isExpanded)
                              Padding(
                                padding: const EdgeInsets.only(left: 12, top: 8),
                                child: Column(
                                  children: sections.isEmpty
                                      ? [
                                          Container(
                                            margin:
                                                const EdgeInsets.only(bottom: 8),
                                            child: GlassCard(
                                              padding: const EdgeInsets.symmetric(
                                                  horizontal: 12, vertical: 10),
                                              child: Row(
                                                children: [
                                                  const SizedBox(width: 32),
                                                  const SizedBox(width: 12),
                                                  Icon(Icons.folder_outlined,
                                                      color: context
                                                          .textSecondary,
                                                      size: 20),
                                                  const SizedBox(width: 12),
                                                  Text('No sections',
                                                      style: TextStyle(
                                                          color: context
                                                              .textSecondary,
                                                          fontSize: 13)),
                                                ],
                                              ),
                                            ),
                                          )
                                        ]
                                      : List.generate(
                                          sections.length,
                                          (sIndex) {
                                            final section = sections[sIndex];
                                            final isSelected =
                                                _selectedSectionId ==
                                                    section.id;

                                            return Column(
                                              children: [
                                                Container(
                                                  margin: const EdgeInsets
                                                      .only(bottom: 8),
                                                  child: GlassCard(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 12,
                                                        vertical: 10),
                                                    color: isSelected
                                                        ? kAccent1.withOpacity(
                                                            0.15)
                                                        : null,
                                                    onTap: () =>
                                                        _selectSection(section.id!),
                                                    child: Row(
                                                      children: [
                                                        const SizedBox(width: 32),
                                                        const SizedBox(width: 12),
                                                        Container(
                                                          width: 28,
                                                          height: 28,
                                                          decoration:
                                                              BoxDecoration(
                                                            color: kAccent2
                                                                .withOpacity(0.2),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(6),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              section.sectionLabel,
                                                              style: const TextStyle(
                                                                  color: kAccent2,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  fontSize: 12),
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
                                                                'Room: ${section.roomNumber}',
                                                                style: TextStyle(
                                                                    color: context
                                                                        .textSecondary,
                                                                    fontSize:
                                                                        11),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                        // Add Student Button
                                                        if (isSelected)
                                                          GestureDetector(
                                                            onTap: () =>
                                                                _showAddStudentDialog(
                                                                    section),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(8),
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: kAccent1
                                                                    .withValues(alpha: 0.3),
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
                                                ),
                                                // Add Student Action (when section is selected)
                                                if (isSelected)
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            bottom: 12,
                                                            left: 44),
                                                    child: GlassCard(
                                                      padding: const EdgeInsets
                                                          .symmetric(
                                                          horizontal: 12,
                                                          vertical: 8),
                                                      onTap: () =>
                                                          _showAddStudentDialog(
                                                              section),
                                                      child: const Row(
                                                        children: [
                                                          Icon(
                                                            Icons
                                                                .person_add_rounded,
                                                            color: kAccent1,
                                                            size: 18,
                                                          ),
                                                          SizedBox(
                                                              width: 8),
                                                          Text(
                                                            'Add Student',
                                                            style: TextStyle(
                                                                color: kAccent1,
                                                                fontSize: 12,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                              ],
                                            );
                                          },
                                        ),
                                ),
                              ),
                            const SizedBox(height: 8),
                          ],
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
    );
  }
}