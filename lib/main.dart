import 'package:alarm/alarm.dart';
import 'package:alzcare/firebase_options.dart';
import 'package:alzcare/screen/care_giver_side/caregiver_dashboard.dart';
import 'package:alzcare/screen/create_account.dart';
import 'package:alzcare/screen/login.dart';
import 'package:alzcare/screen/patient_side/emergency_call_screen.dart';
import 'package:alzcare/screen/patient_side/face_game.dart';
import 'package:alzcare/screen/patient_side/patient_dashboard.dart';
import 'package:alzcare/screen/patient_side/pill_reminder_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  var phoneStatus = await Permission.phone.status;
  if (!phoneStatus.isGranted) {
    phoneStatus = await Permission.phone.request();
  }

  var notificationStatus = await Permission.notification.status;
  if (!notificationStatus.isGranted) {
    notificationStatus = await Permission.notification.request();
  }

  if (phoneStatus.isDenied || notificationStatus.isDenied) {
    debugPrint('Phone or Notification permission denied');
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await Alarm.init();

  await requestPermissions();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "AlzCare",
      debugShowCheckedModeBanner: false,
      routes: {
        '/': (context) => const Login(),
        '/caregiver': (context) => const CaregiverDashboard(),
        '/patient': (context) => const PatientDashboard(),
        '/signup': (context) => const CreateAccount(),
        '/login': (context) => const Login(),
        '/pill_reminder': (context) => const PillReminderScreen(),
        '/emergency_call': (context) => const EmergencyCallScreen(),
        '/face_game': (context) => FaceGameScreen(),
      },
    );
  }
}
