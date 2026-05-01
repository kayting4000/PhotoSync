import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../theme/app_theme.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final supabase = Supabase.instance.client;
  List<dynamic> _examResults = [];
  bool _isLoading = true;
  double _gpa = 0.0;

  @override
  void initState() {
    super.initState();
    _fetchGrades();
  }

  Future<void> _fetchGrades() async {
    try {
      final results = await supabase.from('exam_results').select();
      final grades = results as List<dynamic>;
      double totalPercentage = 0;

      for (var grade in grades) {
        final percentage = (grade['percentage'] ?? 0.0).toDouble();
        totalPercentage += percentage;
        if (percentage >= 90) grade['grade'] = 'A+';
        else if (percentage >= 85) grade['grade'] = 'A';
        else if (percentage >= 80) grade['grade'] = 'B+';
        else if (percentage >= 75) grade['grade'] = 'B';
        else if (percentage >= 70) grade['grade'] = 'C+';
        else if (percentage >= 65) grade['grade'] = 'C';
        else if (percentage >= 60) grade['grade'] = 'D';
        else grade['grade'] = 'F';
      }

      final avg = grades.isEmpty ? 0.0 : totalPercentage / grades.length;
      final gpa = (avg / 100 * 3.0 + 1.0).clamp(1.0, 4.0);

      if (mounted) {
        setState(() {
          _examResults = grades;
          _gpa = gpa;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Color> _gradeColors(String? grade) {
    switch (grade) {
      case 'A+': case 'A': return [const Color(0xFF43E97B), const Color(0xFF38F9D7)];
      case 'B+': case 'B': return [kAccent1, kAccent2];
      case 'C+': case 'C': return [const Color(0xFFF7971E), const Color(0xFFFFD200)];
      default: return [kAccent3, const Color(0xFFFF8FA3)];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: kAccent1))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: GlassCard(
                              padding: const EdgeInsets.all(10),
                              borderRadius: 12,
                              child: const Icon(Icons.arrow_back_ios_new_rounded,
                                  color: kTextPrimary, size: 18),
                            ),
                          ),
                          const SizedBox(width: 16),
                          const Text('Grades & GPA',
                              style: TextStyle(
                                  color: kTextPrimary,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold)),
                        ],
                      ),
                      const SizedBox(height: 24),

                      // GPA Card
                      GlassCard(
                        child: Column(
                          children: [
                            const Text('Current GPA',
                                style: TextStyle(
                                    color: kTextSecondary, fontSize: 13)),
                            const SizedBox(height: 12),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(
                                      colors: [kAccent1, kAccent2])
                                      .createShader(bounds),
                              child: Text(
                                _gpa.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 56,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text('out of 4.00',
                                style: TextStyle(
                                    color: kTextSecondary, fontSize: 12)),
                            const SizedBox(height: 16),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _gpa / 4.0,
                                minHeight: 8,
                                backgroundColor: kGlass,
                                valueColor: const AlwaysStoppedAnimation<Color>(
                                    kAccent1),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),

                      const Text('Exam Results',
                          style: TextStyle(
                              color: kTextPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(height: 14),

                      if (_examResults.isEmpty)
                        GlassCard(
                          padding: const EdgeInsets.all(40),
                          child: Column(
                            children: const [
                              Icon(Icons.assignment_outlined,
                                  size: 48, color: kTextSecondary),
                              SizedBox(height: 12),
                              Text('No exam results yet',
                                  style: TextStyle(color: kTextSecondary)),
                            ],
                          ),
                        )
                      else
                        ...List.generate(_examResults.length, (index) {
                          final result = _examResults[index];
                          final percentage =
                              (result['percentage'] ?? 0.0).toDouble();
                          final grade = result['grade'] ?? 'N/A';
                          final colors = _gradeColors(grade);

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: GlassCard(
                              padding: const EdgeInsets.all(16),
                              child: Row(
                                children: [
                                  Container(
                                    width: 56,
                                    height: 56,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: colors),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(grade,
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16)),
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text('Exam ${index + 1}',
                                            style: const TextStyle(
                                                color: kTextPrimary,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 15)),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius:
                                              BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: percentage / 100,
                                            minHeight: 6,
                                            backgroundColor: kGlass,
                                            valueColor:
                                                AlwaysStoppedAnimation<Color>(
                                                    colors.first),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                            '${percentage.toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                                color: kTextSecondary,
                                                fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }),
                    ],
                  ),
                ),
        ),
      ),
    );
  }
}
