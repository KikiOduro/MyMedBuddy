import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/health_log.dart';
import '../providers/health_log_provider.dart';
import '../providers/theme_provider.dart';

class HealthLogsPage extends ConsumerStatefulWidget {
  const HealthLogsPage({super.key});

  @override
  ConsumerState<HealthLogsPage> createState() => _HealthLogsPageState();
}

class _HealthLogsPageState extends ConsumerState<HealthLogsPage> {
  final TextEditingController _logController = TextEditingController();
  final List<String> _symptomsList = ['Headache', 'Fatigue', 'Nausea'];
  final List<String> _selectedSymptoms = [];

  double _painLevel = 5;
  String _temperature = '';
  String _weight = '';
  String _bp = '';

  bool _dailyReminder = false;
  TimeOfDay? _reminderTime;
  String _reminderPurpose = 'Log Symptoms';

  @override
  void initState() {
    super.initState();
    _loadReminderSettings();
  }

  void _saveReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setBool('daily_reminder', _dailyReminder);
    if (_reminderTime != null) {
      prefs.setInt('reminder_hour', _reminderTime!.hour);
      prefs.setInt('reminder_minute', _reminderTime!.minute);
    }
    prefs.setString('reminder_purpose', _reminderPurpose);
  }

  void _loadReminderSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _dailyReminder = prefs.getBool('daily_reminder') ?? false;
      final hour = prefs.getInt('reminder_hour');
      final minute = prefs.getInt('reminder_minute');
      if (hour != null && minute != null) {
        _reminderTime = TimeOfDay(hour: hour, minute: minute);
      }
      _reminderPurpose = prefs.getString('reminder_purpose') ?? 'Log Symptoms';
    });
  }

  void _submitLog() {
    if (_logController.text.isEmpty) return;
    final log = HealthLog(
      symptoms: _selectedSymptoms,
      painScale: _painLevel.toInt(),
      temperature: double.tryParse(_temperature) ?? 0.0,
      weight: double.tryParse(_weight) ?? 0.0,
      bloodPressure: int.tryParse(_bp) ?? 0,
      note: _logController.text,
      date: DateTime.now(),
    );

    ref.read(healthLogProvider.notifier).addLog(log);
    _logController.clear();
    _selectedSymptoms.clear();
  }

  @override
  Widget build(BuildContext context) {
    final logs = ref.watch(healthLogProvider);
    final themeProvider = context.watch<ThemeProvider>();
    final isDarkMode = themeProvider.isDarkMode;

    final bgColor = isDarkMode ? Colors.black : Colors.white;
    final textColor = isDarkMode ? Colors.white : Colors.black;
    final fadedText = isDarkMode ? Colors.white70 : Colors.black54;
    final inputBorder = OutlineInputBorder(
      borderSide: BorderSide(color: isDarkMode ? Colors.white30 : Colors.grey),
    );

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        title: Text('Health Logs', style: TextStyle(color: textColor)),
        iconTheme: IconThemeData(color: textColor),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            TextField(
              controller: _logController,
              style: TextStyle(color: textColor),
              decoration: InputDecoration(
                labelText: 'How are you feeling today?',
                labelStyle: TextStyle(color: fadedText),
                border: inputBorder,
                enabledBorder: inputBorder,
                focusedBorder: const OutlineInputBorder(
                  borderSide: BorderSide(color: Colors.pinkAccent),
                ),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 16),
            Text('Select Symptoms:', style: TextStyle(color: textColor)),
            Wrap(
              spacing: 8,
              children: _symptomsList.map((symptom) {
                return FilterChip(
                  label: Text(symptom, style: TextStyle(color: textColor)),
                  selected: _selectedSymptoms.contains(symptom),
                  onSelected: (selected) {
                    setState(() {
                      selected
                          ? _selectedSymptoms.add(symptom)
                          : _selectedSymptoms.remove(symptom);
                    });
                  },
                  selectedColor: Colors.pinkAccent,
                  backgroundColor:
                      isDarkMode ? Colors.grey[800] : Colors.grey[200],
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            Text('Pain Level: ${_painLevel.toInt()}',
                style: TextStyle(color: textColor)),
            Slider(
              value: _painLevel,
              min: 1,
              max: 10,
              divisions: 9,
              activeColor: Colors.pinkAccent,
              label: _painLevel.toStringAsFixed(0),
              onChanged: (val) => setState(() => _painLevel = val),
            ),
            Row(
              children: [
                Expanded(child: _buildInputField('Temp (°C)', (val) => _temperature = val, textColor, fadedText, inputBorder)),
                const SizedBox(width: 10),
                Expanded(child: _buildInputField('Weight (kg)', (val) => _weight = val, textColor, fadedText, inputBorder)),
                const SizedBox(width: 10),
                Expanded(child: _buildInputField('BP', (val) => _bp = val, textColor, fadedText, inputBorder)),
              ],
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.add),
              label: const Text('Add Log'),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pinkAccent),
              onPressed: _submitLog,
            ),
            const SizedBox(height: 20),
            SwitchListTile(
              title: Text('Daily Reminder', style: TextStyle(color: textColor)),
              value: _dailyReminder,
              activeColor: Colors.pinkAccent,
              onChanged: (val) {
                setState(() => _dailyReminder = val);
                _saveReminderSettings();
              },
            ),
            if (_dailyReminder) ...[
              ListTile(
                title: Text('Reminder Time', style: TextStyle(color: textColor)),
                trailing: Text(
                  _reminderTime != null
                      ? _reminderTime!.format(context)
                      : 'Select',
                  style: TextStyle(color: fadedText),
                ),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: _reminderTime ?? TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => _reminderTime = picked);
                    _saveReminderSettings();
                  }
                },
              ),
              ListTile(
                title:
                    Text('Reminder Purpose', style: TextStyle(color: textColor)),
                trailing: DropdownButton<String>(
                  dropdownColor: bgColor,
                  value: _reminderPurpose,
                  style: TextStyle(color: textColor),
                  onChanged: (val) {
                    if (val != null) {
                      setState(() => _reminderPurpose = val);
                      _saveReminderSettings();
                    }
                  },
                  items: const [
                    DropdownMenuItem(value: 'Log Symptoms', child: Text('Log Symptoms')),
                    DropdownMenuItem(value: 'Take Meds', child: Text('Take Meds')),
                    DropdownMenuItem(value: 'Doctor Follow-Up', child: Text('Doctor Follow-Up')),
                  ],
                ),
              ),
            ],
            const SizedBox(height: 20),
            Text('Past Logs:', style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
            const SizedBox(height: 8),
            if (logs.isEmpty)
              Text('No logs yet.', style: TextStyle(color: fadedText))
            else
              ...logs.map((log) => ListTile(
                    title: Text(log.toString(), style: TextStyle(color: textColor)),
                  )),
          ],
        ),
      ),
    );
  }

  Widget _buildInputField(String label, Function(String) onChanged,
      Color textColor, Color fadedText, InputBorder border) {
    return TextField(
      style: TextStyle(color: textColor),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: fadedText),
        enabledBorder: border,
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pinkAccent),
        ),
      ),
      keyboardType: TextInputType.number,
      onChanged: onChanged,
    );
  }
}
