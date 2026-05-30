import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../services/api_service.dart';
import '../theme/app_theme.dart';
import '../theme/neumorphic_light_theme.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      drawer: const AppDrawer(currentRoute: '/dashboard'),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight + 8),
        child: Container(
          decoration: BoxDecoration(
            color: isDark ? kBgDeep1 : nBgBase,
            border: Border(
              bottom: BorderSide(
                color: isDark ? kGlassBorder.withValues(alpha: 0.3) : nBorder,
                width: 0.5,
              ),
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              child: Row(
                children: [
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: () => Scaffold.of(context).openDrawer(),
                      icon: Icon(
                        Icons.menu_rounded,
                        color: isDark ? kTextWhite : nTextPrimary,
                        size: 26,
                      ),
                      tooltip: 'Menu',
                      splashRadius: 24,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'PhotoSync',
                      style: AppTypography.subheading.copyWith(
                        color: isDark ? kTextWhite : nTextPrimary,
                        fontSize: 20,
                      ),
                    ),
                  ),
                  Material(
                    color: Colors.transparent,
                    child: IconButton(
                      onPressed: () {},
                      icon: Icon(
                        Icons.notifications_rounded,
                        color: isDark ? kTextWhite : nTextPrimary,
                        size: 26,
                      ),
                      tooltip: 'Notifications',
                      splashRadius: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      body: Container(
        color: isDark ? Colors.transparent : nBgBase,
        child: isDark
            ? AppBackground(
                showOrbs: true,
                child: _buildContent(context, isDark),
              )
            : _buildContent(context, isDark),
      ),
      floatingActionButton: const Padding(
        padding: EdgeInsets.only(bottom: 8, right: 4),
        child: AIAssistantBubble(),
      ),
    );
  }

  Widget _buildContent(BuildContext context, bool isDark) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            FadeSlideIn(
              delay: const Duration(milliseconds: 50),
              duration: const Duration(milliseconds: 150),
              beginOffset: const Offset(0, -0.02),
              child: isDark
                  ? GlassCard(
                      padding: const EdgeInsets.all(20),
                      blurIntensity: 5,
                      elevation: 0.8,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good morning,',
                              style: AppTypography.body.copyWith(
                                  color: context.textSecondary, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('Welcome back to PhotoSync',
                              style: AppTypography.heading.copyWith(
                                  color: context.textPrimary, fontSize: 22)),
                          const SizedBox(height: 12),
                          Text(
                              'Monitor progress, scan papers, and manage your students from one place.',
                              style: AppTypography.body.copyWith(
                                  color: context.textSecondary,
                                  fontSize: 13,
                                  height: 1.5)),
                        ],
                      ),
                    )
                  : NeumorphicCard(
                      padding: const EdgeInsets.all(20),
                      elevation: 1.2,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Good morning,',
                              style: AppTypography.body.copyWith(
                                  color: nTextSecondary, fontSize: 14)),
                          const SizedBox(height: 8),
                          Text('Welcome back to PhotoSync',
                              style: AppTypography.heading.copyWith(
                                  color: nTextPrimary, fontSize: 22)),
                          const SizedBox(height: 12),
                          Text(
                              'Monitor progress, scan papers, and manage your students from one place.',
                              style: AppTypography.body.copyWith(
                                  color: nTextSecondary,
                                  fontSize: 13,
                                  height: 1.5)),
                        ],
                      ),
                    ),
            ),
            const SizedBox(height: 20),
            FadeSlideIn(
              delay: const Duration(milliseconds: 100),
              duration: const Duration(milliseconds: 150),
              child: GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 1.3,
                children: [
                  _StatCard(
                    title: 'Students',
                    value: '$_totalStudents',
                    icon: Icons.people_rounded,
                    colors: const [kAccent1, kAccent2],
                    onTap: () => context.go('/students'),
                    isDark: isDark,
                  ),
                  _StatCard(
                    title: 'Subjects',
                    value: '$_totalSubjects',
                    icon: Icons.menu_book_rounded,
                    colors: const [Color(0xFFB388FF), Color(0xFF7C4DFF)],
                    onTap: () => context.go('/subjects'),
                    isDark: isDark,
                  ),
                  _StatCard(
                    title: 'Scans',
                    value: '$_totalExams',
                    icon: Icons.document_scanner_rounded,
                    colors: const [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                    onTap: () => context.go('/scanner'),
                    isDark: isDark,
                  ),
                  _StatCard(
                    title: 'Results',
                    value: '$_totalResults',
                    icon: Icons.bar_chart_rounded,
                    colors: const [kAccent1, kAccent2],
                    onTap: () => context.go('/grades'),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeSlideIn(
              delay: const Duration(milliseconds: 150),
              duration: const Duration(milliseconds: 150),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Quick links',
                      style: AppTypography.subheading.copyWith(
                          color: isDark ? context.textPrimary : nTextPrimary,
                          fontSize: 18)),
                  Text('Tap to jump',
                      style: AppTypography.caption.copyWith(
                          color: isDark ? context.textSecondary : nTextSecondary,
                          fontSize: 12)),
                ],
              ),
            ),
            const SizedBox(height: 12),
            FadeSlideIn(
              delay: const Duration(milliseconds: 200),
              duration: const Duration(milliseconds: 150),
              child: Wrap(
                runSpacing: 12,
                spacing: 12,
                children: [
                  _ActionTile(
                    label: 'Students',
                    subtitle: 'Manage learners',
                    icon: Icons.people_rounded,
                    gradient: const [kAccent1, kAccent2],
                    onTap: () => context.go('/students'),
                    isDark: isDark,
                  ),
                  _ActionTile(
                    label: 'Subjects',
                    subtitle: 'Manage courses',
                    icon: Icons.menu_book_rounded,
                    gradient: const [Color(0xFFB388FF), Color(0xFF7C4DFF)],
                    onTap: () => context.go('/subjects'),
                    isDark: isDark,
                  ),
                  _ActionTile(
                    label: 'Scanner',
                    subtitle: 'Upload test papers',
                    icon: Icons.document_scanner_rounded,
                    gradient: const [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                    onTap: () => context.go('/scanner'),
                    isDark: isDark,
                  ),
                  _ActionTile(
                    label: 'Grades',
                    subtitle: 'Review results',
                    icon: Icons.bar_chart_rounded,
                    gradient: const [kAccent1, kAccent2],
                    onTap: () => context.go('/grades'),
                    isDark: isDark,
                  ),
                  _ActionTile(
                    label: 'Sections',
                    subtitle: 'Organize classes',
                    icon: Icons.group_rounded,
                    gradient: const [Color(0xFF4DB6AC), Color(0xFF26A69A)],
                    onTap: () => context.go('/sections'),
                    isDark: isDark,
                  ),
                  _ActionTile(
                    label: 'Course Structure',
                    subtitle: 'View hierarchy',
                    icon: Icons.folder_rounded,
                    gradient: const [Color(0xFF7B1FA2), Color(0xFF512DA8)],
                    onTap: () => context.go('/hierarchy'),
                    isDark: isDark,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            FadeSlideIn(
              delay: const Duration(milliseconds: 250),
              duration: const Duration(milliseconds: 150),
              child: isDark
                  ? GlassCard(
                      padding: const EdgeInsets.all(16),
                      blurIntensity: 3,
                      elevation: 0.6,
                      child: _buildTeamSection(isDark),
                    )
                  : NeumorphicCard(
                      padding: const EdgeInsets.all(16),
                      elevation: 1.0,
                      child: _buildTeamSection(isDark),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTeamSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                gradient: const LinearGradient(colors: [kAccent1, kAccent2]),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.groups_rounded, color: Colors.white, size: 14),
            ),
            const SizedBox(width: 10),
            Text('Team',
                style: AppTypography.subheading.copyWith(
                    color: isDark ? context.textPrimary : nTextPrimary,
                    fontSize: 14)),
          ],
        ),
        const SizedBox(height: 14),
        _TeamMember(
          name: 'Habibun-najal Kayting',
          role: 'Lead Developer',
          email: 'kayting4k@gmail.com',
          colors: const [kAccent1, kAccent2],
          icon: Icons.code_rounded,
          isDark: isDark,
        ),
        PremiumDivider(indent: 0, endIndent: 0),
        const SizedBox(height: 10),
        _TeamMember(
          name: 'Hareeja Montenegro',
          role: 'QA & Support',
          colors: const [Color(0xFFE040FB), kAccent1],
          icon: Icons.verified_rounded,
          isDark: isDark,
        ),
        PremiumDivider(indent: 0, endIndent: 0),
        const SizedBox(height: 10),
        _TeamMember(
          name: 'Mohd Shaffiqh Anang',
          role: 'Docs & Testing',
          colors: const [Color(0xFFB388FF), Color(0xFF7C4DFF)],
          icon: Icons.description_rounded,
          isDark: isDark,
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final List<Color> colors;
  final VoidCallback? onTap;
  final bool isDark;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.colors,
    this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return isDark
        ? GlassCard(
            padding: const EdgeInsets.all(14),
            blurIntensity: 3,
            elevation: 0.8,
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
                        style: AppTypography.heading.copyWith(
                            color: context.textPrimary, fontSize: 24)),
                    Text(title,
                        style: AppTypography.caption.copyWith(
                            color: context.textSecondary, fontSize: 11)),
                  ],
                ),
              ],
            ),
          )
        : NeumorphicCard(
            padding: const EdgeInsets.all(14),
            elevation: 1.0,
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
                        style: AppTypography.heading.copyWith(
                            color: nTextPrimary, fontSize: 24)),
                    Text(title,
                        style: AppTypography.caption.copyWith(
                            color: nTextSecondary, fontSize: 11)),
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
  final bool isDark;

  const _TeamMember({
    required this.name,
    required this.role,
    this.email,
    required this.colors,
    required this.icon,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
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
                  style: AppTypography.bodyBold.copyWith(
                      color: isDark ? context.textPrimary : nTextPrimary,
                      fontSize: 12)),
              Text(role,
                  style: AppTypography.caption.copyWith(
                      color: isDark ? context.textSecondary : nTextSecondary,
                      fontSize: 10)),
              if (email != null)
                Text(email!,
                    style: AppTypography.caption.copyWith(
                        color: kAccent1, fontSize: 10)),
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
  final VoidCallback onTap;
  final bool isDark;

  const _ActionTile({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.gradient,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: isDark
          ? GlassCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              blurIntensity: 3,
              elevation: 0.6,
              onTap: onTap,
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
                            style: AppTypography.bodyBold.copyWith(
                                color: context.textPrimary, fontSize: 14)),
                        Text(subtitle,
                            style: AppTypography.caption.copyWith(
                                color: context.textSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: context.textSecondary, size: 12),
                ],
              ),
            )
          : NeumorphicCard(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              elevation: 0.8,
              onTap: onTap,
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
                            style: AppTypography.bodyBold.copyWith(
                                color: nTextPrimary, fontSize: 14)),
                        Text(subtitle,
                            style: AppTypography.caption.copyWith(
                                color: nTextSecondary, fontSize: 11)),
                      ],
                    ),
                  ),
                  Icon(Icons.arrow_forward_ios_rounded,
                      color: nTextSecondary, size: 12),
                ],
              ),
            ),
    );
  }
}
