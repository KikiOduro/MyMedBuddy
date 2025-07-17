import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _formKey = GlobalKey<FormState>();
  final nameController = TextEditingController();
  final ageController = TextEditingController();
  final conditionController = TextEditingController();
  bool medicationReminder = false;

  Future<void> saveUserData() async {
    if (_formKey.currentState!.validate()) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('name', nameController.text);
      await prefs.setInt('age', int.parse(ageController.text));
      await prefs.setString('condition', conditionController.text);
      await prefs.setBool('medicationReminder', medicationReminder);
      await prefs.setBool('onboarding_done', true);

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Column(
          children: [
            // Top pink header
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Color(0xFFFF4F87),
                  borderRadius: BorderRadius.only(
                    bottomRight: Radius.circular(80),
                  ),
                ),
                child: const Center(
                  child: Text(
                    'MyMedBuddy',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                ),
              ),
            ),
            // Form section
            Expanded(
              flex: 7,
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Form(
                  key: _formKey,
                  child: ListView(
                    children: [
                      const Text(
                        'Welcome!',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Let’s set up your profile to get started',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 20),

                      // Name
                      buildTextField(
                        label: 'Full Name',
                        controller: nameController,
                        validatorMsg: 'Please enter your name',
                      ),

                      const SizedBox(height: 16),

                      // Age
                      buildTextField(
                        label: 'Age',
                        controller: ageController,
                        validatorMsg: 'Please enter your age',
                        isNumber: true,
                      ),

                      const SizedBox(height: 16),

                      // Condition
                      buildTextField(
                        label: 'Condition (e.g. Asthma)',
                        controller: conditionController,
                        validatorMsg: 'Please enter your condition',
                      ),

                      const SizedBox(height: 20),

                      // Medication Reminder Switch
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Enable medication reminders',
                            style: TextStyle(color: Colors.white70),
                          ),
                          Switch(
                            value: medicationReminder,
                            onChanged: (value) {
                              setState(() {
                                medicationReminder = value;
                              });
                            },
                            activeColor: Colors.pinkAccent,
                          ),
                        ],
                      ),

                      const SizedBox(height: 30),

                      // Button
                      Center(
                        child: ElevatedButton(
                          onPressed: saveUserData,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFFF4F87),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 40, vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Continue",
                            style: TextStyle(fontSize: 18, color: Colors.white),
                          ),
                        ),
                      )
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildTextField({
    required String label,
    required TextEditingController controller,
    required String validatorMsg,
    bool isNumber = false,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        enabledBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white30),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: const BorderSide(color: Colors.white),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      validator: (value) => value!.isEmpty ? validatorMsg : null,
    );
  }
}
