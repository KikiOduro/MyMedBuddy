import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';
import '../providers/theme_provider.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  String name = '-';
  int age = 0;
  String condition = '-';
  String healthTip = '';
  bool isLoadingTip = true;
  bool _notificationsEnabled = false;

  @override
  void initState() {
    super.initState();
    loadUserData();
    fetchHealthTip();
    loadNotificationSetting();
  }

  Future<void> loadUserData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      name = prefs.getString('name') ?? '-';
      age = prefs.getInt('age') ?? 0;
      condition = prefs.getString('condition') ?? '-';
    });
  }

  Future<void> loadNotificationSetting() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _notificationsEnabled = prefs.getBool('notifications_enabled') ?? false;
    });
  }

  Future<void> toggleNotification(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('notifications_enabled', value);
    setState(() => _notificationsEnabled = value);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          value ? 'Notifications Enabled' : 'Notifications Disabled',
        ),
        duration: const Duration(seconds: 1),
      ),
    );
  }

  void fetchHealthTip() {
    List<String> tips = [
      "Drink at least 8 glasses of water a day.",
      "Get 7–9 hours of sleep each night.",
      "Take a short walk every hour during work.",
      "Eat fruits and vegetables daily.",
      "Stretch your body for 5 minutes in the morning.",
      "Limit screen time before bed for better sleep.",
      "Practice deep breathing for 1 minute.",
      "Use sunscreen even on cloudy days.",
      "Wash your hands regularly to prevent illness.",
      "Take time to rest and recharge your mind.",
      "Don’t skip breakfast. Fuel your body early!",
      "Laugh often—it’s good for your health.",
    ];

    final random = Random();
    setState(() {
      healthTip = tips[random.nextInt(tips.length)];
      isLoadingTip = false;
    });
  }

  void showEditDialog() {
    final nameController = TextEditingController(text: name);
    final ageController = TextEditingController(text: age.toString());
    final conditionController = TextEditingController(text: condition);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Edit Profile"),
        content: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Full Name'),
              ),
              TextField(
                controller: ageController,
                decoration: const InputDecoration(labelText: 'Age'),
                keyboardType: TextInputType.number,
              ),
              TextField(
                controller: conditionController,
                decoration: const InputDecoration(labelText: 'Condition'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('name', nameController.text);
              await prefs.setInt('age', int.tryParse(ageController.text) ?? 0);
              await prefs.setString('condition', conditionController.text);
              Navigator.of(context).pop();
              loadUserData();
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final parts = name.trim().split(' ').where((e) => e.isNotEmpty).toList();
    final initials = parts.isNotEmpty
        ? parts.map((e) => e[0]).take(2).join().toUpperCase()
        : "AA";

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        title: const Text("My Profile"),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Card(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  children: [
                    Stack(
                      alignment: Alignment.bottomRight,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundColor: Colors.pink.shade100,
                          child: Text(
                            initials,
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: Colors.pink,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 0,
                          bottom: 0,
                          child: GestureDetector(
                            onTap: showEditDialog,
                            child: const CircleAvatar(
                              radius: 14,
                              backgroundColor: Colors.white,
                              child: Icon(
                                Icons.edit,
                                size: 16,
                                color: Colors.black,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Age",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(age == 0 ? '-' : age.toString()),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Condition",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(condition),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 30),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Health Tip of the Day",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.pink.shade200,
                ),
              ),
            ),
            const SizedBox(height: 8),
            if (isLoadingTip)
              const Center(child: CircularProgressIndicator())
            else
              Text(healthTip, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 30),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Dark Mode", style: TextStyle(fontSize: 16)),
                Consumer<ThemeProvider>(
                  builder: (context, themeProvider, _) {
                    return Switch(
                      value: themeProvider.isDarkMode,
                      activeColor: Colors.pinkAccent,
                      onChanged: (value) {
                        themeProvider.toggleTheme();
                      },
                    );
                  },
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: const [
                    Icon(Icons.notifications_active, color: Colors.pinkAccent),
                    SizedBox(width: 8),
                    Text("Notifications", style: TextStyle(fontSize: 16)),
                  ],
                ),
                Switch(
                  value: _notificationsEnabled,
                  activeColor: Colors.pinkAccent,
                  onChanged: toggleNotification,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
