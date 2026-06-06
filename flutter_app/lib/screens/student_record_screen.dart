import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../models/subject.dart';
import '../models/section.dart';
import '../models/student.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide_in.dart';

class StudentRecordScreen extends StatefulWidget {
  final Subject subject;
  final Section section;
  final Student student;
  const StudentRecordScreen({
    super.key,
    required this.subject,
    required this.section,
    required this.student,
  });

  @override
  State<StudentRecordScreen> createState() => _StudentRecordScreenState();
}

class _StudentRecordScreenState extends State<StudentRecordScreen> {
  final api = ApiService();
  List<Map<String, dynamic>> _semesters = [];
  Map<String, dynamic>? _gpa;
  bool _loading = true;

  static const _termOrder = ['prelim', 'midterm', 'finals'];
  static const _termLabels = {
    'prelim': 'Prelim',
    'midterm': 'Midterm',
    'finals': 'Finals',
  };
  static const _termWeights = {
    'prelim': '25%',
    'midterm': '45%',
    'finals': '40%',
  };
  static const _termColors = {
    'prelim': [Color(0xFF48CAE4), Color(0xFF0096C7)],
    'midterm': [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
    'finals': [Color(0xFF43E97B), Color(0xFF38F9D7)],
  };

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final semData = await api.get('/semesters/?student_id=${widget.student.id}');
      final sems = List<Map<String, dynamic>>.from(semData.map((e) => Map<String, dynamic>.from(e)));
      // Sort by term order
      sems.sort((a, b) => _termOrder.indexOf(a['term']).compareTo(_termOrder.indexOf(b['term'])));
      
      Map<String, dynamic>? gpa;
      try {
        gpa = await api.getMap('/semesters/student/${widget.student.id}/gpa');
      } catch (_) {}

      if (mounted) {
        setState(() {
          _semesters = sems;
          _gpa = gpa;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _createSemester(String term) async {
    final existing = _semesters.any((s) => s['term'] == term);
    if (existing) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('${_termLabels[term]} already exists'), backgroundColor: kAccent3),
      );
      return;
    }
    try {
      await api.post('/semesters/', {
        'student_id': widget.student.id,
        'term': term,
      });
      _load();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString())));
      }
    }
  }

  Future<void> _deleteSemester(String semesterId) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Delete Semester?',
                  style: TextStyle(color: ctx.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('This will delete all variables inside.',
                  style: TextStyle(color: ctx.textSecondary, fontSize: 13)),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    onTap: () => Navigator.pop(ctx, false),
                    child: const Center(child: Text('Cancel', style: TextStyle(color: kAccent2))),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GradientButton(
                    colors: const [kAccent3, kAccent3],
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    );
    if (confirmed == true) {
      await api.delete('/semesters/$semesterId');
      if (mounted) _load();
    }
  }

  void _openSemester(Map<String, dynamic> semester) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => _SemesterFolderScreen(semester: semester, student: widget.student),
      ),
    ).then((_) => _load());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
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
                            Text(widget.student.fullName,
                                style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Text('${widget.student.studentId} • ${widget.subject.name}',
                                style: TextStyle(color: context.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (_loading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: kAccent2)))
              else
                Expanded(
                  child: RefreshIndicator(
                    color: kAccent2,
                    onRefresh: _load,
                    child: ListView(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      children: [
                        // GPA Card
                        FadeSlideIn(
                          child: GlassCard(
                            padding: const EdgeInsets.all(18),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(children: [
                                  Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(colors: [kAccent1, kAccent2]),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.school_rounded, color: Colors.white, size: 18),
                                  ),
                                  const SizedBox(width: 10),
                                  Text('Final GPA',
                                      style: TextStyle(
                                          color: context.textPrimary,
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold)),
                                ]),
                                const SizedBox(height: 14),
                                if (_gpa?['gpa'] != null)
                                  Text('${_gpa!['gpa']}%',
                                      style: const TextStyle(
                                          color: kAccent2, fontSize: 36, fontWeight: FontWeight.bold))
                                else
                                  Text(
                                    'Complete all semesters with valid weights to see GPA',
                                    style: TextStyle(color: context.textSecondary, fontSize: 13),
                                  ),
                                const SizedBox(height: 8),
                                Text('Prelim 25% + Midterm 45% + Finals 40%',
                                    style: TextStyle(color: context.textSecondary, fontSize: 11)),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Semester Folders
                        Text('Semester Folders',
                            style: TextStyle(
                                color: context.textPrimary,
                                fontSize: 15,
                                fontWeight: FontWeight.w600)),
                        const SizedBox(height: 6),
                        Text('Tap a semester to manage grade variables',
                            style: TextStyle(color: context.textSecondary, fontSize: 12)),
                        const SizedBox(height: 12),

                        for (final term in _termOrder) ...[
                          _buildTermTile(term),
                          const SizedBox(height: 10),
                        ],
                        const SizedBox(height: 24),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTermTile(String term) {
    final semester = _semesters.cast<Map<String, dynamic>?>().firstWhere(
      (s) => s!['term'] == term,
      orElse: () => null,
    );
    final colors = _termColors[term]!;
    final label = _termLabels[term]!;
    final weight = _termWeights[term]!;

    if (semester == null) {
      // Not yet created — show "create" tile
      return FadeSlideIn(
        child: GlassCard(
          padding: const EdgeInsets.all(16),
          onTap: () => _createSemester(term),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: kGlass,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: kGlassBorder),
                ),
                child: const Center(child: Icon(Icons.add_rounded, color: kAccent2, size: 24)),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Create $label',
                        style: TextStyle(
                            color: context.textPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    Text('$weight of final GPA',
                        style: TextStyle(color: context.textSecondary, fontSize: 12)),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final gradeVal = _gpa?[term];
    return FadeSlideIn(
      child: GlassCard(
        padding: const EdgeInsets.all(16),
        onTap: () => _openSemester(semester),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: colors),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Center(child: Icon(Icons.folder_rounded, color: Colors.white, size: 26)),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: context.textPrimary,
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  Text(
                    gradeVal != null ? 'Grade: $gradeVal%  •  $weight of GPA' : '$weight of final GPA',
                    style: TextStyle(
                        color: gradeVal != null ? kAccent2 : context.textSecondary,
                        fontSize: 12),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: kAccent2),
            PopupMenuButton(
              icon: const Icon(Icons.more_vert_rounded, color: kAccent2),
              color: Theme.of(context).brightness == Brightness.dark
                  ? const Color(0xFF1A1A3E)
                  : lSurface,
              itemBuilder: (_) => [
                PopupMenuItem(
                  child: const Row(children: [
                    Icon(Icons.delete_rounded, color: kAccent3, size: 18),
                    SizedBox(width: 8),
                    Text('Delete', style: TextStyle(color: kAccent3)),
                  ]),
                  onTap: () => _deleteSemester(semester['id'] as String),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SEMESTER FOLDER SCREEN — Variables CRUD
// ─────────────────────────────────────────────────────────────────────────────

class _SemesterFolderScreen extends StatefulWidget {
  final Map<String, dynamic> semester;
  final Student student;
  const _SemesterFolderScreen({required this.semester, required this.student});

  @override
  State<_SemesterFolderScreen> createState() => _SemesterFolderScreenState();
}

class _SemesterFolderScreenState extends State<_SemesterFolderScreen> {
  final api = ApiService();
  List<Map<String, dynamic>> _variables = [];
  Map<String, dynamic>? _grade;
  bool _loading = true;

  String get _semesterId => widget.semester['id'] as String;
  String get _termLabel {
    const m = {'prelim': 'Prelim', 'midterm': 'Midterm', 'finals': 'Finals'};
    return m[widget.semester['term']] ?? widget.semester['term'];
  }

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    try {
      final varData = await api.get('/variables/?semester_id=$_semesterId');
      final vars = List<Map<String, dynamic>>.from(varData.map((e) => Map<String, dynamic>.from(e)));

      Map<String, dynamic>? grade;
      try {
        grade = await api.getMap('/semesters/$_semesterId/grade');
      } catch (_) {}

      if (mounted) {
        setState(() {
          _variables = vars;
          _grade = grade;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  double get _totalWeight =>
      _variables.fold(0.0, (sum, v) => sum + ((v['weight'] as num?)?.toDouble() ?? 0.0));

  void _showAddVariableDialog() {
    final nameCtrl = TextEditingController();
    final scoreCtrl = TextEditingController();
    final totalCtrl = TextEditingController();
    final weightCtrl = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Add Variable',
                    style: TextStyle(
                        color: context.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text('Score/Total/Weight can be filled later (leave blank = NULL)',
                    style: TextStyle(color: context.textSecondary, fontSize: 11)),
                const SizedBox(height: 16),
                GlassTextField(controller: nameCtrl, label: 'Name (e.g. Exams, Quizzes)', prefixIcon: Icons.label_rounded),
                const SizedBox(height: 10),
                GlassTextField(controller: scoreCtrl, label: 'Score (optional)', prefixIcon: Icons.grade_rounded, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 10),
                GlassTextField(controller: totalCtrl, label: 'Total Score (optional)', prefixIcon: Icons.score_rounded, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 10),
                GlassTextField(controller: weightCtrl, label: 'Weight % (optional)', prefixIcon: Icons.balance_rounded, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onTap: () => Navigator.pop(ctx),
                      child: const Center(child: Text('Cancel', style: TextStyle(color: kAccent2))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      colors: const [kAccent2, kAccent1],
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        if (name.isEmpty) return;
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          await api.post('/variables/', {
                            'semester_id': _semesterId,
                            'name': name,
                            'score': double.tryParse(scoreCtrl.text),
                            'total_score': double.tryParse(totalCtrl.text),
                            'weight': double.tryParse(weightCtrl.text),
                          });
                          if (!mounted) return;
                          Navigator.pop(ctx);
                          _load();
                        } catch (e) {
                          messenger.showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      child: const Text('Add', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showEditVariableDialog(Map<String, dynamic> variable) {
    final nameCtrl = TextEditingController(text: variable['name'] as String? ?? '');
    final scoreCtrl = TextEditingController(text: variable['score']?.toString() ?? '');
    final totalCtrl = TextEditingController(text: variable['total_score']?.toString() ?? '');
    final weightCtrl = TextEditingController(text: variable['weight']?.toString() ?? '');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: SingleChildScrollView(
          child: GlassCard(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Edit Variable',
                    style: TextStyle(color: context.textPrimary, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                GlassTextField(controller: nameCtrl, label: 'Name', prefixIcon: Icons.label_rounded),
                const SizedBox(height: 10),
                GlassTextField(controller: scoreCtrl, label: 'Score', prefixIcon: Icons.grade_rounded, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 10),
                GlassTextField(controller: totalCtrl, label: 'Total Score', prefixIcon: Icons.score_rounded, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 10),
                GlassTextField(controller: weightCtrl, label: 'Weight %', prefixIcon: Icons.balance_rounded, keyboardType: const TextInputType.numberWithOptions(decimal: true)),
                const SizedBox(height: 20),
                Row(children: [
                  Expanded(
                    child: GlassCard(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      onTap: () => Navigator.pop(ctx),
                      child: const Center(child: Text('Cancel', style: TextStyle(color: kAccent2))),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: GradientButton(
                      colors: const [kAccent1, kAccent2],
                      onPressed: () async {
                        final messenger = ScaffoldMessenger.of(context);
                        try {
                          final body = <String, dynamic>{'name': nameCtrl.text.trim()};
                          final s = double.tryParse(scoreCtrl.text);
                          final t = double.tryParse(totalCtrl.text);
                          final w = double.tryParse(weightCtrl.text);
                          if (s != null) body['score'] = s;
                          if (t != null) body['total_score'] = t;
                          if (w != null) body['weight'] = w;
                          await api.put('/variables/${variable['id']}', body);
                          if (!mounted) return;
                          Navigator.pop(ctx);
                          _load();
                        } catch (e) {
                          messenger.showSnackBar(SnackBar(content: Text(e.toString())));
                        }
                      },
                      child: const Text('Save', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ),
                ]),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final tw = _totalWeight;
    final gradeVal = _grade?['grade'];

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
                        onTap: () => Navigator.pop(context),
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
                            Text(_termLabel,
                                style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Text(widget.student.fullName,
                                style: TextStyle(color: context.textSecondary, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),

              if (_loading)
                const Expanded(child: Center(child: CircularProgressIndicator(color: kAccent2)))
              else
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    children: [
                      // Grade + Weight Summary Card
                      FadeSlideIn(
                        child: GlassCard(
                          padding: const EdgeInsets.all(16),
                          child: Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('Semester Grade',
                                        style: TextStyle(color: context.textSecondary, fontSize: 12)),
                                    const SizedBox(height: 4),
                                    if (gradeVal != null)
                                      Text('$gradeVal%',
                                          style: const TextStyle(
                                              color: kAccent2,
                                              fontSize: 28,
                                              fontWeight: FontWeight.bold))
                                    else
                                      Text(_grade?['reason'] ?? 'Incomplete',
                                          style: TextStyle(color: context.textSecondary, fontSize: 12)),
                                  ],
                                ),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('Total Weight',
                                      style: TextStyle(color: context.textSecondary, fontSize: 11)),
                                  Text('${tw.toStringAsFixed(1)}%',
                                      style: TextStyle(
                                          color: (tw - 100).abs() < 0.1 ? const Color(0xFF43E97B) : kAccent3,
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold)),
                                  Text('must equal 100%',
                                      style: TextStyle(color: context.textSecondary, fontSize: 10)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),

                      Text('Variables',
                          style: TextStyle(
                              color: context.textPrimary, fontSize: 15, fontWeight: FontWeight.w600)),
                      const SizedBox(height: 4),
                      Text('Manually add grade components. All fields are optional at creation.',
                          style: TextStyle(color: context.textSecondary, fontSize: 11)),
                      const SizedBox(height: 12),

                      if (_variables.isEmpty)
                        GlassCard(
                          padding: const EdgeInsets.all(32),
                          child: Column(
                            children: [
                              const Icon(Icons.add_chart_rounded, size: 48, color: kAccent2),
                              const SizedBox(height: 12),
                              Text('No variables yet',
                                  style: TextStyle(color: kAccent2, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 4),
                              Text('Tap + to add Exams, Quizzes, etc.',
                                  style: TextStyle(color: context.textSecondary, fontSize: 12)),
                            ],
                          ),
                        )
                      else
                        for (final variable in _variables) ...[
                          FadeSlideIn(
                            child: _VariableTile(
                              variable: variable,
                              onEdit: () => _showEditVariableDialog(variable),
                              onDelete: () async {
                                await api.delete('/variables/${variable['id']}');
                                _load();
                              },
                            ),
                          ),
                          const SizedBox(height: 8),
                        ],
                      const SizedBox(height: 80),
                    ],
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
          boxShadow: [BoxShadow(color: kAccent2.withValues(alpha: 0.5), blurRadius: 20, offset: const Offset(0, 8))],
        ),
        child: FloatingActionButton(
          onPressed: _showAddVariableDialog,
          backgroundColor: Colors.transparent,
          elevation: 0,
          child: const Icon(Icons.add_rounded, color: Colors.white),
        ),
      ),
    );
  }
}

class _VariableTile extends StatelessWidget {
  final Map<String, dynamic> variable;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  const _VariableTile({required this.variable, required this.onEdit, required this.onDelete});

  @override
  Widget build(BuildContext context) {
    final score = variable['score'] as double?;
    final total = variable['total_score'] as double?;
    final weight = variable['weight'] as double?;

    String scoreStr = score != null && total != null
        ? '${score.toStringAsFixed(1)} / ${total.toStringAsFixed(1)}'
        : 'Score: —';
    String weightStr = weight != null ? '${weight.toStringAsFixed(1)}%' : 'Weight: —';
    double? pct = (score != null && total != null && total > 0) ? (score / total) * 100 : null;

    return GlassCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(colors: [kAccent1, kAccent2]),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(weightStr,
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(variable['name'] as String? ?? '',
                    style: TextStyle(color: context.textPrimary, fontWeight: FontWeight.w600, fontSize: 14)),
              ),
              GestureDetector(
                onTap: onEdit,
                child: const GlassCard(padding: EdgeInsets.all(7), borderRadius: 9,
                    child: Icon(Icons.edit_rounded, color: kAccent2, size: 16)),
              ),
              const SizedBox(width: 6),
              GestureDetector(
                onTap: onDelete,
                child: const GlassCard(padding: EdgeInsets.all(7), borderRadius: 9,
                    child: Icon(Icons.delete_rounded, color: kAccent3, size: 16)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(scoreStr, style: TextStyle(color: context.textSecondary, fontSize: 12)),
              const Spacer(),
              if (pct != null)
                Text('${pct.toStringAsFixed(1)}%',
                    style: TextStyle(
                        color: pct >= 75 ? const Color(0xFF43E97B) : kAccent3,
                        fontSize: 13,
                        fontWeight: FontWeight.bold)),
            ],
          ),
          if (pct != null) ...[
            const SizedBox(height: 6),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: (pct / 100).clamp(0.0, 1.0),
                backgroundColor: kGlass,
                valueColor: AlwaysStoppedAnimation(pct >= 75 ? const Color(0xFF43E97B) : kAccent3),
                minHeight: 5,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
