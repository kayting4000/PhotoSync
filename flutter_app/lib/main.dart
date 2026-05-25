import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'providers/auth_provider.dart';
import 'providers/student_provider.dart';
import 'providers/subject_provider.dart';
import 'providers/exam_provider.dart';
import 'providers/theme_provider.dart';
import 'providers/section_provider.dart';
import 'providers/academic_term_provider.dart';
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
import 'screens/sections_screen.dart';
import 'screens/academic_terms_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    systemNavigationBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
  ));
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
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => SectionProvider()),
        ChangeNotifierProvider(create: (_) => AcademicTermProvider()),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) {
          return MaterialApp.router(
            title: 'PhotoSync',
            theme: buildLightTheme(),
            darkTheme: buildDarkTheme(),
            themeMode: themeProvider.themeMode,
            routerConfig: _buildRouter(),
            debugShowCheckedModeBanner: false,
          );
        },
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
        GoRoute(
          path: '/sections',
          pageBuilder: (_, __) => _slideUpPage(const SectionsScreen()),
        ),
        GoRoute(
          path: '/academic-terms',
          pageBuilder: (_, __) => _slideUpPage(const AcademicTermsScreen()),
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
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}