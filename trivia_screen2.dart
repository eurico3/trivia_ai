import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TriviaScreen extends StatefulWidget {
  const TriviaScreen({super.key});

  @override
  _TriviaScreenState createState() => _TriviaScreenState();
}

class _TriviaScreenState extends State<TriviaScreen> {
  String question = "Press the button to get a trivia question!";
  bool isLoading = false;

  Future<void> fetchTriviaQuestion() async {
    setState(() {
      isLoading = true;
    });

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer sk-xxxxxxxxxx",
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "You are a trivia game assistant."},
          {"role": "user", "content": "Give me a multiple-choice trivia question with four answer choices."}
        ]
      }),
    );

    print("API Response Code: \${response.statusCode}");
    print("API Response Body: \${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);

      // Extract the message content safely
      String aiResponse = data['choices'][0]['message']['content'] ?? "No question received.";

      setState(() {
        question = aiResponse;
      });
    } else {
      setState(() {
        question = "Error fetching question.";
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trivia AI'),
        backgroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                question,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                      onPressed: fetchTriviaQuestion,
                      child: const Text("Get Trivia Question"),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
