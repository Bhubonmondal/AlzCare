import 'package:flutter/material.dart';
import 'package:flutter_card_swiper/flutter_card_swiper.dart';

class FaceGameScreen extends StatelessWidget {
  final List<Map<String, String>> people = [
    {
      'name': 'Elon Musk',
      'image':
      'https://upload.wikimedia.org/wikipedia/commons/e/ed/Elon_Musk_Royal_Society.jpg'
    },
    {
      'name': 'Narendra Modi',
      'image':
      'https://upload.wikimedia.org/wikipedia/commons/b/b2/Shri_Narendra_Modi%2C_Prime_Minister_of_India_%283x4_cropped%29.jpg'
    },
    {
      'name': 'Sachin Tendulkar',
      'image':
      'https://upload.wikimedia.org/wikipedia/commons/thumb/3/3e/The_cricket_legend_Sachin_Tendulkar_at_the_Oval_Maidan_in_Mumbai_During_the_Duke_and_Duchess_of_Cambridge_Visit%2826271019082%29.jpg/1200px-The_cricket_legend_Sachin_Tendulkar_at_the_Oval_Maidan_in_Mumbai_During_the_Duke_and_Duchess_of_Cambridge_Visit%2826271019082%29.jpg'
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
                const Text("Do you know this person?", style: TextStyle(fontSize: 18)),
                const SizedBox(height: 10),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        _showAnswer(context, person['name']!, true);
                      },
                      child: const Text("Yes"),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showAnswer(context, person['name']!, false);
                      },
                      child: const Text("No"),
                    ),
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
