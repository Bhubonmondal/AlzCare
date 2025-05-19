import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_phone_direct_caller/flutter_phone_direct_caller.dart';
import 'package:permission_handler/permission_handler.dart';

class EmergencyHelper {
  static Future<void> handleEmergencyCall(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    String? emergencyNumber = prefs.getString('emergency_number');

    if (emergencyNumber == null || emergencyNumber.isEmpty) {
      await _promptForNumber(context, prefs);
      emergencyNumber = prefs.getString('emergency_number');
      if (emergencyNumber == null || emergencyNumber.isEmpty) return;
    }

    var status = await Permission.phone.status;
    if (!status.isGranted) {
      status = await Permission.phone.request();
    }

    if (status.isGranted) {
      try {
        bool? callMade = await FlutterPhoneDirectCaller.callNumber(emergencyNumber);
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

  static Future<void> _promptForNumber(BuildContext context, SharedPreferences prefs) async {
    final controller = TextEditingController(text: prefs.getString('emergency_number') ?? '');

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
              }
              Navigator.pop(context);
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }
}
