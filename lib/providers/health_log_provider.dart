// lib/providers/health_log_provider.dart (converted to Riverpod)
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../models/health_log.dart';

// Manages the list of health logs and syncs with SharedPreferences
class HealthLogNotifier extends StateNotifier<List<HealthLog>> {
  HealthLogNotifier() : super([]) {
    _loadLogsFromPrefs(); // Load logs on init
  }

  // Checks if a log was submitted today
  bool get hasLogToday {
    final today = DateTime.now();
    return state.any((log) =>
        log.date.year == today.year &&
        log.date.month == today.month &&
        log.date.day == today.day);
  }

  // Adds a new log and updates SharedPreferences
  void addLog(HealthLog log) async {
    state = [log, ...state]; // Add to top
    final prefs = await SharedPreferences.getInstance();
    final history = state.map((e) => jsonEncode(e.toJson())).toList();
    await prefs.setStringList('health_logs', history);
  }

  // Loads logs from SharedPreferences
  Future<void> _loadLogsFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    final savedLogs = prefs.getStringList('health_logs') ?? [];

    final loadedLogs = savedLogs.map((logJson) {
      final decoded = jsonDecode(logJson);
      return HealthLog(
        symptoms: List<String>.from(decoded['symptoms']),
        painScale: decoded['painScale'],
        temperature: decoded['temperature'],
        weight: decoded['weight'],
        bloodPressure: decoded['bloodPressure'],
        note: decoded['note'],
        date: DateTime.parse(decoded['date']),
      );
    }).toList();

    state = loadedLogs;
  }
}

// Riverpod provider to access HealthLogNotifier
final healthLogProvider = StateNotifierProvider<HealthLogNotifier, List<HealthLog>>((ref) {
  return HealthLogNotifier();
});
