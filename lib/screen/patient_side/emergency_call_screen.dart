import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyCallScreen extends StatefulWidget {
  const EmergencyCallScreen({super.key});

  @override
  State<EmergencyCallScreen> createState() => _EmergencyCallScreenState();
}

class _EmergencyCallScreenState extends State<EmergencyCallScreen> {
  String? emergencyNumber;

  @override
  void initState() {
    super.initState();
    _loadNumber();
  }

  Future<void> _loadNumber() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      emergencyNumber = prefs.getString('emergency_number');
    });
  }

  Future<void> _saveNumber(String number) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('emergency_number', number);
    setState(() {
      emergencyNumber = number;
    });
  }

  Future<void> _promptForNumber({bool isUpdate = false}) async {
    final controller = TextEditingController(text: isUpdate ? emergencyNumber : '');

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(isUpdate ? 'Update Emergency Number' : 'Set Emergency Number'),
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
            onPressed: () {
              final number = controller.text.trim();
              if (number.isNotEmpty) {
                _saveNumber(number);
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  Future<void> _callEmergencyNumber() async {
    if (emergencyNumber == null || emergencyNumber!.isEmpty) {
      _promptForNumber();
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency Call'),
      ),
      body: Center(
        child: GestureDetector(
          onTap: _callEmergencyNumber,
          onLongPress: () => _promptForNumber(isUpdate: true),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
            decoration: BoxDecoration(
              color: Colors.redAccent,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Text(
              'Emergency Call',
              style: TextStyle(
                fontSize: 20,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
