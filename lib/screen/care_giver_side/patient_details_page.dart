import 'package:alzcare/data/textfield_design.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class PatientDetailsPage extends StatefulWidget {
  final String patientEmail;
  const PatientDetailsPage({super.key, required this.patientEmail});

  @override
  State<PatientDetailsPage> createState() => _PatientDetailsPageState();
}

class _PatientDetailsPageState extends State<PatientDetailsPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isEditing = true; // Start with editing mode on first load
  bool _isLoading = true;

  // Patient Bio Fields (use TextEditingController to keep data synced with textfields)
  final TextEditingController genderController = TextEditingController();
  final TextEditingController bpController = TextEditingController();
  final TextEditingController bloodGroupController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController lastCheckupController = TextEditingController();
  final TextEditingController mmseController = TextEditingController();
  final TextEditingController mocaController = TextEditingController();
  bool isDiabetic = false;

  // Meds Fields
  String medName = "";
  TimeOfDay? medTime;

  @override
  void initState() {
    super.initState();
    _fetchBio();
    _fetchLocation();
  }

  @override
  void dispose() {
    // Dispose controllers
    genderController.dispose();
    bpController.dispose();
    bloodGroupController.dispose();
    weightController.dispose();
    heightController.dispose();
    lastCheckupController.dispose();
    mmseController.dispose();
    mocaController.dispose();
    super.dispose();
  }

  Future<void> _fetchBio() async {
    final doc = await FirebaseFirestore.instance
        .collection('patient_bio')
        .doc(widget.patientEmail)
        .get();

    if (doc.exists) {
      final data = doc.data()!;
      genderController.text = data['gender'] ?? "";
      bpController.text = data['bp']?.toString() ?? "";
      bloodGroupController.text = data['blood_group'] ?? "";
      weightController.text = data['weight']?.toString() ?? "";
      heightController.text = data['height']?.toString() ?? "";
      lastCheckupController.text = data['last_checkup_condition'] ?? "";
      mmseController.text = data['mmse_score']?.toString() ?? "";
      mocaController.text = data['moca_score']?.toString() ?? "";
      isDiabetic = data['isDiabetic'] ?? false;
      _isEditing = false; // If data exists, show display mode first
    } else {
      // No data found - start with editing mode enabled (default)
      _isEditing = true;
    }

    setState(() => _isLoading = false);
  }

  Future<void> _fetchLocation() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('emergency_contact')
          .where('email', isEqualTo: widget.patientEmail)
          .get();

      if (snapshot.docs.isNotEmpty) {
        final data = snapshot.docs.first.data();
        final location = data['current_location'];

        final lat = location['latitude']?.toString();
        final lng = location['longitude']?.toString();

        if (lat != null && lng != null) {
          setState(() {
            patientCurrentLocation = "$lat, $lng";
          });
        } else {
          setState(() {
            patientCurrentLocation = "Coordinates missing";
          });
        }
      } else {
        setState(() {
          patientCurrentLocation = "No location found for this patient";
        });
      }
    } catch (e) {
      setState(() {
        patientCurrentLocation = "Error fetching location: $e";
      });
    }
  }





  Future<void> _saveBio() async {
    if (_formKey.currentState!.validate()) {
      await FirebaseFirestore.instance
          .collection('patient_bio')
          .doc(widget.patientEmail)
          .set({
        'email': widget.patientEmail,
        'gender': genderController.text.trim(),
        'bp': int.tryParse(bpController.text.trim()),
        'blood_group': bloodGroupController.text.trim(),
        'weight': int.tryParse(weightController.text.trim()),
        'height': int.tryParse(heightController.text.trim()),
        'last_checkup_condition': lastCheckupController.text.trim(),
        'mmse_score': int.tryParse(mmseController.text.trim()),
        'moca_score': int.tryParse(mocaController.text.trim()),
        'isDiabetic': isDiabetic,
      });

      setState(() => _isEditing = false);

      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Bio saved')));
    }
  }

  Future<void> _addMedicine() async {
    if (medName.isNotEmpty && medTime != null) {
      int mTime = int.parse( medTime!.hour.toString() + medTime!.minute.toString() );
      await FirebaseFirestore.instance.collection('meds').add({
        'email': widget.patientEmail,
        'med_name': medName,
        'med_time': mTime,
      });

      setState(() {

        // print("Hour = {medTime!.hour.toString() + medTime!.minute.toString()}");
        medName = "";
        medTime = null;
      });
    }
  }

  Future<void> _deleteMed(String id) async {
    await FirebaseFirestore.instance.collection('meds').doc(id).delete();
  }

  Future<void> _deletePatient() async {
    final firestore = FirebaseFirestore.instance;

    try {
      await firestore.collection('patient_bio').doc(widget.patientEmail).delete();

      final medsSnapshot = await firestore
          .collection('meds')
          .where('email', isEqualTo: widget.patientEmail)
          .get();

      for (var doc in medsSnapshot.docs) {
        await doc.reference.delete();
      }

      final caregiversSnapshot = await firestore
          .collection('care_givers')
          .where('patient_email', isEqualTo: widget.patientEmail)
          .get();

      for (var doc in caregiversSnapshot.docs) {
        await doc.reference.delete();
      }

      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Patient deleted successfully.")),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error deleting patient: $e")),
        );
      }
    }
  }

  String patientCurrentLocation = "0.00, 0.00";

  @override
  Widget build(BuildContext context) {
    if (_isLoading) return const Center(child: CircularProgressIndicator());

    return Scaffold(
      appBar: AppBar(
        // title: const Text('Patient Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.delete),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Confirm Delete'),
                  content:
                  const Text('Are you sure you want to delete this patient?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, false),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      onPressed: () => Navigator.pop(ctx, true),
                      child: const Text('Delete'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await _deletePatient();
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [

            Text('Patient Details',style: TextStyle(fontSize: 24)),
            Divider(),
            Text(patientCurrentLocation),
            SizedBox(height: 10),
            ElevatedButton(
              onPressed: () async {
                final parts = patientCurrentLocation.split(', ');
                if (parts.length == 2) {
                  final lat = parts[0];
                  final lng = parts[1];
                  final url = 'geo:$lat,$lng?q=$lat,$lng(Patient Location)';

                  if (await canLaunch(url)) {
                    await launch(url); // This opens in Google Maps app
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Could not launch Google Maps")),
                    );
                  }
                }
              },
              child: Text("View in Google Map"),
            ),




            _isEditing ? _buildForm() : _buildDisplay(),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: () {
                if (_isEditing) {
                  _saveBio();
                } else {
                  setState(() => _isEditing = true);
                }
              },
              child: Text(_isEditing ? 'Save Bio' : 'Update Details'),
            ),



            SizedBox(height: 50),
            const Text('Medicines List', style: TextStyle(fontSize: 24)),
            Divider(),
            TextField(
              // decoration: const InputDecoration(labelText: 'Medicine Name'),
              decoration: myTextFieldDesign("", "Medicine Name", Icons.medication, Icons.check),
              onChanged: (v) => medName = v,
              controller: TextEditingController(text: medName),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                TextButton(
                  onPressed: () async {
                    final picked = await showTimePicker(
                        context: context, initialTime: TimeOfDay.now());
                    if (picked != null) {
                      setState(() => medTime = picked);
                    }
                  },
                  child:
                  Text(medTime != null ? medTime!.format(context) : 'Set Medicine Timing'),
                ),
              ],
            ),
            const SizedBox(height: 30),
            ElevatedButton(onPressed: _addMedicine, child: const Text('Save Medicine')),
            const SizedBox(height: 10),
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance
                  .collection('meds')
                  .where('email', isEqualTo: widget.patientEmail)
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const CircularProgressIndicator();
                }
                final meds = snapshot.data!.docs;
                if (meds.isEmpty) {
                  return const Text('Medicine List is empty.');
                }
                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: meds.length,
                  itemBuilder: (ctx, i) {
                    final data = meds[i].data()! as Map<String, dynamic>;
                    final id = meds[i].id;
                    final time = Duration(minutes: data['med_time']);
                    // final hour = time.inHours;
                    final minute = time.inMinutes;
                    final timeStr = minute.toString().padLeft(2, '0');

                    return ListTile(
                      title: Text(data['med_name']),
                      subtitle: Text('Time: $timeStr'),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () => _deleteMed(id),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() => Form(
    key: _formKey,
    child: Column(
      children: [
        TextFormField(
          controller: genderController,
          decoration: const InputDecoration(labelText: 'Gender'),
          validator: (v) =>
          v == null || v.isEmpty ? 'Please enter gender' : null,
        ),
        TextFormField(
          controller: bpController,
          decoration: const InputDecoration(labelText: 'BP'),
          keyboardType: TextInputType.number,
          validator: (v) =>
          v == null || v.isEmpty ? 'Please enter BP' : null,
        ),
        TextFormField(
          controller: bloodGroupController,
          decoration: const InputDecoration(labelText: 'Blood Group'),
        ),
        TextFormField(
          controller: weightController,
          decoration: const InputDecoration(labelText: 'Weight'),
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          controller: heightController,
          decoration: const InputDecoration(labelText: 'Height'),
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          controller: lastCheckupController,
          decoration: const InputDecoration(labelText: 'Last Checkup'),
        ),
        TextFormField(
          controller: mmseController,
          decoration: const InputDecoration(labelText: 'MMSE'),
          keyboardType: TextInputType.number,
        ),
        TextFormField(
          controller: mocaController,
          decoration: const InputDecoration(labelText: 'MOCA'),
          keyboardType: TextInputType.number,
        ),
        SwitchListTile(
          value: isDiabetic,
          onChanged: (v) => setState(() => isDiabetic = v),
          title: const Text('Is Diabetic'),
        ),
      ],
    ),
  );

  Widget _buildDisplay() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('Gender: ${genderController.text}'),
      Text('BP: ${bpController.text}'),
      Text('Blood Group: ${bloodGroupController.text}'),
      Text('Weight: ${weightController.text}'),
      Text('Height: ${heightController.text}'),
      Text('Last Checkup: ${lastCheckupController.text}'),
      Text('MMSE: ${mmseController.text}'),
      Text('MOCA: ${mocaController.text}'),
      Text('Diabetic: ${isDiabetic ? "Yes" : "No"}'),
    ],
  );
}
