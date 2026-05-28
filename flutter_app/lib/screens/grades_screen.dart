import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/academic_term_provider.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/app_drawer.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({super.key});

  @override
  State<GradesScreen> createState() => _GradesScreenState();
}

class _GradesScreenState extends State<GradesScreen> {
  final api = ApiService();
  List<dynamic> _examResults = [];
  bool _isLoading = true;
  double _gpa = 0.0;
  double _averagePercentage = 0.0;
  int _highestScore = 0;
  int _lowestScore = 100;
  Map<String, List<double>> _subjectPercentages = {};
  Map<String, int> _gradeDistribution = {};
  String? _selectedTermId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AcademicTermProvider>().fetchTerms();
      _fetchData();
    });
  }

  Future<void> _fetchData({String? termId}) async {
    try {
      final url = termId != null ? '/exam-results/?term_id=$termId' : '/exam-results/';
      final results = await api.get(url);
      double totalPercentage = 0;
      double highest = 0;
      double lowest = 100;
      Map<String, List<double>> subjectScores = {};
      Map<String, int> distrib = {
        'A+': 0, 'A': 0, 'B+': 0, 'B': 0,
        'C+': 0, 'C': 0, 'D': 0, 'F': 0,
      };

      for (var grade in results) {
        final pct = (grade['percentage'] ?? 0.0).toDouble();
        totalPercentage += pct;

        if (pct > highest) highest = pct;
        if (pct < lowest) lowest = pct;

        String letterGrade;
        if (pct >= 90) {
          letterGrade = 'A+';
        } else if (pct >= 85) {
          letterGrade = 'A';
        } else if (pct >= 80) {
          letterGrade = 'B+';
        } else if (pct >= 75) {
          letterGrade = 'B';
        } else if (pct >= 70) {
          letterGrade = 'C+';
        } else if (pct >= 65) {
          letterGrade = 'C';
        } else if (pct >= 60) {
          letterGrade = 'D';
        } else {
          letterGrade = 'F';
        }
        grade['grade'] = letterGrade;
        distrib[letterGrade] = (distrib[letterGrade] ?? 0) + 1;

        final subjectName = grade['exam_name'] ?? 'Exam';
        subjectScores.putIfAbsent(subjectName, () => []);
        subjectScores[subjectName]!.add(pct);
      }

      if (mounted) {
        setState(() {
          _examResults = results;
          _averagePercentage = results.isEmpty ? 0.0 : totalPercentage / results.length;
          _gpa = (_averagePercentage / 100 * 3.0 + 1.0).clamp(1.0, 4.0);
          _highestScore = highest.toInt();
          _lowestScore = lowest == 100 ? 0 : lowest.toInt();
          _subjectPercentages = subjectScores;
          _gradeDistribution = distrib;
          _isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Error fetching grades: $e');
      if (mounted) setState(() => _isLoading = false);
    }
  }

  List<Color> _gradeColors(String? grade) {
    switch (grade) {
      case 'A+': case 'A': return [const Color(0xFF555555), const Color(0xFF777777)];
      case 'B+': case 'B': return [const Color(0xFF666666), const Color(0xFF444444)];
      case 'C+': case 'C': return [const Color(0xFF777777), const Color(0xFF555555)];
      default: return [const Color(0xFF444444), const Color(0xFF666666)];
    }
  }

  String _gradeEmoji(String? grade) {
    switch (grade) {
      case 'A+': case 'A': return '🌟';
      case 'B+': case 'B': return '👍';
      case 'C+': case 'C': return '📚';
      case 'D': return '⚠️';
      case 'F': return '❌';
      default: return '📝';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: GlassCard(
            padding: const EdgeInsets.all(8),
            borderRadius: 12,
            onTap: () => Navigator.of(context).pop(),
            child: const Icon(Icons.arrow_back_ios_rounded, color: kTextPrimary, size: 20),
          ),
        ),
        title: const Text('Grades & GPA',
            style: TextStyle(
                color: kTextPrimary,
                fontSize: 22,
                fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      drawer: const AppDrawer(currentRoute: '/grades'),
      body: AppBackground(
        child: SafeArea(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator(color: kAccent1))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Term selector
                      Consumer<AcademicTermProvider>(
                        builder: (context, termProvider, _) {
                          final terms = termProvider.terms;
                          return Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: kGlass,
                              borderRadius: BorderRadius.circular(14),
                              border: Border.all(color: kGlassBorder),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String?>(
                                value: _selectedTermId,
                                isExpanded: true,
                                hint: Text('All Terms',
                                    style: TextStyle(color: context.textSecondary)),
                                dropdownColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1A1A1A) : lSurface,
                                style: TextStyle(color: context.textPrimary),
                                items: [
                                  DropdownMenuItem<String?>(
                                    value: null,
                                    child: Text('All Terms',
                                        style: TextStyle(color: context.textSecondary)),
                                  ),
                                  ...terms.map((term) =>
                                      DropdownMenuItem<String?>(
                                        value: term.id,
                                        child: Text(term.displayName,
                                            style: TextStyle(color: context.textPrimary)),
                                      )),
                                ],
                                onChanged: (v) {
                                  setState(() {
                                    _selectedTermId = v;
                                    _isLoading = true;
                                  });
                                  _fetchData(termId: v);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 20),

                      // GPA Summary Card
                      GlassCard(
                        blurIntensity: 3,
                        child: Column(
                          children: [
                            const Text('Cumulative GPA',
                                style: TextStyle(color: kTextSecondary, fontSize: 13)),
                            const SizedBox(height: 8),
                            ShaderMask(
                              shaderCallback: (bounds) =>
                                  const LinearGradient(colors: [Color(0xFF777777), Color(0xFF444444)])
                                      .createShader(bounds),
                              child: Text(
                                _gpa.toStringAsFixed(2),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 48,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const Text('out of 4.00',
                                style: TextStyle(color: kTextSecondary, fontSize: 12)),
                            const SizedBox(height: 12),
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: LinearProgressIndicator(
                                value: _gpa / 4.0,
                                minHeight: 8,
                                backgroundColor: kGlass,
                                valueColor: const AlwaysStoppedAnimation<Color>(kAccent1),
                              ),
                            ),
                            const SizedBox(height: 16),

                            // Quick stats row
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                _StatItem(
                                  label: 'Average',
                                  value: '${_averagePercentage.toStringAsFixed(1)}%',
                                  color: kAccent1,
                                ),
                                _StatItem(
                                  label: 'Highest',
                                  value: '$_highestScore%',
                                  color: const Color(0xFF777777),
                                ),
                                _StatItem(
                                  label: 'Lowest',
                                  value: '$_lowestScore%',
                                  color: kAccent3,
                                ),
                                _StatItem(
                                  label: 'Exams',
                                  value: '${_examResults.length}',
                                  color: kAccent2,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Subject Breakdown
                      if (_subjectPercentages.isNotEmpty) ...[
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(colors: [Color(0xFF666666), Color(0xFF444444)]),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 16),
                            ),
                            const SizedBox(width: 10),
                            const Text('Performance by Subject',
                                style: TextStyle(
                                    color: kTextPrimary,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        ..._subjectPercentages.entries.map((entry) {
                          final scores = entry.value;
                          final avg = scores.reduce((a, b) => a + b) / scores.length;
                          final color = avg >= 75 ? kAccent1 : kAccent3;
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GlassCard(
                              padding: const EdgeInsets.all(14),
                              blurIntensity: 3,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(entry.key,
                                          style: const TextStyle(
                                              color: kTextPrimary,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 14)),
                                      Text('${avg.toStringAsFixed(1)}% avg',
                                          style: TextStyle(color: color, fontSize: 12)),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(4),
                                    child: LinearProgressIndicator(
                                      value: avg / 100,
                                      minHeight: 6,
                                      backgroundColor: kGlass,
                                      valueColor: AlwaysStoppedAnimation<Color>(color),
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text('${scores.length} exam(s)',
                                      style: const TextStyle(color: kTextSecondary, fontSize: 11)),
                                ],
                              ),
                            ),
                          );
                        }),
                        const SizedBox(height: 20),
                      ],

                      // Grade Distribution
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF555555), Color(0xFF777777)]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.pie_chart_rounded, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          const Text('Grade Distribution',
                              style: TextStyle(
                                  color: kTextPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),
                      GlassCard(
                        padding: const EdgeInsets.all(14),
                        blurIntensity: 3,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: _gradeDistribution.entries.map((entry) {
                            final gradeColors = _gradeColors(entry.key);
                            return Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                              decoration: BoxDecoration(
                                gradient: LinearGradient(colors: gradeColors),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(entry.key,
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14)),
                                  const SizedBox(width: 6),
                                  Text('${entry.value}',
                                      style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13)),
                                ],
                              ),
                            );
                          }).toList(),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Exam Results List
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(colors: [Color(0xFF444444), Color(0xFF666666)]),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.assignment_rounded, color: Colors.white, size: 16),
                          ),
                          const SizedBox(width: 10),
                          const Text('All Exam Results',
                              style: TextStyle(
                                  color: kTextPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 12),

                      if (_examResults.isEmpty)
                        const GlassCard(
                          padding: EdgeInsets.all(40),
                          child: Column(
                            children: [
                              Icon(Icons.assignment_outlined, size: 48, color: kTextSecondary),
                              SizedBox(height: 12),
                              Text('No exam results yet',
                                  style: TextStyle(color: kTextSecondary)),
                            ],
                          ),
                        )
                      else
                        ...List.generate(_examResults.length, (index) {
                          final result = _examResults[index];
                          final percentage = (result['percentage'] ?? 0.0).toDouble();
                          final grade = result['grade'] ?? 'N/A';
                          final colors = _gradeColors(grade);
                          final emoji = _gradeEmoji(grade);
                          final examName = result['exam_name'] as String? ?? 'Exam ${index + 1}';

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: GlassCard(
                              padding: const EdgeInsets.all(14),
                              blurIntensity: 3,
                              child: Row(
                                children: [
                                  Container(
                                    width: 52,
                                    height: 52,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(colors: colors),
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    child: Center(
                                      child: Text(emoji, style: const TextStyle(fontSize: 22)),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Text(examName,
                                                  style: const TextStyle(
                                                      color: kTextPrimary,
                                                      fontWeight: FontWeight.w600,
                                                      fontSize: 14)),
                                            ),
                                            Text(grade,
                                                style: TextStyle(
                                                    color: colors.first,
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 14)),
                                          ],
                                        ),
                                        const SizedBox(height: 6),
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(4),
                                          child: LinearProgressIndicator(
                                            value: percentage / 100,
                                            minHeight: 6,
                                            backgroundColor: kGlass,
                                            valueColor: AlwaysStoppedAnimation<Color>(colors.first),
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text('${percentage.toStringAsFixed(1)}%',
                                            style: const TextStyle(
                                                color: kTextSecondary, fontSize: 11)),
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

class _StatItem extends StatelessWidget {
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(
                color: color,
                fontSize: 18,
                fontWeight: FontWeight.bold)),
        const SizedBox(height: 2),
        Text(label,
            style: const TextStyle(color: kTextSecondary, fontSize: 10)),
      ],
    );
  }
}