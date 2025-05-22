import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PatientDetailScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const PatientDetailScreen({required this.patient});

  @override
  Widget build(BuildContext context) {
    final bio = patient['bio'] ?? {};

    return Scaffold(
      appBar: AppBar(title: Text('Patient Details')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Email: ${patient['email']}', style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text('Name: ${bio['name'] ?? 'N/A'}'),
            Text('Age: ${bio['age'] ?? 'N/A'}'),
            Text('Gender: ${bio['gender'] ?? 'N/A'}'),
            Text('Address: ${bio['address'] ?? 'N/A'}'),
            // Add more fields as available
          ],
        ),
      ),
    );
  }
}
