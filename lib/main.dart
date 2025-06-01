import 'package:alarm/alarm.dart';
import 'package:alzcare/firebase_options.dart';
import 'package:alzcare/screen/care_giver_side/add_pill_page.dart';
import 'package:alzcare/screen/care_giver_side/caregiver_dashboard.dart';
import 'package:alzcare/screen/create_account.dart';
import 'package:alzcare/screen/guest_page.dart';
import 'package:alzcare/screen/login.dart';
import 'package:alzcare/screen/patient_side/board.dart';
import 'package:alzcare/screen/patient_side/face_game.dart';
import 'package:alzcare/screen/patient_side/patient_dashboard.dart';
import 'package:alzcare/screen/patient_side/pill_reminder_screen.dart';
import 'package:alzcare/screen/patient_side/therapist_chatbot.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

Future<void> requestPermissions() async {
  var phoneStatus = await Permission.phone.status;
  if (!phoneStatus.isGranted) {
    phoneStatus = await Permission.phone.request();
  }

  var locationStatus = await Permission.location.status;
  if (!locationStatus.isGranted) {
    locationStatus = await Permission.location.request();
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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      title: "AlzCare",
      debugShowCheckedModeBanner: false,
      onGenerateRoute: (settings) {
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const Login());

          case '/caregiver':
            return MaterialPageRoute(builder: (_) =>  CareGiverDashboard());

          case '/patient':
            return MaterialPageRoute(builder: (_) => const PatientDashboard());

          case '/signup':
            return MaterialPageRoute(builder: (_) => const CreateAccount());

          case '/pill_reminder':
            return MaterialPageRoute(builder: (_) => const PillReminderScreen());

          case '/white_board':
            return MaterialPageRoute(builder: (_) => const WhiteBoard());

          case '/therapist_chatbot':
            return MaterialPageRoute(builder: (_) => const TherapistChatbot());

          case '/face_game':
            return MaterialPageRoute(builder: (_) => FaceGameScreen());

          case '/guest':
            return MaterialPageRoute(builder: (_) => const GuestPage());

          case '/add_pill':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => AddPillPage(
                patientId: args['patientId'],
                patientEmail: args['patientEmail'],
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => const Scaffold(
                body: Center(child: Text("Page not found")),
              ),
            );
        }
      },
    );
  }
}
