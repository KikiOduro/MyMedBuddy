import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String name = '';
  String condition = '';
  String reminderTime = '';
  List<String> appointmentHistory = [];
  Map<String, dynamic> nextMedication = {};
  List<Map<String, dynamic>> missedDoses = [];

  int _selectedIndex = 0;

  // Load user data and medication details from SharedPreferences
  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawMeds = prefs.getStringList('medication_list') ?? [];

    final meds = rawMeds
        .map((m) => jsonDecode(m))
        .whereType<Map<String, dynamic>>()
        .toList();

    DateTime now = DateTime.now();

    final pendingMeds = meds
        .map(
          (m) => {...m, 'parsedTime': DateTime.tryParse(m['dateTime'] ?? '')},
        )
        .where((m) => m['isTaken'] == 'false' && m['parsedTime'] != null)
        .toList();

    // Sort pending meds by date
    pendingMeds.sort(
      (a, b) =>
          (a['parsedTime'] as DateTime).compareTo(b['parsedTime'] as DateTime),
    );

    // Find the next upcoming med
    final nextMed = pendingMeds.firstWhere(
      (m) => (m['parsedTime'] as DateTime).isAfter(now),
      orElse: () => {},
    );

    // Filter missed doses
    final missed = pendingMeds
        .where((m) => (m['parsedTime'] as DateTime).isBefore(now))
        .toList();

    setState(() {
      name = prefs.getString('name') ?? 'User';
      condition = prefs.getString('condition') ?? 'Not specified';
      reminderTime =
          prefs.getString('reminderTime') ?? 'Check your health logs';
      appointmentHistory = prefs.getStringList('appointment_history') ?? [];
      nextMedication = nextMed;
      missedDoses = missed;
    });
  }

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  // Handle bottom nav actions
  void _onItemTapped(int index) async {
    setState(() {
      _selectedIndex = index;
    });

    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/');
        break;
      case 1:
        Navigator.pushNamed(context, '/medication');
        break;
      case 2:
        Navigator.pushNamed(context, '/logs');
        break;
      case 3:
        final result = await Navigator.pushNamed(context, '/appointments');
        if (result == true) {
          _loadUserData(); // Refresh if new appointment is made
        }
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  // Format time nicely
  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 30),

                  // Welcome section
                  Text(
                    'Welcome back,',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      fontSize: 22,
                      color: Colors.grey.shade700,
                    ),
                  ),
                  Text(
                    name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Condition & Reminder
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: theme.cardColor,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.pinkAccent.withAlpha(25),
                          blurRadius: 12,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          '🩺 Condition:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(condition, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 16),
                        Text(
                          '⏰ Medication Reminder:',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey.shade600,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reminderTime,
                          style: const TextStyle(fontSize: 18),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Next medication section
                  Text(
                    'Next Medication',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (nextMedication.isEmpty)
                    const Text(
                      'You’re all caught up!',
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: theme.cardColor,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${nextMedication['name'] ?? 'Medication'} at ${nextMedication['dateTime'] != null ? formatTime(DateTime.parse(nextMedication['dateTime'])) : 'Unknown'}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),

                  const SizedBox(height: 24),

                  // Missed doses section
                  Text(
                    'Missed Doses',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (missedDoses.isEmpty)
                    const Text(
                      'No missed doses!',
                      style: TextStyle(color: Color.fromARGB(255, 0, 0, 0)),
                    )
                  else
                    ...missedDoses.map(
                      (med) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${med['name'] ?? 'Medication'} at ${med['dateTime'] != null ? formatTime(DateTime.parse(med['dateTime'])) : 'Unknown'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),

                  const SizedBox(height: 30),

                  // Appointment history
                  Text(
                    '📅 Appointment History:',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                  const SizedBox(height: 8),
                  if (appointmentHistory.isEmpty)
                    const Text(
                      'No appointments yet.',
                      style: TextStyle(
                        fontSize: 16,
                        color: Color.fromARGB(255, 0, 0, 0),
                      ),
                    )
                  else
                    ...appointmentHistory.reversed.map(
                      (appointment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(
                          appointment,
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color.fromARGB(255, 0, 0, 0),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),

      // Bottom nav bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.medication),
            label: 'Medication',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.insert_chart),
            label: 'Logs',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Appointments',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}
