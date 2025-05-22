import 'package:alzcare/screen/care_giver_side/patient_details_page.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/quotes.dart';

class CareGiverDashboard extends StatefulWidget {
  const CareGiverDashboard({super.key});

  @override
  _CareGiverDashboardState createState() => _CareGiverDashboardState();
}

class _CareGiverDashboardState extends State<CareGiverDashboard> {
  final TextEditingController _emailController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _currentUserEmail;

  @override
  void initState() {
    super.initState();
    _currentUserEmail = FirebaseAuth.instance.currentUser?.email;
  }

  Future<void> _addPatient() async {
    final enteredEmail = _emailController.text.trim();

    if (enteredEmail.isEmpty) return;

    try {
      // Check if the user exists and is not a caregiver
      final snapshot = await _firestore
          .collection('users')
          .where('email', isEqualTo: enteredEmail)
          .where('isCareGiver', isEqualTo: false)
          .limit(1)
          .get();

      if (snapshot.docs.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Invalid patient email or already a caregiver')),
        );
        return;
      }

      // Check if this patient is already added for this caregiver
      final existing = await _firestore
          .collection('care_givers')
          .where('email', isEqualTo: _currentUserEmail)
          .where('patient_email', isEqualTo: enteredEmail)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Patient is already added')),
        );
        return;
      }

      // Add patient-caregiver relationship
      await _firestore.collection('care_givers').add({
        'email': _currentUserEmail,
        'patient_email': enteredEmail,
        'createdAt': Timestamp.now(),
      });

      _emailController.clear();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Patient added successfully')),
      );
    } catch (e) {
      print('Error adding patient: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacementNamed(context, '/');
  }

  @override
  Widget build(BuildContext context) {
    if (_currentUserEmail == null) {
      return Scaffold(
        body: Center(child: Text('User not logged in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Care Giver Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            SizedBox(height: 2.0),
            Text(
              "Today's Quote: ${quotes()}",
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 25),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(
                labelText: 'Enter patient email',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addPatient,
              child: Text('Add Patient'),
            ),
            SizedBox(height: 20),

            // StreamBuilder for real-time updates of patients list
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: _firestore
                    .collection('care_givers')
                    .where('email', isEqualTo: _currentUserEmail)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return Center(child: Text('Error loading patients'));
                  }
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }

                  final docs = snapshot.data?.docs ?? [];

                  if (docs.isEmpty) {
                    return Center(child: Text('No patients added yet.'));
                  }

                  return ListView.builder(
                    itemCount: docs.length,
                    itemBuilder: (context, index) {
                      final patientEmail = docs[index]['patient_email'] as String;

                      return Card(
                        child: ListTile(
                          leading: Icon(Icons.person),
                          title: Text(patientEmail),
                          subtitle: Text("Tap to add medicine or bio"),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => PatientDetailsPage(
                                  patientEmail: patientEmail,
                                ),
                              ),
                            );
                          },
                          trailing: IconButton(
                            icon: Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              // Confirm before deleting patient relation
                              final confirm = await showDialog<bool>(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: Text('Remove Patient'),
                                  content: Text('Are you sure you want to remove this patient?'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: Text('Cancel'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: Text('Remove'),
                                    ),
                                  ],
                                ),
                              );

                              if (confirm == true) {
                                try {
                                  await _firestore
                                      .collection('care_givers')
                                      .doc(docs[index].id)
                                      .delete();

                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Patient removed')),
                                  );
                                } catch (e) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Error removing patient: $e')),
                                  );
                                }
                              }
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
