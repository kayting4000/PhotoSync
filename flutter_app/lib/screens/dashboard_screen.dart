import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../providers/auth_provider.dart';
import '../theme/app_theme.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

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
      final students = await supabase.from('students').select('id');
      final subjects = await supabase.from('subjects').select('id');
      final exams = await supabase.from('exams').select('id');
      final results = await supabase.from('exam_results').select('id');
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
    await context.read<AuthProvider>().logout();
    if (mounted) context.go('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'EduScan',
                          style: TextStyle(
                            color: kTextPrimary,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1,
                          ),
                        ),
                        const Text(
                          'Welcome back! 👋',
                          style: TextStyle(color: kTextSecondary, fontSize: 14),
                        ),
                      ],
                    ),
                    GestureDetector(
                      onTap: _logout,
                      child: GlassCard(
                        padding: const EdgeInsets.all(12),
                        borderRadius: 14,
                        child: const Icon(Icons.logout_rounded,
                            color: kTextPrimary, size: 20),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                // Stats grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 14,
                  crossAxisSpacing: 14,
                  childAspectRatio: 1.3,
                  children: [
                    _StatCard(
                      title: 'Students',
                      value: '$_totalStudents',
                      icon: Icons.people_rounded,
                      colors: [const Color(0xFF6C63FF), const Color(0xFF9B8FFF)],
                    ),
                    _StatCard(
                      title: 'Subjects',
                      value: '$_totalSubjects',
                      icon: Icons.menu_book_rounded,
                      colors: [const Color(0xFF48CAE4), const Color(0xFF0096C7)],
                    ),
                    _StatCard(
                      title: 'Exams',
                      value: '$_totalExams',
                      icon: Icons.assignment_rounded,
                      colors: [const Color(0xFFFF6584), const Color(0xFFFF8FA3)],
                    ),
                    _StatCard(
                      title: 'Results',
                      value: '$_totalResults',
                      icon: Icons.bar_chart_rounded,
                      colors: [const Color(0xFF43E97B), const Color(0xFF38F9D7)],
                    ),
                  ],
                ),
                const SizedBox(height: 28),

                const Text(
                  'Quick Actions',
                  style: TextStyle(
                    color: kTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),

                _ActionTile(
                  label: 'Manage Students',
                  subtitle: 'Add, edit & view students',
                  icon: Icons.people_rounded,
                  gradient: const [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
                  onTap: () => context.go('/students'),
                ),
                _ActionTile(
                  label: 'Manage Subjects',
                  subtitle: 'Configure courses & units',
                  icon: Icons.menu_book_rounded,
                  gradient: const [Color(0xFF48CAE4), Color(0xFF0096C7)],
                  onTap: () => context.go('/subjects'),
                ),
                _ActionTile(
                  label: 'Scan Test Papers',
                  subtitle: 'Upload & analyze papers',
                  icon: Icons.document_scanner_rounded,
                  gradient: const [Color(0xFFFF6584), Color(0xFFFF8FA3)],
                  onTap: () => context.go('/scanner'),
                ),
                _ActionTile(
                  label: 'View Grades',
                  subtitle: 'Track GPA & results',
                  icon: Icons.bar_chart_rounded,
                  gradient: const [Color(0xFF43E97B), Color(0xFF38F9D7)],
                  onTap: () => context.go('/grades'),
                ),
                _ActionTile(
                  label: 'Send Email Reports',
                  subtitle: 'Notify students via email',
                  icon: Icons.mark_email_read_rounded,
                  gradient: const [Color(0xFFF7971E), Color(0xFFFFD200)],
                  onTap: () => context.go('/email'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> colors;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.colors,
  });

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: LinearGradient(colors: colors),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: const TextStyle(
                  color: kTextPrimary,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(title,
                  style: const TextStyle(color: kTextSecondary, fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final VoidCallback onTap;

  const _ActionTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: GlassCard(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(label,
                        style: const TextStyle(
                            color: kTextPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 15)),
                    Text(subtitle,
                        style: const TextStyle(
                            color: kTextSecondary, fontSize: 12)),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded,
                  color: kTextSecondary, size: 14),
            ],
          ),
        ),
      ),
    );
  }
}
