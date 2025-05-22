import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:alarm/alarm.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/remindermodel.dart';

class PillReminderScreen extends StatefulWidget {
  const PillReminderScreen({super.key});

  @override
  State<PillReminderScreen> createState() => _PillReminderScreenState();
}

class _PillReminderScreenState extends State<PillReminderScreen> {
  List<ReminderModel> _userReminders = [];
  List<ReminderModel> _caregiverReminders = [];
  late SharedPreferences _prefs;
  final user = FirebaseAuth.instance.currentUser;

  @override
  void initState() {
    super.initState();
    Alarm.init();
    _loadUserReminders();
    _listenToCaregiverReminders();
  }

  Future<void> _loadUserReminders() async {
    _prefs = await SharedPreferences.getInstance();
    final saved = _prefs.getStringList('reminders') ?? [];
    setState(() {
      _userReminders =
          saved.map((e) => ReminderModel.fromMap(jsonDecode(e))).toList();
    });
  }

  void _listenToCaregiverReminders() {
    if (user == null) return;

    FirebaseFirestore.instance
        .collection('meds')
        .where('email', isEqualTo: user!.email)
        .snapshots()
        .listen((snapshot) async {
      final List<ReminderModel> caregiverMeds = [];

      for (var doc in snapshot.docs) {
        final data = doc.data();
        final medTime = data['med_time'];
        final name = data['med_name'];

        if (medTime == null || name == null) continue;

        final medTimeStr = medTime.toString().padLeft(4, '0');
        final hour = int.tryParse(medTimeStr.substring(0, 2)) ?? 0;
        final minute = int.tryParse(medTimeStr.substring(2, 4)) ?? 0;
        final id = doc.id.hashCode;

        final reminder = ReminderModel(
          id: id,
          name: name,
          hour: hour,
          minute: minute,
        );

        caregiverMeds.add(reminder);

        final now = DateTime.now();
        DateTime alarmTime = DateTime(
          now.year,
          now.month,
          now.day,
          hour,
          minute,
        );

        if (alarmTime.isBefore(now)) {
          alarmTime = alarmTime.add(const Duration(days: 1));
        }

        final isSet = await Alarm.getAlarm(id) != null;
        if (!isSet) {
          await Alarm.set(
            alarmSettings: AlarmSettings(
              id: id,
              dateTime: alarmTime,
              assetAudioPath: 'assets/alarm.mp3',
              loopAudio: true,
              vibrate: true,
              volume: 1.0,
              notificationSettings: NotificationSettings(
                stopButton: "Stop",
                title: 'Pill Reminder',
                body: name,
              ),
            ),
          );
        }
      }

      setState(() {
        _caregiverReminders = caregiverMeds;
      });
    });
  }

  Future<void> _saveReminder(ReminderModel reminder) async {
    _userReminders.add(reminder);
    final jsonList = _userReminders.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList('reminders', jsonList);

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('reminders')
          .doc(reminder.id.toString())
          .set(reminder.toMap());
    }
  }

  Future<void> _deleteReminder(int index) async {
    final reminder = _userReminders[index];
    Alarm.stop(reminder.id);
    _userReminders.removeAt(index);
    final jsonList = _userReminders.map((e) => jsonEncode(e.toMap())).toList();
    await _prefs.setStringList('reminders', jsonList);

    if (user != null) {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user!.uid)
          .collection('reminders')
          .doc(reminder.id.toString())
          .delete();
    }
    setState(() {});
  }

  Future<void> _addReminder() async {
    final medicineController = TextEditingController();
    TimeOfDay? selectedTime;

    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Add Medicine Reminder"),
        content: StatefulBuilder(
          builder: (context, setState) => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: medicineController,
                decoration: const InputDecoration(labelText: "Medicine Name"),
              ),
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(selectedTime == null
                    ? "Pick Time"
                    : selectedTime!.format(context)),
                onTap: () async {
                  final picked = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (picked != null) {
                    setState(() => selectedTime = picked);
                  }
                },
              )
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancel"),
          ),
          ElevatedButton(
            onPressed: () async {
              if (medicineController.text.isEmpty || selectedTime == null) return;

              final now = DateTime.now();
              DateTime alarmTime = DateTime(
                now.year,
                now.month,
                now.day,
                selectedTime!.hour,
                selectedTime!.minute,
              );

              if (alarmTime.isBefore(now)) {
                alarmTime = alarmTime.add(const Duration(days: 1));
              }

              int id = Random().nextInt(2147483647);
              final reminder = ReminderModel(
                id: id,
                name: medicineController.text,
                hour: selectedTime!.hour,
                minute: selectedTime!.minute,
              );

              await Alarm.set(
                alarmSettings: AlarmSettings(
                  id: id,
                  dateTime: alarmTime,
                  assetAudioPath: 'assets/alarm.mp3',
                  loopAudio: true,
                  vibrate: true,
                  volume: 1.0,
                  notificationSettings: NotificationSettings(
                    stopButton: "Stop",
                    title: 'Pill Reminder',
                    body: medicineController.text,
                  ),
                ),
              );

              await _saveReminder(reminder);
              Navigator.pop(context);
              setState(() {});
            },
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allReminders = [..._caregiverReminders, ..._userReminders];

    return Scaffold(
      appBar: AppBar(title: const Text("Pill Reminder")),
      body: allReminders.isEmpty
          ? const Center(child: Text("No reminders yet"))
          : ListView.builder(
        itemCount: allReminders.length,
        itemBuilder: (context, index) {
          final r = allReminders[index];
          final isUserReminder = _userReminders.any((e) => e.id == r.id);

          return ListTile(
            leading: const Icon(Icons.medication),
            title: Text(r.name),
            subtitle: Text(
              "${r.hour.toString().padLeft(2, '0')}:${r.minute.toString().padLeft(2, '0')}" +
                  (isUserReminder ? " (You)" : " (Caregiver)"),
            ),
            trailing: isUserReminder
                ? IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () => _deleteReminder(
                  _userReminders.indexWhere((e) => e.id == r.id)),
            )
                : null,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addReminder,
        child: const Icon(Icons.add),
      ),
    );
  }
}
