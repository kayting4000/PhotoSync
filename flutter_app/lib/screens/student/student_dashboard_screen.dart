import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/api_service.dart';
import '../../services/service_locator.dart';
import '../../services/sync_service.dart';
import '../../theme/app_theme.dart';

class StudentDashboardScreen extends StatefulWidget {
  const StudentDashboardScreen({super.key});

  @override
  State<StudentDashboardScreen> createState() => _StudentDashboardScreenState();
}

class _StudentDashboardScreenState extends State<StudentDashboardScreen> {
  final api = ApiService();
  int _totalSubjects = 0;
  int _totalExams = 0;
  double _attendanceRate = 0.0;
  double _currentGpa = 0.0;
  bool _isLoading = true;
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    _isOnline = connectivityService.isOnline;
    connectivityService.onConnectivityChanged.listen((online) {
      if (mounted) setState(() => _isOnline = online);
    });
    _fetchDashboard();
  }

  void _fetchDashboard() async {
    try {
      final data = await api.getMap('/portal/dashboard');
      if (mounted) {
        setState(() {
          _totalSubjects = (data['total_subjects'] ?? 0 as num).toInt();
          _totalExams = (data['total_exams'] ?? 0 as num).toInt();
          _attendanceRate = (data['attendance_rate'] ?? 0.0 as num).toDouble();
          _currentGpa = (data['current_gpa'] ?? 0.0 as num).toDouble();
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
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 80),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [kAccent1, kAccent2],
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: const Icon(Icons.school_rounded,
                          color: Colors.white, size: 20),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Student Portal',
                            style: TextStyle(
                              color: tp,
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'Your academic dashboard',
                                style: TextStyle(color: ts, fontSize: 12),
                              ),
                              const SizedBox(width: 8),
                              Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: _isOnline ? Colors.green : Colors.red,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),

                if (_isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  // Stats cards
                  _StatCard(
                    title: 'Subjects Enrolled',
                    value: '$_totalSubjects',
                    icon: Icons.menu_book_rounded,
                    color: const Color(0xFF6C63FF),
                  ),
                  const SizedBox(height: 10),
                  _StatCard(
                    title: 'Exams Taken',
                    value: '$_totalExams',
                    icon: Icons.assignment_rounded,
                    color: const Color(0xFFFF6584),
                  ),
                  const SizedBox(height: 10),
                  _StatCard(
                    title: 'Attendance Rate',
                    value: '${_attendanceRate.toStringAsFixed(1)}%',
                    icon: Icons.calendar_today_rounded,
                    color: const Color(0xFF48CAE4),
                  ),
                  const SizedBox(height: 10),
                  _StatCard(
                    title: 'Current GPA',
                    value: _currentGpa.toStringAsFixed(2),
                    icon: Icons.star_rounded,
                    color: const Color(0xFF43E97B),
                  ),
                ],

                const SizedBox(height: 20),

                // Quick Links
                Text(
                  'Quick Links',
                  style: TextStyle(
                    color: tp,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 10),

                _QuickLink(
                  label: 'My Grades',
                  subtitle: 'View exam results & GPA',
                  icon: Icons.bar_chart_rounded,
                  color: const Color(0xFF6C63FF),
                  route: '/student/grades',
                ),
                _QuickLink(
                  label: 'Attendance',
                  subtitle: 'View attendance records',
                  icon: Icons.calendar_today_rounded,
                  color: const Color(0xFF48CAE4),
                  route: '/student/attendance',
                ),
                _QuickLink(
                  label: 'Exams',
                  subtitle: 'View upcoming & past exams',
                  icon: Icons.assignment_rounded,
                  color: const Color(0xFFFF6584),
                  route: '/student/exams',
                ),
                _QuickLink(
                  label: 'My Profile',
                  subtitle: 'View personal information',
                  icon: Icons.person_rounded,
                  color: const Color(0xFF43E97B),
                  route: '/student/profile',
                ),
                _QuickLink(
                  label: 'Send Feedback',
                  subtitle: 'Report problems & suggestions',
                  icon: Icons.feedback_rounded,
                  color: const Color(0xFFE040FB),
                  route: '/feedback',
                ),

                const SizedBox(height: 16),

                // Sync status
                StreamBuilder<SyncStatus>(
                  stream: syncService.onSyncStatusChanged,
                  builder: (context, snapshot) {
                    final status = snapshot.data ?? SyncStatus.idle;
                    return Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: status == SyncStatus.syncing
                            ? Colors.blue.withValues(alpha: 0.1)
                            : Colors.green.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            status == SyncStatus.syncing
                                ? Icons.sync
                                : Icons.cloud_done_rounded,
                            size: 18,
                            color: status == SyncStatus.syncing
                                ? Colors.blue
                                : Colors.green,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            status == SyncStatus.syncing
                                ? 'Syncing...'
                                : _isOnline
                                    ? 'All data synced'
                                    : 'Offline mode',
                            style: TextStyle(
                              color: status == SyncStatus.syncing
                                  ? Colors.blue
                                  : _isOnline
                                      ? Colors.green
                                      : Colors.red,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
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
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final tp = context.textPrimary;
    final ts = context.textSecondary;
    return GlassCard(
      padding: const EdgeInsets.all(14),
      blurIntensity: 3,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(value,
                    style: TextStyle(
                        color: tp,
                        fontSize: 20,
                        fontWeight: FontWeight.bold)),
                Text(title,
                    style: TextStyle(color: ts, fontSize: 11)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickLink extends StatelessWidget {
  final String label;
  final String subtitle;
  final IconData icon;
  final Color color;
  final String route;

  const _QuickLink({
    required this.label,
    required this.subtitle,
    required this.icon,
    required this.color,
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
                color: color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
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