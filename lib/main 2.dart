import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // for ThemeProvider
import 'package:flutter_riverpod/flutter_riverpod.dart'; // for Riverpod
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/welcome_screen.dart';
import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/medication_schedule.dart';
import 'screens/health_logs_page.dart';
import 'screens/appointments.dart';
import 'screens/profile.dart';

import 'providers/theme_provider.dart'; // using provider for theme only

void main() {
  runApp(
    ProviderScope( // for Riverpod
      child:ChangeNotifierProvider(
        create: (_) => ThemeProvider(),
        child: const MyMedBuddyApp(),
      ),
    ),
  );
}

class MyMedBuddyApp extends StatelessWidget {
  const MyMedBuddyApp({super.key});

  Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_done') ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
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
          home: FutureBuilder<bool>(
            future: isOnboardingDone(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                );
              }
              return snapshot.data == true
                  ? const HomeScreen()
                  : const WelcomeScreen();
            },
          ),
          routes: {
            '/home': (context) => const HomeScreen(),
            '/welcome': (context) => const WelcomeScreen(),
            '/onboarding': (context) => const OnboardingScreen(),
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
