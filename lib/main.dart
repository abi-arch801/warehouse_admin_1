import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:warehouse_admin_1/presentation/pages/app_theme.dart';
import 'package:warehouse_admin_1/presentation/pages/dashboard_pages.dart';
import 'package:warehouse_admin_1/presentation/pages/login_pages.dart';
import 'package:warehouse_admin_1/presentation/pages/splash_paes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(AppTheme.lightOverlay);
  runApp(const GudangProAdminApp());
}

class GudangProAdminApp extends StatelessWidget {
  const GudangProAdminApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GudangPro Admin',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.buildTheme(),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
      },
    );
  }
}
