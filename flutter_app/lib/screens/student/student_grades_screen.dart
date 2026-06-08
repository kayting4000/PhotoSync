import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';

class StudentGradesScreen extends StatefulWidget {
  const StudentGradesScreen({super.key});

  @override
  State<StudentGradesScreen> createState() => _StudentGradesScreenState();
}

class _StudentGradesScreenState extends State<StudentGradesScreen> {
  final api = ApiService();
  List<dynamic> _grades = [];
  List<dynamic> _summaries = [];
  bool _isLoading = true;
  bool _showSummary = false;

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  void _fetchGrades() async {
    try {
      final grades = await api.get('/portal/grades');
      final summaries = await api.get('/portal/grades/summary');
      if (mounted) {
        setState(() {
          _grades = grades;
          _summaries = summaries;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.textPrimary;
    final ts = context.textSecondary;

    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
                child: Row(
                  children: [
                    GestureDetector(
                      onTap: () => context.go('/student/dashboard'),
                      child: const GlassCard(
                        padding: EdgeInsets.all(10),
                        borderRadius: 14,
                        blurIntensity: 3,
                        child: Icon(Icons.arrow_back_rounded,
                            color: kAccent2, size: 20),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'My Grades',
                        style: TextStyle(
                          color: tp,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    // Toggle between individual grades and summary
                    GestureDetector(
                      onTap: () => setState(() => _showSummary = !_showSummary),
                      child: GlassCard(
                        padding: const EdgeInsets.all(10),
                        borderRadius: 14,
                        blurIntensity: 3,
                        child: Icon(
                          _showSummary
                              ? Icons.list_alt_rounded
                              : Icons.summarize_rounded,
                          color: kAccent2,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (_showSummary)
                _buildSummaryView(tp, ts)
              else
                _buildGradesView(tp, ts),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGradesView(Color tp, Color ts) {
    if (_grades.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_rounded, color: ts, size: 48),
              const SizedBox(height: 12),
              Text('No grades available yet', style: TextStyle(color: ts)),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _grades.length,
        itemBuilder: (ctx, i) {
          final g = _grades[i] as Map<String, dynamic>;
          final remarks = g['remarks'] as String? ?? '';
          final passed = remarks == 'Passed';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              blurIntensity: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${g['subject_code']} - ${g['subject_name']}',
                          style: TextStyle(
                            color: tp,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: passed
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          remarks,
                          style: TextStyle(
                            color: passed ? Colors.green : Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(g['exam_name'] ?? '',
                      style: TextStyle(color: ts, fontSize: 12)),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      _GradeChip(
                          label: 'Score', value: '${g['percentage']}%'),
                      const SizedBox(width: 8),
                      _GradeChip(label: 'Grade', value: g['grade'] ?? ''),
                      const SizedBox(width: 8),
                      _GradeChip(
                          label: 'GPA',
                          value: (g['grade_point'] ?? 0.0).toStringAsFixed(2)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSummaryView(Color tp, Color ts) {
    if (_summaries.isEmpty) {
      return Expanded(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.info_rounded, color: ts, size: 48),
              const SizedBox(height: 12),
              Text('No grade summary available', style: TextStyle(color: ts)),
            ],
          ),
        ),
      );
    }

    return Expanded(
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _summaries.length,
        itemBuilder: (ctx, i) {
          final s = _summaries[i] as Map<String, dynamic>;
          final remarks = s['remarks'] as String? ?? '';
          final passed = remarks == 'Passed';
          return Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GlassCard(
              padding: const EdgeInsets.all(14),
              blurIntensity: 3,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          '${s['subject_code']} - ${s['subject_name']}',
                          style: TextStyle(
                            color: tp,
                            fontWeight: FontWeight.w600,
                            fontSize: 14,
                          ),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: passed
                              ? Colors.green.withValues(alpha: 0.2)
                              : Colors.red.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          remarks,
                          style: TextStyle(
                            color: passed ? Colors.green : Colors.red,
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _GradeChip(
                          label: 'Units', value: '${s['units'] ?? 0}'),
                      const SizedBox(width: 8),
                      _GradeChip(label: 'Grade', value: s['grade'] ?? ''),
                      const SizedBox(width: 8),
                      _GradeChip(
                          label: 'GPA',
                          value: (s['grade_point'] ?? 0.0).toStringAsFixed(2)),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _GradeChip extends StatelessWidget {
  final String label;
  final String value;

  const _GradeChip({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final ts = context.textSecondary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('$label: ', style: TextStyle(color: ts, fontSize: 11)),
          Text(value,
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}