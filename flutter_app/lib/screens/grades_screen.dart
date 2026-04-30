import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class GradesScreen extends StatefulWidget {
  const GradesScreen({Key? key}) : super(key: key);

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

      double totalWeightedGrade = 0;
      double totalUnits = 0;

      for (var grade in grades) {
        final percentage = (grade['percentage'] ?? 0.0).toDouble();
        if (percentage >= 90) grade['grade'] = 'A+';
        else if (percentage >= 85) grade['grade'] = 'A';
        else if (percentage >= 80) grade['grade'] = 'B+';
        else if (percentage >= 75) grade['grade'] = 'B';
        else if (percentage >= 70) grade['grade'] = 'C+';
        else if (percentage >= 65) grade['grade'] = 'C';
        else if (percentage >= 60) grade['grade'] = 'D';
        else grade['grade'] = 'F';
      }

      double calculatedGpa = 4.0 - (totalWeightedGrade / totalUnits);

      if (mounted) {
        setState(() {
          _examResults = grades;
          _gpa = calculatedGpa.clamp(1.0, 4.0);
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
      debugPrint('Error fetching grades: $e');
    }
  }

  String _getGradeColor(String? grade) {
    switch (grade) {
      case 'A+':
      case 'A':
        return '#10b981';
      case 'B+':
      case 'B':
        return '#3b82f6';
      case 'C+':
      case 'C':
        return '#f59e0b';
      case 'D':
        return '#ef4444';
      default:
        return '#6b7280';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grades & GPA'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        children: [
                          Text(
                            'Current GPA',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            _gpa.toStringAsFixed(2),
                            style: Theme.of(context)
                                .textTheme
                                .displaySmall
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color:
                                      Theme.of(context).colorScheme.primary,
                                ),
                          ),
                          const SizedBox(height: 8),
                          LinearProgressIndicator(
                            value: _gpa / 4.0,
                            minHeight: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Text(
                    'Exam Results',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 16),
                  if (_examResults.isEmpty)
                    Center(
                      child: Column(
                        children: [
                          Icon(
                            Icons.assignment_outlined,
                            size: 48,
                            color: Theme.of(context).colorScheme.outline,
                          ),
                          const SizedBox(height: 12),
                          const Text('No exam results yet'),
                        ],
                      ),
                    )
                  else
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _examResults.length,
                      itemBuilder: (context, index) {
                        final result = _examResults[index];
                        final percentage =
                            (result['percentage'] ?? 0.0).toDouble();
                        final grade = result['grade'] ?? 'N/A';

                        return Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Row(
                              children: [
                                Container(
                                  width: 60,
                                  height: 60,
                                  decoration: BoxDecoration(
                                    color: Color(int.parse(
                                        '0xff${_getGradeColor(grade).substring(1)}')),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Center(
                                    child: Text(
                                      grade,
                                      style: const TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 18,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Exam ${index + 1}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleMedium,
                                      ),
                                      const SizedBox(height: 4),
                                      Text(
                                        '${percentage.toStringAsFixed(1)}%',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }
}
