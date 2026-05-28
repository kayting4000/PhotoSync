import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/academic_term_provider.dart';
import '../models/academic_term.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';
import 'package:intl/intl.dart';

class AcademicTermsScreen extends StatefulWidget {
  const AcademicTermsScreen({super.key});

  @override
  State<AcademicTermsScreen> createState() => _AcademicTermsScreenState();
}

class _AcademicTermsScreenState extends State<AcademicTermsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicTermProvider>().fetchTerms();
    });
  }

  void _showAddDialog() {
    final nameController = TextEditingController();
    DateTime startDate = DateTime.now();
    DateTime endDate = DateTime.now().add(const Duration(days: 120));
    bool isCurrent = false;
    String termType = 'preliminary';
    int percentageWeight = 33;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Add Academic Term',
                      style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  GlassTextField(
                      controller: nameController,
                      label: 'Term Name',
                      prefixIcon: Icons.calendar_month_outlined),
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
                        value: termType,
                        isExpanded: true,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : lSurface,
                        style: TextStyle(color: context.textPrimary),
                        items: const [
                          DropdownMenuItem(
                            value: 'preliminary',
                            child: Text('Preliminary'),
                          ),
                          DropdownMenuItem(
                            value: 'mid-semester',
                            child: Text('Mid-Semester'),
                          ),
                          DropdownMenuItem(
                            value: 'final',
                            child: Text('Final'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => termType = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weight: $percentageWeight%',
                          style: TextStyle(color: context.textPrimary, fontSize: 14)),
                      Slider(
                        value: percentageWeight.toDouble(),
                        min: 10,
                        max: 90,
                        divisions: 8,
                        label: '$percentageWeight%',
                        activeColor: kAccent1,
                        onChanged: (v) {
                          setState(() => percentageWeight = v.toInt());
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DatePickerField(
                    label: 'Start Date',
                    value: startDate,
                    onChanged: (d) => setState(() => startDate = d),
                  ),
                  const SizedBox(height: 12),
                  _DatePickerField(
                    label: 'End Date',
                    value: endDate,
                    onChanged: (d) => setState(() => endDate = d),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFF555555),
                            secondary: Color(0xFF777777),
                          ),
                        ),
                        child: Checkbox(
                          value: isCurrent,
                          onChanged: (v) {
                            if (v != null) setState(() => isCurrent = v);
                          },
                          activeColor: kAccent1,
                          checkColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Set as current term',
                          style: TextStyle(color: context.textPrimary)),
                    ],
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
                            if (nameController.text.trim().isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                    content: Text('Please enter a term name'),
                                    backgroundColor: Color(0xFF444444)),
                              );
                              return;
                            }
                            final term = AcademicTerm(
                              name: nameController.text.trim(),
                              termType: termType,
                              percentageWeight: percentageWeight,
                              startDate: startDate,
                              endDate: endDate,
                              isCurrent: isCurrent,
                            );
                            final provider =
                                context.read<AcademicTermProvider>();
                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(context);
                            final success = await provider.addTerm(term);
                            if (success && mounted) {
                              nav.pop();
                              messenger.showSnackBar(
                                const SnackBar(
                                    content: Text('Term added!'),
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

  void _showEditDialog(AcademicTerm term) {
    final nameController = TextEditingController(text: term.name);
    DateTime startDate = term.startDate;
    DateTime endDate = term.endDate;
    bool isCurrent = term.isCurrent;
    String termType = term.termType;
    int percentageWeight = term.percentageWeight;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => Dialog(
          backgroundColor: Colors.transparent,
          child: GlassCard(
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Edit Academic Term',
                      style: TextStyle(
                          color: context.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                  const SizedBox(height: 20),
                  GlassTextField(
                      controller: nameController,
                      label: 'Term Name',
                      prefixIcon: Icons.calendar_month_outlined),
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
                        value: termType,
                        isExpanded: true,
                        dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : lSurface,
                        style: TextStyle(color: context.textPrimary),
                        items: const [
                          DropdownMenuItem(
                            value: 'preliminary',
                            child: Text('Preliminary'),
                          ),
                          DropdownMenuItem(
                            value: 'mid-semester',
                            child: Text('Mid-Semester'),
                          ),
                          DropdownMenuItem(
                            value: 'final',
                            child: Text('Final'),
                          ),
                        ],
                        onChanged: (v) {
                          if (v != null) setState(() => termType = v);
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Weight: $percentageWeight%',
                          style: TextStyle(color: context.textPrimary, fontSize: 14)),
                      Slider(
                        value: percentageWeight.toDouble(),
                        min: 10,
                        max: 90,
                        divisions: 8,
                        label: '$percentageWeight%',
                        activeColor: kAccent1,
                        onChanged: (v) {
                          setState(() => percentageWeight = v.toInt());
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _DatePickerField(
                    label: 'Start Date',
                    value: startDate,
                    onChanged: (d) => setState(() => startDate = d),
                  ),
                  const SizedBox(height: 12),
                  _DatePickerField(
                    label: 'End Date',
                    value: endDate,
                    onChanged: (d) => setState(() => endDate = d),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Theme(
                        data: Theme.of(context).copyWith(
                          colorScheme: const ColorScheme.dark(
                            primary: Color(0xFF555555),
                            secondary: Color(0xFF777777),
                          ),
                        ),
                        child: Checkbox(
                          value: isCurrent,
                          onChanged: (v) {
                            if (v != null) setState(() => isCurrent = v);
                          },
                          activeColor: kAccent1,
                          checkColor: Colors.white,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text('Set as current term',
                          style: TextStyle(color: context.textPrimary)),
                    ],
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
                            final updated = AcademicTerm(
                              id: term.id,
                              name: nameController.text,
                              termType: termType,
                              percentageWeight: percentageWeight,
                              startDate: startDate,
                              endDate: endDate,
                              isCurrent: isCurrent,
                            );
                            final provider =
                                context.read<AcademicTermProvider>();
                            final messenger = ScaffoldMessenger.of(context);
                            final nav = Navigator.of(context);
                            final success =
                                await provider.updateTerm(term.id!, updated);
                            if (success && mounted) {
                              nav.pop();
                              messenger.showSnackBar(
                                const SnackBar(
                                    content: Text('Term updated!'),
                                    backgroundColor: kAccent2),
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
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.textPrimary;
    final ts = context.textSecondary;
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/academic-terms'),
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
                    Text('Academic Terms',
                        style: TextStyle(
                            color: tp,
                            fontSize: 22,
                            fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: Consumer<AcademicTermProvider>(
                  builder: (context, provider, _) {
                    if (provider.isLoading) {
                      return const Center(
                          child: CircularProgressIndicator(color: kAccent1));
                    }
                    if (provider.terms.isEmpty) {
                      return const Center(
                        child: GlassCard(
                          padding: EdgeInsets.all(40),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.calendar_month_outlined,
                                  size: 64, color: kAccent1),
                              SizedBox(height: 16),
                              Text('No academic terms yet',
                                  style: TextStyle(
                                      color: kAccent1,
                                      fontSize: 18,
                                      fontWeight: FontWeight.w600)),
                              SizedBox(height: 8),
                              Text('Tap + to create a term',
                                  style: TextStyle(color: kAccent1)),
                            ],
                          ),
                        ),
                      );
                    }
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      itemCount: provider.terms.length,
                      itemBuilder: (context, index) {
                        final term = provider.terms[index];
                        final dateFormat = DateFormat('MMM d, yyyy');
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
                                    gradient: term.isCurrent
                                        ? const LinearGradient(
                                            colors: [Color(0xFF666666), Color(0xFF444444)])
                                        : const LinearGradient(
                                            colors: [Color(0xFF555555), Color(0xFF777777)]),
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  child: Icon(
                                    term.isCurrent
                                        ? Icons.check_circle_rounded
                                        : Icons.calendar_month_rounded,
                                    color: Colors.white,
                                    size: 24,
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Text(term.name,
                                              style: TextStyle(
                                                  color: tp,
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 15)),
                                          if (term.isCurrent)
                                            const SizedBox(width: 8),
                                          if (term.isCurrent)
                                            Container(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8,
                                                      vertical: 2),
                                              decoration: BoxDecoration(
                                                color: kAccent1
                                                    .withValues(alpha: 0.2),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              child: const Text('Active',
                                                  style: TextStyle(
                                                      color: kAccent1,
                                                      fontSize: 10,
                                                      fontWeight:
                                                          FontWeight.bold)),
                                            ),
                                        ],
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${dateFormat.format(term.startDate)} - ${dateFormat.format(term.endDate)}',
                                        style: TextStyle(
                                            color: ts, fontSize: 12),
                                      ),
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
                                      onTap: () => _showEditDialog(term),
                                    ),
                                    PopupMenuItem(
                                      child: const Text('Delete',
                                          style:
                                              TextStyle(color: kAccent3)),
                                      onTap: () => context
                                          .read<AcademicTermProvider>()
                                          .deleteTerm(term.id!),
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

class _DatePickerField extends StatelessWidget {
  final String label;
  final DateTime value;
  final ValueChanged<DateTime> onChanged;

  const _DatePickerField({
    required this.label,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final dateFormat = DateFormat('MMM d, yyyy');

    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value,
          firstDate: DateTime(2020),
          lastDate: DateTime(2035),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? dGlass : lGlass,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: isDark ? dGlassBorder : lGlassBorder),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today_rounded,
                color: isDark ? dTextSecondary : lTextSecondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '$label: ${dateFormat.format(value)}',
                style: TextStyle(
                  color: isDark ? dTextPrimary : lTextPrimary,
                  fontSize: 14,
                ),
              ),
            ),
            Icon(Icons.arrow_drop_down_rounded,
                color: isDark ? dTextSecondary : lTextSecondary),
          ],
        ),
      ),
    );
  }
}