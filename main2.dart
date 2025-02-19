import 'package:flutter/material.dart';
import 'trivia_screen.dart';

void main() {
  runApp(const TriviaApp());
}

class TriviaApp extends StatelessWidget {
  const TriviaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Trivia AI',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const TriviaHomePage(),
    );
  }
}

class TriviaHomePage extends StatelessWidget {
  const TriviaHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivia AI'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: const Center(
        child: Text(
          'Welcome to Trivia AI!\nPress Start to Play!',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Next step: Navigate to Trivia Questions Screen
          Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const TriviaScreen()),
    );
        },
        child: const Icon(Icons.play_arrow),
      ),
    );
  }
}
