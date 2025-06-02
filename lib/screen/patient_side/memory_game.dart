import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class MemoryGame extends StatefulWidget {
  const MemoryGame({super.key});

  @override
  State<MemoryGame> createState() => _MemoryGameState();
}

class _MemoryGameState extends State<MemoryGame> {
  final List<String> emojis = ['🍎', '🚗', '🐶', '🎵'];
  late List<String> gameData;
  List<bool> revealed = List.filled(8, false);
  List<int> selectedIndices = [];

  // Timer
  int secondsPassed = 0;
  Timer? gameTimer;

  // Best Time (lowest time to complete)
  int? bestTime; // nullable to show "--" initially

  @override
  void initState() {
    super.initState();
    loadBestTime();
    resetGame();
  }

  void loadBestTime() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      bestTime = prefs.getInt('bestTime');
    });
  }

  void saveBestTime(int newTime) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setInt('bestTime', newTime);
  }

  void resetGame() {
    gameData = [...emojis, ...emojis];
    gameData.shuffle(Random());
    revealed = List.filled(gameData.length, false);
    selectedIndices.clear();
    secondsPassed = 0;
    gameTimer?.cancel();
    gameTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        secondsPassed++;
      });
    });
  }

  void onTileTap(int index) {
    if (revealed[index] || selectedIndices.length == 2) return;

    setState(() {
      revealed[index] = true;
      selectedIndices.add(index);

      if (selectedIndices.length == 2) {
        Future.delayed(Duration(milliseconds: 700), () {
          setState(() {
            int first = selectedIndices[0];
            int second = selectedIndices[1];

            if (gameData[first] != gameData[second]) {
              revealed[first] = false;
              revealed[second] = false;
            }

            selectedIndices.clear();

            if (revealed.every((e) => e)) {
              gameTimer?.cancel();
              if (bestTime == null || secondsPassed < bestTime!) {
                bestTime = secondsPassed;
                saveBestTime(secondsPassed);
              }
              showWinDialog();
            }
          });
        });
      }
    });
  }

  void showWinDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("🎉 You Win!"),
        content: Text("Time taken: ${secondsPassed}s"),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                resetGame();
              });
            },
            child: const Text("Play Again"),
          )
        ],
      ),
    );
  }

  @override
  void dispose() {
    gameTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          Center(
            child: Text(
              "⏱ $secondsPassed s | 🏅 Best: ${bestTime != null ? "${bestTime}s" : "--"}  ",
              style: const TextStyle(fontSize: 14),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                resetGame();
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.builder(
          physics: NeverScrollableScrollPhysics(),
          itemCount: gameData.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return GestureDetector(
              onTap: () => onTileTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                decoration: BoxDecoration(
                  color: revealed[index]
                      ? Colors.blue.shade200
                      : Colors.blue.shade100,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    child: Text(
                      revealed[index] ? gameData[index] : '❓',
                      key: ValueKey(revealed[index]),
                      style: const TextStyle(fontSize: 40),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
