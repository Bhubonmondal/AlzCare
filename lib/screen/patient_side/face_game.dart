import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class FaceGameScreen extends StatelessWidget {
  final List<Map<String, String>> people = [
    {
      'name': 'Daughter',
      'image':
      'https://i.postimg.cc/fWttyFRQ/Whats-App-Image-2025-06-04-at-12-51-47.jpg'
    },
    {
      'name': 'Son',
      'image':
      'https://i.postimg.cc/zGj34Y0K/Whats-App-Image-2025-06-04-at-12-51-48.jpg'
    },
    {
      'name': 'Brother',
      'image':
      'https://i.postimg.cc/4NpYb9c8/Whats-App-Image-2025-06-04-at-12-51-48-1.jpg'
    },
    {
      'name': 'Wife',
      'image':
      'https://i.postimg.cc/RCk3HRW6/Whats-App-Image-2025-06-04-at-12-51-48-3.jpg'
    },
    {
      'name': 'You',
      'image':
      'https://i.postimg.cc/FHm7PHgh/Whats-App-Image-2025-06-04-at-12-51-48-2.jpg'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Face Recognition Game')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: CardSwiper(
          cardsCount: people.length,
          numberOfCardsDisplayed: 1,
          cardBuilder: (context, index, _, __) {
            final person = people[index];
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.network(person['image']!, height: 300),
                ),
                const SizedBox(height: 20),
                Text("This is ${person['name']}", style: const TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // ElevatedButton(
                    //   onPressed: () {
                    //     _showAnswer(context, person['name']!, true);
                    //   },
                    //   child: const Text("Yes"),
                    // ),
                    // ElevatedButton(
                    //   onPressed: () {
                    //     _showAnswer(context, person['name']!, false);
                    //   },
                    //   child: const Text("No"),
                    // ),
                  ],
                )
              ],
            );
          },
        ),
      ),
    );
  }

  void _showAnswer(BuildContext context, String name, bool knows) {
    final result = knows ? "Correct! It's $name." : "Oops! That was $name.";
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Result"),
        content: Text(result),
        actions: [
          TextButton(
            child: const Text("OK"),
            onPressed: () => Navigator.pop(context),
          )
        ],
      ),
    );
  }
}
