import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:go_router/go_router.dart';

import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/subject_provider.dart';
import 'providers/exam_provider.dart';
import 'theme/app_theme.dart';
import 'screens/splash_screen.dart';
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
  await Supabase.initialize(url: supabaseUrl, anonKey: supabaseAnonKey);
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
        debugShowCheckedModeBanner: false,
      ),
    );
  }

  GoRouter _buildRouter() {
    return GoRouter(
      initialLocation: '/splash',
      redirect: (context, state) {
        final authProvider = context.read<AuthProvider>();
        final isAuthenticated = authProvider.isAuthenticated;
        final loc = state.matchedLocation;
        final isAuthScreen = loc == '/login' || loc == '/signup' || loc == '/splash';
        if (!isAuthenticated && !isAuthScreen) return '/login';
        return null;
      },
      errorBuilder: (context, state) => Scaffold(
        body: Center(child: Text('Page not found: ${state.error}')),
      ),
      routes: [
        GoRoute(
          path: '/splash',
          pageBuilder: (_, __) => _fadePage(const SplashScreen()),
        ),
        GoRoute(
          path: '/login',
          pageBuilder: (_, __) => _slidePage(const LoginScreen()),
        ),
        GoRoute(
          path: '/signup',
          pageBuilder: (_, __) => _slidePage(const SignupScreen()),
        ),
        GoRoute(
          path: '/dashboard',
          pageBuilder: (_, __) => _fadePage(const DashboardScreen()),
        ),
        GoRoute(
          path: '/students',
          pageBuilder: (_, __) => _slideUpPage(const StudentsScreen()),
        ),
        GoRoute(
          path: '/scanner',
          pageBuilder: (_, __) => _slideUpPage(const ScannerScreen()),
        ),
        GoRoute(
          path: '/grades',
          pageBuilder: (_, __) => _slideUpPage(const GradesScreen()),
        ),
        GoRoute(
          path: '/email',
          pageBuilder: (_, __) => _slideUpPage(const EmailScreen()),
        ),
        GoRoute(
          path: '/subjects',
          pageBuilder: (_, __) => _slideUpPage(const SubjectsScreen()),
        ),
      ],
    );
  }
}

// Fade transition
CustomTransitionPage _fadePage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: CurvedAnimation(parent: animation, curve: Curves.easeInOut),
        child: child,
      );
    },
  );
}

// Slide from right transition
CustomTransitionPage _slidePage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: const Duration(milliseconds: 400),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(1.0, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutCubic));
      return SlideTransition(
        position: slide,
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}

// Slide from bottom transition
CustomTransitionPage _slideUpPage(Widget child) {
  return CustomTransitionPage(
    child: child,
    transitionDuration: const Duration(milliseconds: 450),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final slide = Tween<Offset>(
        begin: const Offset(0.0, 1.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOutQuart));
      return SlideTransition(
        position: slide,
        child: child,
      );
    },
  );
}
