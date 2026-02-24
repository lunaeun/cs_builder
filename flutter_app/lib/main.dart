import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'theme/app_theme.dart';
import 'providers/app_provider.dart';
import 'screens/landing_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/faq_detail_screen.dart';
import 'screens/operation_detail_screen.dart';
import 'screens/qa_detail_screen.dart';
import 'screens/scripts_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const CSBuilderApp());
}

class CSBuilderApp extends StatelessWidget {
  const CSBuilderApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppProvider()..loadFromHive(),
      child: Consumer<AppProvider>(
        builder: (ctx, provider, _) {
          return MaterialApp(
            title: 'CS Builder',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: provider.isDarkMode ? ThemeMode.dark : ThemeMode.light,
            builder: (context, child) {
              return _MobileWrapper(child: child!);
            },
            home: provider.profileCompleted
                ? const DashboardScreen()
                : const LandingScreen(),
            routes: {
              '/landing': (_) => const LandingScreen(),
              '/onboarding': (_) => const OnboardingScreen(),
              '/dashboard': (_) => const DashboardScreen(),
              '/document/faq': (_) => const FAQDetailScreen(),
              '/document/operation': (_) => const OperationDetailScreen(),
              '/document/qa': (_) => const QADetailScreen(),
              '/document/scripts': (_) => const ScriptsDetailScreen(),
            },
          );
        },
      ),
    );
  }
}

class _MobileWrapper extends StatelessWidget {
  final Widget child;
  const _MobileWrapper({required this.child});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    const maxWidth = 480.0;

    if (screenWidth <= maxWidth) {
      return child;
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF0A0A0A) : const Color(0xFFF1F5F9),
      child: Center(
        child: Container(
          width: maxWidth,
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.08),
                blurRadius: 32,
                spreadRadius: 0,
                offset: const Offset(0, 0),
              ),
            ],
          ),
          clipBehavior: Clip.hardEdge,
          child: child,
        ),
      ),
    );
  }
}