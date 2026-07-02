import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'firebase_options.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/register_screen.dart';
import 'screens/auth/startup_pending_screen.dart';
import 'screens/student/student_home_screen.dart';
import 'screens/student/opportunity_detail_screen.dart';
import 'screens/student/apply_screen.dart';
import 'screens/student/my_applications_screen.dart';
import 'screens/startup/startup_home_screen.dart';
import 'screens/startup/create_opportunity_screen.dart';
import 'screens/startup/applicants_screen.dart';
import 'screens/admin/admin_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends ConsumerWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'ALU Internship App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/login',
      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/startup-pending': (context) => const StartupPendingScreen(),
        '/student-home': (context) => const StudentHomeScreen(),
        '/my-applications': (context) => const MyApplicationsScreen(),
        '/startup-home': (context) => const StartupHomeScreen(),
        '/admin-home': (context) => const AdminHomeScreen(),
        '/opportunity-detail': (context) {
          final id =
              ModalRoute.of(context)!.settings.arguments as String;
          return OpportunityDetailScreen(opportunityId: id);
        },
        '/apply': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return ApplyScreen(
            opportunityId: args['opportunityId'],
            startupId: args['startupId'],
            opportunityTitle: args['opportunityTitle'],
            studentUid: args['studentUid'],
            studentName: args['studentName'],
          );
        },
        '/create-opportunity': (context) {
          final args = ModalRoute.of(context)!.settings.arguments
              as Map<String, dynamic>;
          return CreateOpportunityScreen(
            startupId: args['startupId'],
            startupName: args['startupName'],
          );
        },
        '/applicants': (context) {
          final id =
              ModalRoute.of(context)!.settings.arguments as String;
          return ApplicantsScreen(opportunityId: id);
        },
      },
    );
  }
}