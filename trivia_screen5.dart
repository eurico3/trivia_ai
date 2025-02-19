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
  List<String> previousQuestions = [];
  List<String> topics = ["Science", "History", "Geography", "Sports", "Technology"];

  Future<void> fetchTriviaQuestion() async {
    setState(() {
      isLoading = true;
      feedbackMessage = "";
      question = "Fetching new question...";
      options = [];
    });

    final response = await http.post(
      Uri.parse("https://api.openai.com/v1/chat/completions"),
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer sk-xxxxxxxxxxxxxxxxxxxxxxx",
      },
      body: jsonEncode({
        "model": "gpt-3.5-turbo",
        "temperature": 1.2,
        "messages": [
          {"role": "system", "content": "You are a trivia game assistant."},
{
  "role": "user",
  "content": "You are a trivia game assistant. Generate a UNIQUE multiple-choice trivia question from these topics: ${topics.join(", ")}. \n\n"
             "Ensure the question is NOT a duplicate of any of these: [${previousQuestions.map((q) => "\"$q\"").join(", ")}].\n\n"
             "Return ONLY JSON in this exact format (without any extra text):\n"
             "{\n"
             "  \"question\": \"What is the capital of France?\",\n"
             "  \"options\": [\"Paris\", \"London\", \"Berlin\", \"Madrid\"],\n"
             "  \"correct_answer\": \"Paris\"\n"
             "}\n\n"
             "DO NOT add explanations, formatting, or any extra text."
}

        ]
      }),
    );

  debugPrint("==== API DEBUG START ====");
  debugPrint("API Response Code: ${response.statusCode}");
  debugPrint("Raw API Response: ${response.body}");
  debugPrint("==== API DEBUG END ====");

    try {
      var responseData = jsonDecode(response.body);

      // Extract the JSON string inside the "content" field
      if (responseData.containsKey("choices") &&
          responseData["choices"].isNotEmpty &&
          responseData["choices"][0].containsKey("message") &&
          responseData["choices"][0]["message"].containsKey("content")) {
    
        // Extract JSON content as a string
        String contentString = responseData["choices"][0]["message"]["content"];

        // Parse the content as JSON
        var triviaData = jsonDecode(contentString);

        if (triviaData is Map &&
            triviaData.containsKey('question') &&
            triviaData.containsKey('options') &&
            triviaData.containsKey('correct_answer')) {
          setState(() {
            question = triviaData['question'];
            options = List<String>.from(triviaData['options']);
            correctAnswer = triviaData['correct_answer'];

            if (!previousQuestions.contains(question)) {
              previousQuestions.add(question);
            }
          });
        } else {
          setState(() {
            question = "Invalid response format from API.";
            options = [];
          });
        }
      } else {
        setState(() {
          question = "No valid JSON found in response.";
          options = [];
        });
      }
    } catch (e) {
      setState(() {
        question = "Error parsing question data.";
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
