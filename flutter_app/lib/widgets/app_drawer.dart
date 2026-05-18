import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../providers/theme_provider.dart';
import '../theme/app_theme.dart';

class AppDrawer extends StatelessWidget {
  final String currentRoute;

  const AppDrawer({super.key, required this.currentRoute});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return Drawer(
      backgroundColor: isDark ? dBg1 : lBg,
      width: 280,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
              decoration: BoxDecoration(
                gradient: isDark
                    ? const LinearGradient(
                        colors: [Color(0xFF0D1B4B), Color(0xFF1A0533)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          const Color(0xFFE8F0FF),
                          const Color(0xFFF0E8FF),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                border: Border(
                  bottom: BorderSide(
                    color: isDark ? dGlassBorder : lGlassBorder,
                    width: 1,
                  ),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [kAccent1, kAccent2]),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(Icons.document_scanner_rounded,
                        color: Colors.white, size: 28),
                  ),
                  const SizedBox(height: 14),
                  Text('PhotoSync',
                      style: TextStyle(
                          color: isDark ? dTextPrimary : lTextPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 1)),
                  if (auth.userEmail != null) ...[
                    const SizedBox(height: 4),
                    Text(auth.userEmail!,
                        style: TextStyle(
                          color: isDark ? dTextSecondary : lTextSecondary,
                          fontSize: 12,
                        )),
                  ],
                ],
              ),
            ),

            // Menu items
            Expanded(
              child: ListView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                children: [
                  _DrawerItem(
                    icon: Icons.dashboard_rounded,
                    label: 'Dashboard',
                    route: '/dashboard',
                    currentRoute: currentRoute,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/dashboard');
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Text('MANAGE',
                        style: TextStyle(
                            color: isDark ? dTextSecondary : lTextSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2)),
                  ),
                  _DrawerItem(
                    icon: Icons.people_rounded,
                    label: 'Students',
                    route: '/students',
                    currentRoute: currentRoute,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/students');
                    },
                    isDark: isDark,
                  ),
                  _DrawerItem(
                    icon: Icons.menu_book_rounded,
                    label: 'Subjects',
                    route: '/subjects',
                    currentRoute: currentRoute,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/subjects');
                    },
                    isDark: isDark,
                  ),
                  _DrawerItem(
                    icon: Icons.document_scanner_rounded,
                    label: 'Scanner',
                    route: '/scanner',
                    currentRoute: currentRoute,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/scanner');
                    },
                    isDark: isDark,
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
                    child: Text('REPORTS',
                        style: TextStyle(
                            color: isDark ? dTextSecondary : lTextSecondary,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1.2)),
                  ),
                  _DrawerItem(
                    icon: Icons.bar_chart_rounded,
                    label: 'Grades',
                    route: '/grades',
                    currentRoute: currentRoute,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/grades');
                    },
                    isDark: isDark,
                  ),
                  _DrawerItem(
                    icon: Icons.mark_email_read_rounded,
                    label: 'Send Emails',
                    route: '/email',
                    currentRoute: currentRoute,
                    onTap: () {
                      Navigator.pop(context);
                      context.go('/email');
                    },
                    isDark: isDark,
                  ),
                ],
              ),
            ),

            // Theme toggle
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? dGlassBorder : lGlassBorder,
                    width: 1,
                  ),
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kAccent1.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
                    color: kAccent1,
                    size: 20,
                  ),
                ),
                title: Text(
                  isDark ? 'Light Mode' : 'Dark Mode',
                  style: TextStyle(
                    color: isDark ? dTextPrimary : lTextPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                trailing: Switch.adaptive(
                  value: !isDark,
                  onChanged: (_) => themeProvider.toggle(),
                  activeColor: kAccent2,
                ),
                onTap: () => themeProvider.toggle(),
              ),
            ),

            // Logout
            Container(
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(
                    color: isDark ? dGlassBorder : lGlassBorder,
                    width: 1,
                  ),
                ),
              ),
              child: ListTile(
                leading: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kAccent3.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.logout_rounded,
                      color: kAccent3, size: 20),
                ),
                title: const Text('Logout',
                    style: TextStyle(color: kAccent3, fontWeight: FontWeight.w600)),
                onTap: () {
                  Navigator.pop(context);
                  context.read<AuthProvider>().logout();
                  context.go('/login');
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String route;
  final String currentRoute;
  final VoidCallback onTap;
  final bool isDark;

  const _DrawerItem({
    required this.icon,
    required this.label,
    required this.route,
    required this.currentRoute,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final isActive = currentRoute == route;
    final textCol = isActive ? kAccent1 : (isDark ? dTextSecondary : lTextSecondary);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      decoration: BoxDecoration(
        color: isActive ? kAccent1.withValues(alpha: 0.15) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: textCol, size: 22),
        title: Text(label,
            style: TextStyle(
                color: textCol,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                fontSize: 14)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}