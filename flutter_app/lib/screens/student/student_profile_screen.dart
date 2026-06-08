import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../services/api_service.dart';
import '../../theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  final api = ApiService();
  Map<String, dynamic>? _profile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
  }

  void _fetchProfile() async {
    try {
      final data = await api.getMap('/portal/profile');
      if (mounted) {
        setState(() {
          _profile = data;
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
    final auth = context.watch<AuthProvider>();

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
                    Text(
                      'My Profile',
                      style: TextStyle(
                        color: tp,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              if (_isLoading)
                const Expanded(
                  child: Center(child: CircularProgressIndicator()),
                )
              else ...[
                // Avatar section
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  child: Column(
                    children: [
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [kAccent1, kAccent2],
                          ),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Center(
                          child: Text(
                            _getInitials(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 32,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '${_profile?['first_name'] ?? ''} ${_profile?['last_name'] ?? ''}',
                        style: TextStyle(
                          color: tp,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Student ID: ${_profile?['student_id'] ?? ''}',
                        style: TextStyle(color: ts, fontSize: 13),
                      ),
                    ],
                  ),
                ),

                // Info cards
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Column(
                    children: [
                      _InfoTile(
                        label: 'Email',
                        value: _profile?['email'] ?? auth.userEmail ?? 'N/A',
                        icon: Icons.email_rounded,
                      ),
                      const SizedBox(height: 8),
                      _InfoTile(
                        label: 'Course',
                        value: _profile?['course'] ?? 'N/A',
                        icon: Icons.school_rounded,
                      ),
                      const SizedBox(height: 8),
                      _InfoTile(
                        label: 'Year Level',
                        value: '${_profile?['year_level'] ?? 'N/A'}',
                        icon: Icons.grade_rounded,
                      ),
                      const SizedBox(height: 8),
                      _InfoTile(
                        label: 'Section',
                        value: _profile?['section_label'] ?? 'Not assigned',
                        icon: Icons.group_rounded,
                      ),
                    ],
                  ),
                ),
              ],

              const Spacer(),

              // Logout button
              Padding(
                padding: const EdgeInsets.all(16),
                child: SizedBox(
                  width: double.infinity,
                  child: GlassCard(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    blurIntensity: 3,
                    onTap: () {
                      auth.logout();
                      context.go('/login');
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.logout_rounded,
                            color: Colors.redAccent, size: 18),
                        const SizedBox(width: 8),
                        Text(
                          'Sign Out',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getInitials() {
    final first = _profile?['first_name'] as String? ?? '';
    final last = _profile?['last_name'] as String? ?? '';
    if (first.isNotEmpty && last.isNotEmpty) {
      return '${first[0]}${last[0]}'.toUpperCase();
    }
    return '?';
  }
}

class _InfoTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _InfoTile({
    required this.label,
    required this.value,
    required this.icon,
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
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: kAccent2.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: kAccent2, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: TextStyle(color: ts, fontSize: 11)),
                const SizedBox(height: 2),
                Text(value,
                    style: TextStyle(
                        color: tp,
                        fontSize: 14,
                        fontWeight: FontWeight.w500)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}