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
  const StudentRecordScreen(
      {super.key,
      required this.subject,
      required this.section,
      required this.student});

  @override
  State<StudentRecordScreen> createState() => _StudentRecordScreenState();
}

class _StudentRecordScreenState extends State<StudentRecordScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final api = ApiService();

  List<dynamic> _exams = [];
  List<dynamic> _results = [];
  Map<String, dynamic> _attendanceSummary = {'present': 0, 'late': 0, 'absent': 0};
  List<dynamic> _attendanceRecords = [];
  bool _loading = true;

  final List<String> _tabLabels = [
    'Exams', 'Quizzes', 'Assignments', 'Performance', 'Attendance'
  ];
  final List<IconData> _tabIcons = [
    Icons.description_rounded,
    Icons.quiz_rounded,
    Icons.assignment_rounded,
    Icons.star_rounded,
    Icons.calendar_month_rounded,
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _loading = true);
    try {
      final exams = await api.get('/exams/?subject_id=${widget.subject.id}');
      final results = await api.get('/results/?student_id=${widget.student.id}');
      final summary = await api.getMap(
          '/attendance/student/${widget.student.id}/subject/${widget.subject.id}/summary');
      final records = await api.get(
          '/attendance/student/${widget.student.id}/subject/${widget.subject.id}');
      if (mounted) {
        setState(() {
          _exams = exams;
          _results = results;
          _attendanceSummary = summary;
          _attendanceRecords = records;
          _loading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _loading = false);
    }
  }

  List<dynamic> _examsOfType(String type) =>
      _exams.where((e) => e['component_type'] == type).toList();

  Map<String, dynamic>? _resultForExam(String examId) {
    try {
      return _results.firstWhere((r) => r['exam_id'] == examId);
    } catch (_) {
      return null;
    }
  }

  void _showAddExamDialog(String componentType) {
    final nameController = TextEditingController();
    final itemsController = TextEditingController(text: '50');
    final pointsController = TextEditingController(text: '1.0');

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Add ${_labelFor(componentType)}',
                  style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              GlassTextField(
                  controller: nameController,
                  label: 'Name',
                  prefixIcon: Icons.label_rounded),
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
                        try {
                          await api.post('/exams/', {
                            'subject_id': widget.subject.id,
                            'name': nameController.text.trim(),
                            'component_type': componentType,
                            'total_items': int.tryParse(itemsController.text) ?? 50,
                            'points_per_item':
                                double.tryParse(pointsController.text) ?? 1.0,
                          });
                          if (mounted) {
                            final nav = Navigator.of(ctx);
                            nav.pop();
                            _loadData();
                          }
                        } catch (e) {
                          if (mounted) {
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                                SnackBar(content: Text(e.toString())));
                          }
                        }
                      },
                      child: const Text('Add',
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
    );
  }

  void _showAddResultDialog(Map<String, dynamic> exam) {
    final scoreController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        backgroundColor: Colors.transparent,
        child: GlassCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Enter Score — ${exam['name']}',
                  style: TextStyle(
                      color: context.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text(
                  'Max: ${(exam['total_items'] * exam['points_per_item']).toStringAsFixed(1)}',
                  style: TextStyle(color: context.textSecondary, fontSize: 12)),
              const SizedBox(height: 16),
              GlassTextField(
                  controller: scoreController,
                  label: 'Score',
                  prefixIcon: Icons.grade_rounded,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true)),
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
                        try {
                          final existing = _resultForExam(exam['id']);
                          if (existing != null) {
                            await api.put('/results/${existing['id']}', {
                              'score': double.tryParse(scoreController.text) ?? 0,
                            });
                          } else {
                            await api.post('/results/', {
                              'student_id': widget.student.id,
                              'exam_id': exam['id'],
                              'score': double.tryParse(scoreController.text) ?? 0,
                            });
                          }
                          if (mounted) {
                            final nav = Navigator.of(ctx);
                            nav.pop();
                            _loadData();
                          }
                        } catch (e) {
                          if (mounted) {
                            final messenger = ScaffoldMessenger.of(context);
                            messenger.showSnackBar(
                                SnackBar(content: Text(e.toString())));
                          }
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
    );
  }

  String _labelFor(String type) {
    switch (type) {
      case 'exam': return 'Exam';
      case 'quiz': return 'Quiz';
      case 'assignment': return 'Assignment';
      case 'performance_task': return 'Performance Task';
      default: return type;
    }
  }

  Widget _buildComponentTab(String componentType) {
    final exams = _examsOfType(componentType);
    return Column(
      children: [
        Expanded(
          child: exams.isEmpty
              ? Center(
                  child: Text('No ${_labelFor(componentType)}s yet',
                      style: TextStyle(color: context.textSecondary)))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: exams.length,
                  itemBuilder: (context, i) {
                    final exam = exams[i];
                    final result = _resultForExam(exam['id']);
                    final maxScore =
                        (exam['total_items'] * exam['points_per_item'])
                            .toDouble();
                    final score = result != null
                        ? (result['score'] as num).toDouble()
                        : null;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: GlassCard(
                        padding: const EdgeInsets.all(14),
                        child: Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(exam['name'],
                                      style: TextStyle(
                                          color: context.textPrimary,
                                          fontWeight: FontWeight.w600)),
                                  const SizedBox(height: 4),
                                  Text(
                                      score != null
                                          ? '${score.toStringAsFixed(1)} / ${maxScore.toStringAsFixed(1)}'
                                          : 'No score yet',
                                      style: TextStyle(
                                          color: score != null
                                              ? kAccent2
                                              : context.textSecondary,
                                          fontSize: 13)),
                                ],
                              ),
                            ),
                            GestureDetector(
                              onTap: () => _showAddResultDialog(exam),
                              child: const GlassCard(
                                padding: EdgeInsets.all(8),
                                borderRadius: 10,
                                child: Icon(Icons.edit_rounded,
                                    color: kAccent2, size: 18),
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: () async {
                                await api.delete('/exams/${exam['id']}');
                                _loadData();
                              },
                              child: const GlassCard(
                                padding: EdgeInsets.all(8),
                                borderRadius: 10,
                                child: Icon(Icons.delete_rounded,
                                    color: kAccent3, size: 18),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
        Padding(
          padding: const EdgeInsets.all(16),
          child: GradientButton(
            colors: const [kAccent2, kAccent1],
            onPressed: () => _showAddExamDialog(componentType),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, color: Colors.white, size: 18),
                const SizedBox(width: 8),
                Text('Add ${_labelFor(componentType)}',
                    style: const TextStyle(
                        color: Colors.white, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAttendanceTab() {
    final now = DateTime.now();
    final months = List.generate(12, (i) => i + 1);
    final monthNames = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              _attendanceBadge('Present', _attendanceSummary['present'] ?? 0,
                  const Color(0xFF43E97B)),
              const SizedBox(width: 8),
              _attendanceBadge('Late', _attendanceSummary['late'] ?? 0,
                  const Color(0xFFF7971E)),
              const SizedBox(width: 8),
              _attendanceBadge('Absent', _attendanceSummary['absent'] ?? 0,
                  kAccent3),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: 12,
            itemBuilder: (context, index) {
              final month = months[index];
              final monthRecords = _attendanceRecords
                  .where((r) =>
                      r['month'] == month && r['year'] == now.year)
                  .toList();
              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: GlassCard(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(monthNames[index],
                          style: TextStyle(
                              color: context.textPrimary,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: List.generate(31, (d) {
                          final day = d + 1;
                          final record = monthRecords.firstWhere(
                              (r) => r['day'] == day,
                              orElse: () => <String, dynamic>{});
                          final status = record['status'] as String?;
                          return GestureDetector(
                            onTap: () => _cycleAttendance(month, day, status),
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: status == 'present'
                                    ? const Color(0xFF43E97B)
                                    : status == 'late'
                                        ? const Color(0xFFF7971E)
                                        : status == 'absent'
                                            ? kAccent3
                                            : kGlass,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: kGlassBorder),
                              ),
                              child: Center(
                                child: Text('$day',
                                    style: TextStyle(
                                        color: status != null
                                            ? Colors.white
                                            : context.textSecondary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600)),
                              ),
                            ),
                          );
                        }),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Future<void> _cycleAttendance(int month, int day, String? current) async {
    final next = current == null
        ? 'present'
        : current == 'present'
            ? 'late'
            : current == 'late'
                ? 'absent'
                : null;
    try {
      if (next == null) {
        final record = _attendanceRecords.firstWhere(
            (r) =>
                r['month'] == month &&
                r['day'] == day &&
                r['year'] == DateTime.now().year,
            orElse: () => <String, dynamic>{});
        if (record['id'] != null) {
          await api.delete('/attendance/${record['id']}');
        }
      } else {
        await api.post('/attendance/', {
          'student_id': widget.student.id,
          'subject_id': widget.subject.id,
          'year': DateTime.now().year,
          'month': month,
          'day': day,
          'status': next,
        });
      }
      _loadData();
    } catch (_) {}
  }

  Widget _attendanceBadge(String label, int count, Color color) {
    return Expanded(
      child: GlassCard(
        padding: const EdgeInsets.symmetric(vertical: 10),
        child: Column(
          children: [
            Text('$count',
                style: TextStyle(
                    color: color,
                    fontSize: 22,
                    fontWeight: FontWeight.bold)),
            Text(label,
                style: TextStyle(color: context.textSecondary, fontSize: 11)),
          ],
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
                            Text(widget.student.fullName,
                                style: TextStyle(
                                    color: context.textPrimary,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold)),
                            Text(
                                '${widget.student.studentId} • ${widget.subject.name}',
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
              const SizedBox(height: 12),
              TabBar(
                controller: _tabController,
                isScrollable: true,
                indicatorColor: kAccent2,
                labelColor: kAccent2,
                unselectedLabelColor: context.textSecondary,
                tabs: List.generate(
                  5,
                  (i) => Tab(
                    icon: Icon(_tabIcons[i], size: 18),
                    text: _tabLabels[i],
                  ),
                ),
              ),
              Expanded(
                child: _loading
                    ? const Center(
                        child: CircularProgressIndicator(color: kAccent2))
                    : TabBarView(
                        controller: _tabController,
                        children: [
                          _buildComponentTab('exam'),
                          _buildComponentTab('quiz'),
                          _buildComponentTab('assignment'),
                          _buildComponentTab('performance_task'),
                          _buildAttendanceTab(),
                        ],
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
