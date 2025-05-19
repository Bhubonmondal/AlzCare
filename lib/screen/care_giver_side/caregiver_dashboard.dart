import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class CaregiverDashboard extends StatefulWidget {
  const CaregiverDashboard({super.key});

  @override
  State<CaregiverDashboard> createState() => _CaregiverDashboardState();
}

class _CaregiverDashboardState extends State<CaregiverDashboard> {
  final _emailController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  Future<void> _addPatientDialog() async {
    _emailController.clear();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Add Patient"),
          content: TextField(
            controller: _emailController,
            decoration: const InputDecoration(labelText: "Patient Email"),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Cancel"),
            ),
            ElevatedButton(
              onPressed: () async {
                final email = _emailController.text.trim();
                Navigator.pop(context); // Close dialog
                await _addPatient(email);
              },
              child: const Text("Add"),
            ),
          ],
        );
      },
    );
  }

  Future<void> _addPatient(String email) async {
    try {
      final caregiverId = _auth.currentUser!.uid;

      // 1. Check if user exists and is not a caregiver
      final userQuery = await _firestore
          .collection('users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (userQuery.docs.isEmpty) {
        _showMessage("No user found with this email.");
        return;
      }

      final userDoc = userQuery.docs.first;
      final userId = userDoc.id;
      final isCareGiver = userDoc['isCareGiver'] ?? false;

      if (isCareGiver == true) {
        _showMessage("This user is a caregiver, not a patient.");
        return;
      }

      // 2. Check if already added
      final patientDoc = await _firestore
          .collection('caregivers')
          .doc(caregiverId)
          .collection('patients')
          .doc(userId)
          .get();

      if (patientDoc.exists) {
        _showMessage("This patient is already added.");
        return;
      }

      // 3. Add patient
      await _firestore
          .collection('caregivers')
          .doc(caregiverId)
          .collection('patients')
          .doc(userId)
          .set({
        'email': email,
        'linkedAt': Timestamp.now(),
      });

      _showMessage("Patient added successfully.");
      setState(() {});
    } catch (e) {
      _showMessage("Error: ${e.toString()}");
    }
  }

  void _showMessage(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }

  @override
  Widget build(BuildContext context) {
    final caregiverId = _auth.currentUser!.uid;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Caregiver Dashboard"),
        actions: [
          IconButton(
            onPressed: _logout,
            icon: const Icon(Icons.logout),
            tooltip: "Logout",
          ),
        ],
      ),
      body: Column(
        children: [
          const SizedBox(height: 20),
          ElevatedButton.icon(
            onPressed: _addPatientDialog,
            icon: const Icon(Icons.person_add),
            label: const Text("Add Patient"),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('caregivers')
                  .doc(caregiverId)
                  .collection('patients')
                  .orderBy('linkedAt', descending: true)
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return const Center(child: Text("Something went wrong"));
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final patients = snapshot.data!.docs;

                if (patients.isEmpty) {
                  return const Center(child: Text("No patients added yet."));
                }

                return ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    final email = patient['email'];

                    return ListTile(
                      title: Text(email),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/add_pill',
                          arguments: {
                            'patientId': patient.id,
                            'patientEmail': email,
                          },
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
