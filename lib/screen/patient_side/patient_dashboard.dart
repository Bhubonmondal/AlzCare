import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
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
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    String? emergencyNumber = prefs.getString('emergency_number');

    if (emergencyNumber == null || emergencyNumber.isEmpty) {
      final controller = TextEditingController();

      await showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Set Emergency Number'),
          content: TextField(
            autofocus: true,
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

                  Position position = await Geolocator.getCurrentPosition(
                    locationSettings: AndroidSettings(
                      accuracy: LocationAccuracy.best,
                      distanceFilter: 10,
                    )
                  );

                  await _firestore.collection('emergency_contact').doc(user?.uid).set({
                    'email': user?.email ?? 'Unknown',
                    'emergency_contact': number,
                    'current_location': {
                      'latitude': position.latitude,
                      'longitude': position.longitude,
                    },
                    'timestamp': FieldValue.serverTimestamp(),
                  });
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
            tooltip: "log out",
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
      floatingActionButton: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.red,
          shape: const CircleBorder(),
          padding: const EdgeInsets.all(16.0),
        ),
        onPressed: _handleEmergencyCall,
        onLongPress: _editEmergencyNumber,
        child: const Icon(Icons.call, color: Colors.white, size: 32.0),
      ),
    );
  }

  void _editEmergencyNumber() async {
    final prefs = await SharedPreferences.getInstance();
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;
    final user = FirebaseAuth.instance.currentUser;
    String? emergencyNumber = prefs.getString('emergency_number');

    final controller = TextEditingController();
    controller.text = emergencyNumber ?? '';

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Emergency Number'),
        content: TextField(
          autofocus: true,
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

                Position position = await Geolocator.getCurrentPosition(
                  locationSettings: AndroidSettings(
                    accuracy: LocationAccuracy.best,
                    distanceFilter: 10,
                  )
                );

                await _firestore.collection('emergency_contact').doc(user?.uid).set({
                  'email': user?.email ?? 'Unknown',
                  'emergency_contact': number,
                  'current_location': {
                    'latitude': position.latitude,
                    'longitude': position.longitude,
                  },
                  'timestamp': FieldValue.serverTimestamp(),
                });
              }
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Emergency number updated.')),
              );
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

}
