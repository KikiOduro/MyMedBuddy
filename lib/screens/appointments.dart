import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart'; // For theme toggling

class AppointmentScreen extends StatefulWidget {
  const AppointmentScreen({super.key});

  @override
  State<AppointmentScreen> createState() => _AppointmentScreenState();
}

class _AppointmentScreenState extends State<AppointmentScreen> {
  int selectedDay = DateTime.now().day;
  int selectedMonth = DateTime.now().month;
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedReason = 'Follow Up';
  String appointmentType = 'Online';
  String selectedDoctorType = 'General Doctor';

  List<String> reasons = ['Follow Up', 'Check-up', 'Consultation'];
  List<String> doctorTypes = ['General Doctor', 'Specialist'];

  // Picks time using system picker
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: selectedTime,
    );
    if (picked != null && mounted) {
      setState(() => selectedTime = picked);
    }
  }

  // Saves appointment details in local storage
  Future<void> _saveAppointment() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('appointment_time', selectedTime.format(context));
    await prefs.setString('appointment_reason', selectedReason);
    await prefs.setString('appointment_type', appointmentType);
    await prefs.setString('appointment_doctor_type', selectedDoctorType);

    final summary =
        'You have a $appointmentType appointment on $selectedDay/$selectedMonth at ${selectedTime.format(context)} for $selectedReason with a $selectedDoctorType.';

    final history = prefs.getStringList('appointment_history') ?? [];
    history.add(summary);
    await prefs.setStringList('appointment_history', history);
  }

  // Calls save and shows confirmation dialog
  void _bookAppointment() async {
    await _saveAppointment();

    if (!mounted) return;

    final summary =
        'You have a $appointmentType appointment on $selectedDay/$selectedMonth at ${selectedTime.format(context)} for $selectedReason with a $selectedDoctorType.';

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Appointment Booked'),
        content: Text(summary),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Close dialog
              Navigator.pop(context, true); // Go back to home
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  // Box UI for selecting day/month/time
  Widget _dateBox(String label, String value, VoidCallback onTap, bool isDark) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isDark ? Colors.grey[800] : Colors.white,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: TextStyle(color: isDark ? Colors.white70 : Colors.grey),
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDark ? Colors.white : Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Toggle between Online and In-Person
  Widget _typeOption(String type, bool isDark) {
    final isSelected = appointmentType == type;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => appointmentType = type),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: isSelected
                ? Colors.pinkAccent.withAlpha((255 * 0.1).toInt())
                : (isDark ? Colors.grey[900] : Colors.white),
            border: Border.all(
              color: isSelected ? Colors.pinkAccent : Colors.grey.shade300,
              width: 2,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            type,
            style: TextStyle(
              color: isSelected
                  ? Colors.pinkAccent
                  : (isDark ? Colors.white : Colors.black),
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = themeProvider.isDarkMode;

    final bgColor = isDark ? const Color.fromARGB(255, 9, 8, 8) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black;
    final cardColor = isDark ? Colors.grey[800] : Colors.white;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: const Text('Book Appointment'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(color: textColor),
        titleTextStyle: TextStyle(
          color: textColor,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose Date & Time',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                _dateBox('Day', selectedDay.toString(), () {
                  setState(() => selectedDay = selectedDay % 31 + 1);
                }, isDark),
                const SizedBox(width: 12),
                _dateBox('Month', selectedMonth.toString(), () {
                  setState(() => selectedMonth = selectedMonth % 12 + 1);
                }, isDark),
                const SizedBox(width: 12),
                _dateBox(
                  'Time',
                  selectedTime.format(context),
                  () => _selectTime(context),
                  isDark,
                ),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Reason',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: selectedReason,
                dropdownColor: cardColor,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: isDark ? Colors.white : Colors.black,
                ),
                isExpanded: true,
                underline: const SizedBox(),
                style: TextStyle(color: textColor),
                onChanged: (String? newValue) {
                  setState(() => selectedReason = newValue!);
                },
                items: reasons
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Appointment Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _typeOption('Online', isDark),
                const SizedBox(width: 12),
                _typeOption('In-Person', isDark),
              ],
            ),
            const SizedBox(height: 24),
            Text(
              'Preferred Doctor Type',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(10),
              ),
              child: DropdownButton<String>(
                value: selectedDoctorType,
                dropdownColor: cardColor,
                icon: Icon(
                  Icons.arrow_drop_down,
                  color: isDark ? Colors.white : Colors.black,
                ),
                isExpanded: true,
                underline: const SizedBox(),
                style: TextStyle(color: textColor),
                onChanged: (String? newValue) {
                  setState(() => selectedDoctorType = newValue!);
                },
                items: doctorTypes
                    .map(
                      (value) =>
                          DropdownMenuItem(value: value, child: Text(value)),
                    )
                    .toList(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _bookAppointment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.pinkAccent,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Book Appointment',
                  style: TextStyle(fontSize: 18),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
