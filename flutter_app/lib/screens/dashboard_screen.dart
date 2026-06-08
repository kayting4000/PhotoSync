import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../widgets/fade_slide_in.dart';
import '../widgets/app_drawer.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final api = ApiService();
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
      final data = await api.getMap('/dashboard/');
      if (mounted) {
        setState(() {
          _totalStudents = (data['total_students'] ?? 0 as num).toInt();
          _totalSubjects = (data['total_subjects'] ?? 0 as num).toInt();
          _totalExams = (data['total_exams'] ?? 0 as num).toInt();
          _totalResults = (data['total_results'] ?? 0 as num).toInt();
        });
      }
    } catch (e) {
      debugPrint('Error fetching dashboard data: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final tp = context.textPrimary;
    final ts = context.textSecondary;
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Compact Header with hamburger menu
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  beginOffset: const Offset(0, -0.05),
                  child: Row(
                    children: [
                      Builder(
                        builder: (context) => GestureDetector(
                          onTap: () => Scaffold.of(context).openDrawer(),
                          child: const GlassCard(
                            padding: EdgeInsets.all(10),
                            borderRadius: 14,
                            blurIntensity: 3,
                            child: Icon(Icons.menu_rounded,
                                color: kAccent2, size: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'PhotoSync',
                              style: TextStyle(
                                color: tp,
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                            Text(
                              'Welcome back! 👋',
                              style: TextStyle(color: ts, fontSize: 13),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Compact Stats grid
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.4,
                    children: [
                      _StatCard(
                        title: 'Students',
                        value: '$_totalStudents',
                        icon: Icons.people_rounded,
                        colors: const [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
                        onTap: () => context.go('/students'),
                      ),
                      _StatCard(
                        title: 'Subjects',
                        value: '$_totalSubjects',
                        icon: Icons.menu_book_rounded,
                        colors: const [Color(0xFF48CAE4), Color(0xFF0096C7)],
                        onTap: () => context.go('/subjects'),
                      ),
                      _StatCard(
                        title: 'Exams',
                        value: '$_totalExams',
                        icon: Icons.assignment_rounded,
                        colors: const [Color(0xFFFF6584), Color(0xFFFF8FA3)],
                        onTap: () => context.go('/scanner'),
                      ),
                      _StatCard(
                        title: 'Results',
                        value: '$_totalResults',
                        icon: Icons.bar_chart_rounded,
                        colors: const [Color(0xFF43E97B), Color(0xFF38F9D7)],
                        onTap: () => context.go('/grades'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Quick Actions header
                FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(colors: [kAccent1, kAccent2]),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.flash_on_rounded,
                            color: Colors.white, size: 16),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        'Quick Actions',
                        style: TextStyle(
                          color: tp,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),

                FadeSlideIn(
                  delay: const Duration(milliseconds: 350),
                  child: const _ActionTile(
                    label: 'Manage Students',
                    subtitle: 'Add, edit & view students',
                    icon: Icons.people_rounded,
                    gradient: [Color(0xFF6C63FF), Color(0xFF9B8FFF)],
                    route: '/students',
                  ),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 400),
                  child: const _ActionTile(
                    label: 'Manage Subjects',
                    subtitle: 'Configure courses & units',
                    icon: Icons.menu_book_rounded,
                    gradient: [Color(0xFF48CAE4), Color(0xFF0096C7)],
                    route: '/subjects',
                  ),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 450),
                  child: const _ActionTile(
                    label: 'Scan Test Papers',
                    subtitle: 'Upload & analyze papers',
                    icon: Icons.document_scanner_rounded,
                    gradient: [Color(0xFFFF6584), Color(0xFFFF8FA3)],
                    route: '/scanner',
                  ),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 500),
                  child: const _ActionTile(
                    label: 'View Grades',
                    subtitle: 'Track GPA & results',
                    icon: Icons.bar_chart_rounded,
                    gradient: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                    route: '/grades',
                  ),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 550),
                  child: const _ActionTile(
                    label: 'Send Email Reports',
                    subtitle: 'Notify students via email',
                    icon: Icons.mark_email_read_rounded,
                    gradient: [Color(0xFFF7971E), Color(0xFFFFD200)],
                    route: '/email',
                  ),
                ),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 600),
                  child: const _ActionTile(
                    label: 'Send Feedback',
                    subtitle: 'Report problems & suggestions',
                    icon: Icons.feedback_rounded,
                    gradient: [Color(0xFFE040FB), Color(0xFF9D4EDD)],
                    route: '/feedback',
                  ),
                ),
                const SizedBox(height: 20),

                // Compact Team info
                FadeSlideIn(
                  delay: const Duration(milliseconds: 650),
                  child: GlassCard(
                    padding: const EdgeInsets.all(14),
                    blurIntensity: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.groups_rounded, color: kAccent2, size: 16),
                            const SizedBox(width: 8),
                            Text('Development Team',
                                style: TextStyle(
                                    color: tp,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 12),
                        const _TeamMember(
                          name: 'Habibun-najal Kayting',
                          role: 'Lead Developer',
                          email: 'kayting4k@gmail.com',
                          colors: [kAccent1, kAccent2],
                          icon: Icons.code_rounded,
                        ),
                        const SizedBox(height: 8),
                        const _TeamMember(
                          name: 'Hareeja Montenegro',
                          role: 'Sub-developer & Quality Assurance',
                          colors: [kAccent3, kAccent1],
                          icon: Icons.verified_rounded,
                        ),
                        const SizedBox(height: 8),
                        const _TeamMember(
                          name: 'Mohd Shaffiqh Anang',
                          role: 'Sub-developer & Documentation',
                          colors: [Color(0xFF43E97B), Color(0xFF38F9D7)],
                          icon: Icons.description_rounded,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(bottom: 8, right: 4),
        child: SizedBox.shrink(),
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback? onTap;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.colors,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tp = context.textPrimary;
    final ts = context.textSecondary;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      blurIntensity: 3,
      onTap: onTap,
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
            child: Icon(icon, color: Colors.white, size: 18),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                    color: tp,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  )),
              Text(title,
                  style: TextStyle(color: ts, fontSize: 11)),
            ],
          ),
        ],
      ),
    );
  }
}

class _TeamMember extends StatelessWidget {
  final String name;
  final String role;
  final String? email;
  final List<Color> colors;
  final IconData icon;

  const _TeamMember({
    required this.name,
    required this.role,
    this.email,
    required this.colors,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    final tp = context.textPrimary;
    final ts = context.textSecondary;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(7),
          decoration: BoxDecoration(
            gradient: LinearGradient(colors: colors),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: Colors.white, size: 14),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name,
                  style: TextStyle(
                      color: tp,
                      fontWeight: FontWeight.w600,
                      fontSize: 12)),
              Text(role,
                  style: TextStyle(
                      color: ts, fontSize: 10)),
              if (email != null)
                Text(email!,
                    style: const TextStyle(
                        color: kAccent2, fontSize: 10)),
            ],
          ),
        ),
      ],
    );
  }
}

class _ActionTile extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final List<Color> gradient;
  final String route;

  const _ActionTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.route,
  });

  @override
  Widget build(BuildContext context) {
    final tp = context.textPrimary;
    final ts = context.textSecondary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: GlassCard(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        blurIntensity: 3,
        onTap: () => context.go(route),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(9),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label,
                      style: TextStyle(
                          color: tp,
                          fontWeight: FontWeight.w600,
                          fontSize: 14)),
                  Text(subtitle,
                      style: TextStyle(color: ts, fontSize: 11)),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, color: ts, size: 12),
          ],
        ),
      ),
    );
  }
}