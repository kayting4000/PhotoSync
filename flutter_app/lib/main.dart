import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'screens/dashboard_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/signup_screen.dart';
import 'screens/student/student_dashboard_screen.dart';
import 'screens/student/student_grades_screen.dart';
import 'screens/student/student_attendance_screen.dart';
import 'screens/student/student_exams_screen.dart';
import 'screens/student/student_profile_screen.dart';
import 'screens/feedback_screen.dart';
import 'services/service_locator.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize offline services
  await connectivityService.init();
  await syncService.init();

  // create auth provider — session is restored asynchronously in constructor
  final authProvider = AuthProvider();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AuthProvider>.value(value: authProvider),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    // while init is happening show a simple loading screen
    if (!auth.initialized) {
      return const MaterialApp(
        home: Scaffold(body: Center(child: CircularProgressIndicator())),
      );
    }

    // Determine initial route based on role
    String initialRoute;
    if (!auth.isAuthenticated) {
      initialRoute = '/login';
    } else if (auth.isStudent) {
      initialRoute = '/student/dashboard';
    } else {
      initialRoute = '/dashboard';
    }

    return MaterialApp(
      title: 'PhotoSync',
      debugShowCheckedModeBanner: false,
      initialRoute: initialRoute,
      routes: {
        '/login': (ctx) => const LoginScreen(),
        '/signup': (ctx) => const SignupScreen(),
        '/dashboard': (ctx) => const DashboardScreen(),
        // Student portal routes
        '/student/dashboard': (ctx) => const StudentDashboardScreen(),
        '/student/grades': (ctx) => const StudentGradesScreen(),
        '/student/attendance': (ctx) => const StudentAttendanceScreen(),
        '/student/exams': (ctx) => const StudentExamsScreen(),
        '/student/profile': (ctx) => const StudentProfileScreen(),
        '/feedback': (ctx) => const FeedbackScreen(),
      },
    );
  }
}