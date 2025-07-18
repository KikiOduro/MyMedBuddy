import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as p;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Screens
import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/medication_schedule.dart';
import 'screens/health_logs_page.dart';
import 'screens/appointments.dart';
import 'screens/profile.dart';

// Providers
import 'providers/theme_provider.dart';

void main() {
  runApp(
    ProviderScope(
      child: p.ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyMedBuddyApp(),
      ),
    ),
  );
}

class MyMedBuddyApp extends StatelessWidget {
  const MyMedBuddyApp({super.key});

  // Decides which screen to show first
  Future<Widget> getInitialScreen() async {
    final prefs = await SharedPreferences.getInstance();
    final welcomeSeen = prefs.getBool('welcome_seen') ?? false;
    final onboardingDone = prefs.getBool('onboarding_done') ?? false;

    if (!welcomeSeen) {
      return const WelcomeScreen();
    } else if (!onboardingDone) {
      return const OnboardingScreen();
    } else {
      return const HomeScreen();
    }
  }

  @override
  Widget build(BuildContext context) {
    return p.Consumer<ThemeProvider>(
      builder: (context, themeProvider, _) {
        return MaterialApp(
          title: 'MyMedBuddy',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            brightness: Brightness.light,
            primarySwatch: Colors.pink,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            primarySwatch: Colors.pink,
          ),
          themeMode: themeProvider.themeMode,
          home: FutureBuilder<Widget>(
            future: getInitialScreen(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return snapshot.data!;
            },
          ),
          routes: {
            '/welcome': (context) => const WelcomeScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
            '/home': (context) => const HomeScreen(),
            '/medication': (context) => const MedicationScheduleScreen(),
            '/logs': (context) => const HealthLogsPage(),
            '/appointments': (context) => const AppointmentScreen(),
            '/profile': (context) => const ProfileScreen(),
          },
        );
      },
    );
  }
}
