import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/subject_provider.dart';
import 'providers/exam_provider.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/students_screen.dart';
import 'screens/scanner_screen.dart';
import 'screens/grades_screen.dart';
import 'screens/email_screen.dart';
import 'screens/subjects_screen.dart';

const String supabaseUrl = 'https://YOUR_SUPABASE_URL.supabase.co';
const String supabaseAnonKey = 'YOUR_SUPABASE_ANON_KEY';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: supabaseUrl,
    anonKey: supabaseAnonKey,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

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
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF2563eb),
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          fontFamily: 'Geist',
        ),
        routerConfig: _buildRouter(),
      ),
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      redirect: (context, state) {
        final authProvider = context.read<AuthProvider>();
        final isAuthenticated = authProvider.isAuthenticated;
        final isLoggingIn = state.matchedLocation == '/login' ||
            state.matchedLocation == '/signup';

        if (!isAuthenticated && !isLoggingIn) {
          return '/login';
        }

        if (isAuthenticated && isLoggingIn) {
          return '/dashboard';
        }

        return null;
      },
      routes: [
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/signup',
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const DashboardScreen(),
        ),
        GoRoute(
          path: '/students',
          builder: (context, state) => const StudentsScreen(),
        ),
        GoRoute(
          path: '/scanner',
          builder: (context, state) => const ScannerScreen(),
        ),
        GoRoute(
          path: '/grades',
          builder: (context, state) => const GradesScreen(),
        ),
        GoRoute(
          path: '/email',
          builder: (context, state) => const EmailScreen(),
        ),
        GoRoute(
          path: '/subjects',
          builder: (context, state) => const SubjectsScreen(),
        ),
      ],
    );
  }
}
