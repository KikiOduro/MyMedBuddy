// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';

// class NotificationProvider with ChangeNotifier {
//   bool _notificationsEnabled = true;

//   bool get notificationsEnabled => _notificationsEnabled;

//   NotificationProvider() {
//     _loadFromPrefs();
//   }

//   void _loadFromPrefs() async {
//     final prefs = await SharedPreferences.getInstance();
//     _notificationsEnabled = prefs.getBool('notifications_enabled') ?? true;
//     notifyListeners();
//   }

//   void toggleNotifications(bool value) async {
//     _notificationsEnabled = value;
//     final prefs = await SharedPreferences.getInstance();
//     await prefs.setBool('notifications_enabled', value);
//     notifyListeners();
//   }
// }
