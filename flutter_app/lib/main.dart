import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/subject_provider.dart';
import 'providers/exam_provider.dart';
import 'theme/app_theme.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/students_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/grades_screen.dart';
import 'screens/email_screen.dart';
import 'screens/subjects_screen.dart';

const String supabaseUrl = 'https://spbzddkeklaexgukmrxn.supabase.co';
const String supabaseAnonKey = 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6InNwYnpkZGtla2xhZXhndWttcnhuIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzczMzg2NjIsImV4cCI6MjA5MjkxNDY2Mn0.xK8vIBG_NLGwSxmebt2QRiT54Qr-LLy2CARNxktengc';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => StudentProvider()),
        ChangeNotifierProvider(create: (_) => SubjectProvider()),
        ChangeNotifierProvider(create: (_) => ExamProvider()),
      ],
      child: MaterialApp.router(
        title: 'EduScan',
        theme: buildAppTheme(),
        routerConfig: _buildRouter(),
      ),
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/login',
      redirect: (context, state) {
        final authProvider = context.read<AuthProvider>();
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login' ||
            state.matchedLocation == '/signup';

        if (!isAuthenticated && !isLoggingIn) return '/login';
        if (isAuthenticated && isLoggingIn) return '/dashboard';
        return null;
      },
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.error}')),
      ),
      routes: [
        GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
        GoRoute(path: '/signup', builder: (_, __) => const SignupScreen()),
        GoRoute(path: '/dashboard', builder: (_, __) => const DashboardScreen()),
        GoRoute(path: '/students', builder: (_, __) => const StudentsScreen()),
        GoRoute(path: '/scanner', builder: (_, __) => const ScannerScreen()),
        GoRoute(path: '/grades', builder: (_, __) => const GradesScreen()),
        GoRoute(path: '/email', builder: (_, __) => const EmailScreen()),
        GoRoute(path: '/subjects', builder: (_, __) => const SubjectsScreen()),
      ],
    );
  }
}
