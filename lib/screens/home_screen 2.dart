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

  Future<void> _loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final rawMeds = prefs.getStringList('medication_list') ?? [];

    final meds = rawMeds
        .map((m) => jsonDecode(m))
        .whereType<Map<String, dynamic>>()
        .toList();

    DateTime now = DateTime.now();

    final pendingMeds = meds
        .map((m) => {
              ...m,
              'parsedTime': DateTime.tryParse(m['dateTime'] ?? ''),
            })
        .where((m) => m['isTaken'] == 'false' && m['parsedTime'] != null)
        .toList();

    pendingMeds.sort((a, b) => (a['parsedTime'] as DateTime)
        .compareTo(b['parsedTime'] as DateTime));

    final nextMed = pendingMeds.firstWhere(
      (m) => (m['parsedTime'] as DateTime).isAfter(now),
      orElse: () => {},
    );

    final missed = pendingMeds
        .where((m) => (m['parsedTime'] as DateTime).isBefore(now))
        .toList();

    setState(() {
      name = prefs.getString('name') ?? 'User';
      condition = prefs.getString('condition') ?? 'Not specified';
      reminderTime = prefs.getString('reminderTime') ?? 'Not set';
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
          _loadUserData();
        }
        break;
      case 4:
        Navigator.pushNamed(context, '/profile');
        break;
    }
  }

  String formatTime(DateTime dateTime) {
    final hour = dateTime.hour.toString().padLeft(2, '0');
    final minute = dateTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 30),
                Text(
                  'Welcome back,',
                  style: theme.textTheme.bodyLarge?.copyWith(fontSize: 22, color: Colors.grey.shade700),
                ),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerLeft,
                  child: Text(
                    name,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.pinkAccent,
                    ),
                  ),
                ),
                const SizedBox(height: 40),
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
                      Text('🩺 Condition:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text(condition, style: const TextStyle(fontSize: 18)),
                      const SizedBox(height: 16),
                      Text('⏰ Medication Reminder:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey.shade600)),
                      const SizedBox(height: 4),
                      Text(reminderTime, style: const TextStyle(fontSize: 18)),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                _sectionTitle('Next Medication'),
                _buildCardOrMessage(nextMedication.isEmpty, 'You’re all caught up!',
                    '${nextMedication['name']} at ${formatTime(DateTime.parse(nextMedication['dateTime']))}', theme),
                const SizedBox(height: 24),
                _sectionTitle('Missed Doses'),
                if (missedDoses.isEmpty)
                  const Text('No missed doses!', style: TextStyle(color: Colors.black))
                else
                  ...missedDoses.map((med) => Padding(
                        padding: const EdgeInsets.only(bottom: 8),
                        child: Text(
                          '${med['name']} at ${formatTime(DateTime.parse(med['dateTime']))}',
                          style: const TextStyle(color: Colors.black, fontSize: 16),
                        ),
                      )),
                const SizedBox(height: 30),
                _sectionTitle('📅 Appointment History:'),
                if (appointmentHistory.isEmpty)
                  const Text('No appointments yet.', style: TextStyle(fontSize: 16, color: Colors.black))
                else
                  ...appointmentHistory.reversed.map((appointment) => Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Text(appointment, style: const TextStyle(fontSize: 16, color: Colors.black)),
                      )),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pinkAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.medication), label: 'Medication'),
          BottomNavigationBarItem(icon: Icon(Icons.insert_chart), label: 'Logs'),
          BottomNavigationBarItem(icon: Icon(Icons.calendar_today), label: 'Appointments'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }

  Widget _sectionTitle(String text) {
    return Text(
      text,
      style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            color: Colors.pinkAccent,
          ),
    );
  }

  Widget _buildCardOrMessage(bool isEmpty, String message, String content, ThemeData theme) {
    return isEmpty
        ? Text(message, style: const TextStyle(color: Colors.black))
        : Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(content, style: const TextStyle(fontSize: 16)),
          );
  }
}
