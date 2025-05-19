import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AddPillPage extends StatefulWidget {
  final String patientId;
  final String patientEmail;

  const AddPillPage({
    super.key,
    required this.patientId,
    required this.patientEmail,
  });

  @override
  State<AddPillPage> createState() => _AddPillPageState();
}

class _AddPillPageState extends State<AddPillPage> {
  final _pillController = TextEditingController();
  final _timeController = TextEditingController();

  Future<void> _addPill() async {
    final pillName = _pillController.text.trim();
    final time = _timeController.text.trim();

    if (pillName.isEmpty || time.isEmpty) return;

    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.patientId)
        .collection('pills')
        .add({
      'pillName': pillName,
      'time': time,
      'timestamp': FieldValue.serverTimestamp(),
    });

    _pillController.clear();
    _timeController.clear();
  }

  Future<void> _updatePill(String pillId, String newName, String newTime) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.patientId)
        .collection('pills')
        .doc(pillId)
        .update({
      'pillName': newName,
      'time': newTime,
    });
  }

  Future<void> _deletePill(String pillId) async {
    await FirebaseFirestore.instance
        .collection('users')
        .doc(widget.patientId)
        .collection('pills')
        .doc(pillId)
        .delete();

  }
  Future<void> _pickTime() async {
    final TimeOfDay? pickedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );

    if (pickedTime != null) {
      final formattedTime = pickedTime.format(context); // e.g., 8:30 AM
      setState(() {
        _timeController.text = formattedTime;
      });
    }
  }


  void _showUpdateDialog(String pillId, String currentName, String currentTime) {
    final nameController = TextEditingController(text: currentName);
    final timeController = TextEditingController(text: currentTime);

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Update Pill"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Pill Name')),
            TextField(controller: timeController, decoration: const InputDecoration(labelText: 'Time')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              _updatePill(pillId, nameController.text.trim(), timeController.text.trim());
              Navigator.pop(context);
            },
            child: const Text("Update"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pillsRef = FirebaseFirestore.instance
        .collection('users')
        .doc(widget.patientId)
        .collection('pills')
        .orderBy('timestamp', descending: false);

    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Pills: ${widget.patientEmail}'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          children: [
            // Input Fields
            TextField(
              controller: _pillController,
              decoration: const InputDecoration(labelText: 'Pill Name'),
            ),
            TextField(
              controller: _timeController,
              decoration: const InputDecoration(labelText: 'Time'),
              readOnly: true,
              onTap: _pickTime,
            ),

            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addPill,
              child: const Text("Add Pill"),
            ),
            const Divider(height: 30),
            const Text("Existing Pills", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            // Pill List
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: pillsRef.snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) return const Text("Error loading pills");
                  if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();

                  final pills = snapshot.data!.docs;

                  if (pills.isEmpty) return const Text("No pills added yet");

                  return ListView.builder(
                    itemCount: pills.length,
                    itemBuilder: (context, index) {
                      final pill = pills[index];
                      final pillData = pill.data() as Map<String, dynamic>;

                      return ListTile(
                        title: Text(pillData['pillName']),
                        subtitle: Text("Time: ${pillData['time']}"),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () {
                                _showUpdateDialog(pill.id, pillData['pillName'], pillData['time']);
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _deletePill(pill.id);
                              },
                            ),
                          ],
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
