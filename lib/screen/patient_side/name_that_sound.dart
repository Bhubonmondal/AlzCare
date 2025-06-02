import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';

class NameThatSoundGame extends StatefulWidget {
  const NameThatSoundGame({super.key});

  @override
  State<NameThatSoundGame> createState() => _NameThatSoundGameState();
}

class _NameThatSoundGameState extends State<NameThatSoundGame> {
  final player = AudioPlayer();
  int currentQuestion = 0;
  bool? isCorrect;

  final List<Map<String, dynamic>> questions = [
    {
      "sound": "sounds/bird.mp3",
      "answer": "Bird 🐦",
      "options": ["Bird 🐦", "Car 🚗", "Bell 🔔"],
    },
    {
      "sound": "sounds/car.mp3",
      "answer": "Car 🚗",
      "options": ["Fan 🪭", "Car 🚗", "Cat 🐱"],
    },
  ];

  void playSound(String path) async {
    await player.play(AssetSource(path));
  }

  void checkAnswer(String selected) {
    String correct = questions[currentQuestion]["answer"];
    setState(() {
      isCorrect = selected == correct;
    });

    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        currentQuestion = (currentQuestion + 1) % questions.length;
        isCorrect = null;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final q = questions[currentQuestion];

    return Scaffold(
      appBar: AppBar(title: const Text("Name That Sound")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(

          children: [
            Text("Question ${currentQuestion + 1}/${questions.length}", style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            Text("What is the sound of ", style: const TextStyle(fontSize: 24)),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [

                ElevatedButton.icon(
                  onPressed: () => playSound(q["sound"]),
                  icon: Icon(Icons.volume_up),
                  label: Text("Play Sound"),
                ),
              ],
            ),
            const SizedBox(height: 100),
            Text("Choose the correct Answer:", style: const TextStyle(fontSize: 24)),
            const SizedBox(height: 20),
            ...q["options"].map<Widget>((opt) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: ElevatedButton(
                  onPressed: () => checkAnswer(opt),
                  child: Text(opt),
                ),
              );
            }),
            const SizedBox(height: 20),
            if (isCorrect != null)
              Text(
                isCorrect! ? "✅ Correct!" : "❌ Try again!",
                style: TextStyle(fontSize: 24, color: isCorrect! ? Colors.green : Colors.red),
              ),
          ],
        ),
      ),
    );
  }
}
