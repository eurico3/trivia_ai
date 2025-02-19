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
  List<String> options = [];
  String correctAnswer = "";
  bool isLoading = false;
  String feedbackMessage = "";

  Future<void> fetchTriviaQuestion() async {
    setState(() {
      isLoading = true;
      feedbackMessage = "";
    });

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer sk-xxxxxxxx",
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "messages": [
          {"role": "system", "content": "You are a trivia game assistant."},
          {"role": "user", "content": "Give me a multiple-choice trivia question with four answer choices and indicate the correct answer in JSON format. Example: {\"question\":\"What is the capital of France?\", \"options\":[\"Paris\",\"London\",\"Berlin\",\"Madrid\"], \"correct_answer\":\"Paris\"}"}
        ]
      }),
    );

    print("API Response Code: \${response.statusCode}");
    print("API Response Body: \${response.body}");

    if (response.statusCode == 200) {
      var data = jsonDecode(response.body);
      String aiResponse = data['choices'][0]['message']['content'] ?? "No question received.";

      try {
        var triviaData = jsonDecode(aiResponse);
        setState(() {
          question = triviaData['question'];
          options = List<String>.from(triviaData['options']);
          correctAnswer = triviaData['correct_answer'];
        });
      } catch (e) {
        setState(() {
          question = "Error parsing question data.";
          options = [];
        });
      }
    } else {
      setState(() {
        question = "Error fetching question.";
        options = [];
      });
    }

    setState(() {
      isLoading = false;
    });
  }

  void checkAnswer(String selectedAnswer) {
    setState(() {
      feedbackMessage = selectedAnswer == correctAnswer
          ? "✅ Correct!"
          : "❌ Wrong! The correct answer is: $correctAnswer";
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
              if (options.isNotEmpty)
                ...options.map((option) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 5),
                      child: ElevatedButton(
                        onPressed: () => checkAnswer(option),
                        child: Text(option),
                      ),
                    )),
              if (feedbackMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: Text(
                    feedbackMessage,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                ),
              if (isLoading)
                const CircularProgressIndicator(),
              if (!isLoading)
                Padding(
                  padding: const EdgeInsets.only(top: 20),
                  child: ElevatedButton(
                    onPressed: fetchTriviaQuestion,
                    child: const Text("Get New Trivia Question"),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
