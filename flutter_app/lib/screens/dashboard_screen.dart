import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../providers/auth_provider.dart';
import '../../providers/student_provider.dart';
import '../../providers/subject_provider.dart';
import '../../providers/exam_provider.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({Key? key}) : super(key: key);

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final supabase = Supabase.instance.client;
  int _totalStudents = 0;
  int _totalSubjects = 0;
  int _totalExams = 0;
  int _totalResults = 0;

  @override
  void initState() {
    super.initState();
    _fetchDashboardData();
  }

  void _fetchDashboardData() async {
    try {
      final students =
          await supabase.from('students').select('id', const FetchOptions());
      final subjects =
          await supabase.from('subjects').select('id', const FetchOptions());
      final exams =
          await supabase.from('exams').select('id', const FetchOptions());
      final results = await supabase
          .from('exam_results')
          .select('id', const FetchOptions());

      if (mounted) {
        setState(() {
          _totalStudents = (students as List).length;
          _totalSubjects = (subjects as List).length;
          _totalExams = (exams as List).length;
          _totalResults = (results as List).length;
        });
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    }
  }

  void _logout() async {
    final authProvider = context.read<AuthProvider>();
    await authProvider.logout();
    if (mounted) {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Welcome back!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _StatCard(
                  title: 'Students',
                  value: '$_totalStudents',
                  icon: Icons.people,
                  color: Colors.blue,
                ),
                _StatCard(
                  title: 'Subjects',
                  value: '$_totalSubjects',
                  icon: Icons.book,
                  color: Colors.green,
                ),
                _StatCard(
                  title: 'Exams',
                  value: '$_totalExams',
                  icon: Icons.assignment,
                  color: Colors.orange,
                ),
                _StatCard(
                  title: 'Results',
                  value: '$_totalResults',
                  icon: Icons.assessment,
                  color: Colors.red,
                ),
              ],
            ),
            const SizedBox(height: 32),
            Text(
              'Quick Actions',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            _ActionButton(
              label: 'Manage Students',
              icon: Icons.people,
              onPressed: () => context.go('/students'),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Manage Subjects',
              icon: Icons.book,
              onPressed: () => context.go('/subjects'),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Scan Test Papers',
              icon: Icons.camera_alt,
              onPressed: () => context.go('/scanner'),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'View Grades',
              icon: Icons.assessment,
              onPressed: () => context.go('/grades'),
            ),
            const SizedBox(height: 12),
            _ActionButton(
              label: 'Send Email Results',
              icon: Icons.mail,
              onPressed: () => context.go('/email'),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: color.withOpacity(0.1),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 12),
          Text(
            value,
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onPressed;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      child: InkWell(
        onTap: onPressed,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Theme.of(context).colorScheme.outlineVariant,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
          child: Row(
            children: [
              Icon(icon, color: Theme.of(context).colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(label),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: Theme.of(context).colorScheme.outline,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
