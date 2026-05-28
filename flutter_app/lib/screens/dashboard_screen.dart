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
          _totalStudents = (data['total_students'] ?? 0) as int;
          _totalSubjects = (data['total_subjects'] ?? 0) as int;
          _totalExams = (data['total_exams'] ?? 0) as int;
          _totalResults = (data['total_results'] ?? 0) as int;
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      appBar: AppBar(
        backgroundColor: isDark ? dBg2.withOpacity(0.96) : Colors.white.withOpacity(0.92),
        elevation: 0,
        iconTheme: IconThemeData(color: tp),
        title: Text('Dashboard', style: TextStyle(color: tp, fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.notifications_rounded, color: tp),
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: AppBackground(
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FadeSlideIn(
                  delay: const Duration(milliseconds: 100),
                  beginOffset: const Offset(0, -0.05),
                  child: GlassCard(
                    padding: const EdgeInsets.all(20),
                    blurIntensity: 5,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Good morning,', style: TextStyle(color: ts, fontSize: 14)),
                        const SizedBox(height: 8),
                        Text('Welcome back to PhotoSync', style: TextStyle(color: tp, fontSize: 22, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 12),
                        Text('Monitor progress, scan papers, and manage your students from one place.', style: TextStyle(color: ts, fontSize: 13, height: 1.5)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 200),
                  child: GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: 12,
                    crossAxisSpacing: 12,
                    childAspectRatio: 1.3,
                    children: [
                      _StatCard(title: 'Students', value: '$_totalStudents', icon: Icons.people_rounded, colors: const [kAccent1, kAccent2], onTap: () => context.go('/students')),
                      _StatCard(title: 'Subjects', value: '$_totalSubjects', icon: Icons.menu_book_rounded, colors: const [Color(0xFFB388FF), Color(0xFF7C4DFF)], onTap: () => context.go('/subjects')),
                      _StatCard(title: 'Scans', value: '$_totalExams', icon: Icons.document_scanner_rounded, colors: const [Color(0xFFE040FB), Color(0xFF7C4DFF)], onTap: () => context.go('/scanner')),
                      _StatCard(title: 'Results', value: '$_totalResults', icon: Icons.bar_chart_rounded, colors: const [kAccent1, kAccent2], onTap: () => context.go('/grades')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 300),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Quick links', style: TextStyle(color: tp, fontSize: 18, fontWeight: FontWeight.w700)),
                      Text('Tap to jump', style: TextStyle(color: ts, fontSize: 12)),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 350),
                  child: Wrap(
                    runSpacing: 12,
                    spacing: 12,
                    children: [
                      _ActionTile(label: 'Students', subtitle: 'Manage learners', icon: Icons.people_rounded, gradient: const [kAccent1, kAccent2], onTap: () => context.go('/students')),
                      _ActionTile(label: 'Subjects', subtitle: 'Manage courses', icon: Icons.menu_book_rounded, gradient: const [Color(0xFFB388FF), Color(0xFF7C4DFF)], onTap: () => context.go('/subjects')),
                      _ActionTile(label: 'Scanner', subtitle: 'Upload test papers', icon: Icons.document_scanner_rounded, gradient: const [Color(0xFFE040FB), Color(0xFF7C4DFF)], onTap: () => context.go('/scanner')),
                      _ActionTile(label: 'Grades', subtitle: 'Review results', icon: Icons.bar_chart_rounded, gradient: const [kAccent1, kAccent2], onTap: () => context.go('/grades')),
                      _ActionTile(label: 'Sections', subtitle: 'Organize classes', icon: Icons.group_rounded, gradient: const [Color(0xFF4DB6AC), Color(0xFF26A69A)], onTap: () => context.go('/sections')),
                      _ActionTile(label: 'Course Structure', subtitle: 'View hierarchy', icon: Icons.folder_rounded, gradient: const [Color(0xFF7B1FA2), Color(0xFF512DA8)], onTap: () => context.go('/hierarchy')),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                FadeSlideIn(
                  delay: const Duration(milliseconds: 400),
                  child: GlassCard(
                    padding: const EdgeInsets.all(16),
                    blurIntensity: 3,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(children: [const Icon(Icons.groups_rounded, color: kAccent1, size: 16), const SizedBox(width: 8), Text('Team', style: TextStyle(color: tp, fontWeight: FontWeight.bold, fontSize: 14))]),
                        const SizedBox(height: 14),
                        const _TeamMember(name: 'Habibun-najal Kayting', role: 'Lead Developer', email: 'kayting4k@gmail.com', colors: [kAccent1, kAccent2], icon: Icons.code_rounded),
                        const SizedBox(height: 10),
                        const _TeamMember(name: 'Hareeja Montenegro', role: 'QA & Support', colors: [Color(0xFFE040FB), kAccent1], icon: Icons.verified_rounded),
                        const SizedBox(height: 10),
                        const _TeamMember(name: 'Mohd Shaffiqh Anang', role: 'Docs & Testing', colors: [Color(0xFFB388FF), Color(0xFF7C4DFF)], icon: Icons.description_rounded),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: const Padding(padding: EdgeInsets.only(bottom: 8, right: 4), child: AIAssistantBubble()),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title; final String value; final IconData icon; final List<Color> colors; final VoidCallback? onTap;
  const _StatCard({required this.title, required this.value, required this.icon, required this.colors, this.onTap});

  @override
  Widget build(BuildContext context) {
    final tp = context.textPrimary; final ts = context.textSecondary;
    return GlassCard(padding: const EdgeInsets.all(14), blurIntensity: 3, onTap: onTap, child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Container(padding: const EdgeInsets.all(8), decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 18)),
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(value, style: TextStyle(color: tp, fontSize: 24, fontWeight: FontWeight.bold)), Text(title, style: TextStyle(color: ts, fontSize: 11))]),
    ]));
  }
}

class _TeamMember extends StatelessWidget {
  final String name; final String role; final String? email; final List<Color> colors; final IconData icon;
  const _TeamMember({required this.name, required this.role, this.email, required this.colors, required this.icon});

  @override
  Widget build(BuildContext context) {
    final tp = context.textPrimary; final ts = context.textSecondary;
    return Row(children: [
      Container(padding: const EdgeInsets.all(7), decoration: BoxDecoration(gradient: LinearGradient(colors: colors), borderRadius: BorderRadius.circular(8)), child: Icon(icon, color: Colors.white, size: 14)),
      const SizedBox(width: 10),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(name, style: TextStyle(color: tp, fontWeight: FontWeight.w600, fontSize: 12)), Text(role, style: TextStyle(color: ts, fontSize: 10)), if (email != null) Text(email!, style: const TextStyle(color: kAccent1, fontSize: 10))])),
    ]);
  }
}

class _ActionTile extends StatelessWidget {
  final String label; final String subtitle; final IconData icon; final List<Color> gradient; final VoidCallback onTap;
  const _ActionTile({required this.label, required this.subtitle, required this.icon, required this.gradient, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final tp = context.textPrimary; final ts = context.textSecondary;
    return Padding(padding: const EdgeInsets.only(bottom: 10), child: GlassCard(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12), blurIntensity: 3, onTap: onTap, child: Row(children: [
      Container(padding: const EdgeInsets.all(9), decoration: BoxDecoration(gradient: LinearGradient(colors: gradient), borderRadius: BorderRadius.circular(10)), child: Icon(icon, color: Colors.white, size: 20)),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(label, style: TextStyle(color: tp, fontWeight: FontWeight.w600, fontSize: 14)), Text(subtitle, style: TextStyle(color: ts, fontSize: 11))])),
      Icon(Icons.arrow_forward_ios_rounded, color: ts, size: 12),
    ])));
  }
}