import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

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

  Future<void> _handleEmergencyCall() async {
    final prefs = await SharedPreferences.getInstance();
    String? emergencyNumber = prefs.getString('emergency_number');

    if (emergencyNumber == null || emergencyNumber.isEmpty) {
      final controller = TextEditingController();

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Set Emergency Number'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(hintText: 'Enter phone number'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () async {
                final number = controller.text.trim();
                if (number.isNotEmpty) {
                  await prefs.setString('emergency_number', number);
                  emergencyNumber = number;
                }
                Navigator.pop(context);
              },
              child: const Text('Save'),
            ),
          ],
        ),
      );
    }

    if (emergencyNumber != null && emergencyNumber!.isNotEmpty) {
      var status = await Permission.phone.status;
      if (!status.isGranted) {
        status = await Permission.phone.request();
      }

      if (status.isGranted) {
        try {
          bool? callMade = await FlutterPhoneDirectCaller.callNumber(emergencyNumber!);
          if (callMade == false) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Call failed. Please try again.')),
            );
          }
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error while trying to call.')),
          );
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Permission denied to make phone calls.')),
        );
      }
    }
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
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/pill_reminder');
              },
              icon: const Icon(Icons.notifications),
              label: const Text(" Pill Reminder"),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/therapist_chatbot');
              },
              icon: const Icon(Icons.chat),
              label: const Text(" Therapist Chatbot"),
            ),
            const SizedBox(height: 12),

            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/face_game');
              },
              icon: const Icon(Icons.face),
              label: const Text(" Face Recognition Game"),
            ),
          ],
        ),
      ),

      // Red Floating Emergency Button
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.red,
        onPressed: _handleEmergencyCall,
        tooltip: 'Emergency Call',
        child: const Icon(Icons.call),
      ),
    );
  }
}
