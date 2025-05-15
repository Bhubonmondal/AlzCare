import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PatientDashboard extends StatefulWidget {
  const PatientDashboard({super.key});

  @override
  State<PatientDashboard> createState() => _PatientDashboardState();
}

class _PatientDashboardState extends State<PatientDashboard> {
  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Patient Dashboard"),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            // Pill Reminder Feature
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/pill_reminder');
              },
              icon: const Icon(Icons.notifications),
              label: const Text(" Pill Reminder"),
            ),
            const SizedBox(height: 12),

            // Therapist Chatbot Feature
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/therapist_chatbot');
              },
              icon: const Icon(Icons.chat),
              label: const Text(" Therapist Chatbot"),
            ),
            const SizedBox(height: 12),

            // Face Recognition Game Feature
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/face_game');
              },
              icon: const Icon(Icons.face),
              label: const Text(" Face Recognition Game"),
            ),
            const SizedBox(height: 12),

            // Emergency Call Feature
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/emergency_call');
              },
              icon: const Icon(Icons.call),
              label: const Text(" Emergency Call"),
            ),
          ],
        ),
      ),
    );
  }
}
