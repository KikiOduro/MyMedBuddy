import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class MedicationScheduleScreen extends StatefulWidget {
  const MedicationScheduleScreen({super.key});

  @override
  State<MedicationScheduleScreen> createState() => _MedicationScheduleScreenState();
}

class _MedicationScheduleScreenState extends State<MedicationScheduleScreen> {
  late Future<List<String>> _medicationsFuture;
  Map<String, TimeOfDay?> selectedTimes = {};

  final Map<String, List<String>> conditionToMedications = {
    'hypertension': ['lisinopril', 'amlodipine', 'losartan'],
    'diabetes': ['metformin', 'insulin', 'glipizide'],
    'asthma': ['albuterol', 'budesonide', 'montelukast'],
    'malaria': ['artemether', 'lumefantrine'],
    'pain': ['ibuprofen', 'acetaminophen', 'naproxen'],
    'arthritis': ['naproxen', 'celecoxib', 'diclofenac'],
    'depression': ['sertraline', 'fluoxetine', 'citalopram'],
  };

  @override
  void initState() {
    super.initState();
    _medicationsFuture = loadConditionAndFetchMedications();
  }

  Future<List<String>> loadConditionAndFetchMedications() async {
    final prefs = await SharedPreferences.getInstance();
    final condition = prefs.getString('condition')?.toLowerCase();

    if (condition == null || !conditionToMedications.containsKey(condition)) {
      return ['No medications found for your condition.'];
    }

    final drugs = conditionToMedications[condition]!;
    List<String> fetchedMeds = [];

    for (String drug in drugs) {
      final url = Uri.parse(
        'https://rxnav.nlm.nih.gov/REST/drugs.json?name=$drug',
      );
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final groups = data['drugGroup']['conceptGroup'];
        if (groups != null) {
          for (var group in groups) {
            if (group['conceptProperties'] != null) {
              for (var item in group['conceptProperties']) {
                fetchedMeds.add(item['name']);
              }
            }
          }
        }
      }
    }

    return fetchedMeds.isNotEmpty
        ? fetchedMeds
        : ['No detailed results found from RxNav API.'];
  }

  Future<void> _selectTime(String medName) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null && mounted) {
      setState(() {
        selectedTimes[medName] = picked;
      });
    }
  }

  Future<void> _saveMedication(String medName) async {
    final prefs = await SharedPreferences.getInstance();
    final List<String> stored = prefs.getStringList('medication_list') ?? [];

    final time = selectedTimes[medName];
    if (time == null) return;

    final now = DateTime.now();
    final medDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    final medMap = {
      'name': medName,
      'dateTime': medDateTime.toIso8601String(),
      'isTaken': false.toString(),
    };

    stored.add(json.encode(medMap));
    await prefs.setStringList('medication_list', stored);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.pinkAccent,
        content: Text('Saved $medName for ${time.format(context)}'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text("Medication Schedule"),
        backgroundColor: Colors.pinkAccent,
        iconTheme: const IconThemeData(color: Colors.white),
        titleTextStyle: const TextStyle(
          color: Colors.white,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: _medicationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: Colors.pinkAccent));
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)));
          } else if (snapshot.hasData) {
            final meds = snapshot.data!;
            return ListView.builder(
              itemCount: meds.length,
              itemBuilder: (context, index) {
                final med = meds[index];
                return Card(
                  color: isDarkMode ? Colors.grey[900] : Colors.grey[200],
                  margin: const EdgeInsets.all(10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: ListTile(
                    leading: const Icon(Icons.medication, color: Colors.pinkAccent),
                    title: Text(med, style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)),
                    subtitle: selectedTimes[med] != null
                        ? Text(
                            'Time: ${selectedTimes[med]!.format(context)}',
                            style: TextStyle(color: isDarkMode ? Colors.white70 : Colors.black87),
                          )
                        : Text('No time set', style: TextStyle(color: isDarkMode ? Colors.white54 : Colors.black54)),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.access_time),
                          color: Colors.pinkAccent,
                          onPressed: () => _selectTime(med),
                        ),
                        IconButton(
                          icon: const Icon(Icons.save),
                          color: selectedTimes[med] != null ? Colors.greenAccent : Colors.grey,
                          onPressed: selectedTimes[med] != null ? () => _saveMedication(med) : null,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          } else {
            return Center(child: Text("No data available.", style: TextStyle(color: isDarkMode ? Colors.white : Colors.black)));
          }
        },
      ),
    );
  }
}
