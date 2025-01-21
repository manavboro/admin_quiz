import 'package:admin_quiz/db_constant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EditQuestionPage extends StatefulWidget {
  final String questionId; // The ID of the question to edit
  final String currentQuestion; // The current question text
  final List<dynamic> currentOptions; // Current options
  final String currentCorrectAnswer; // Current correct answer
  final String topicId; // Current correct answer

  const EditQuestionPage({
    super.key,
    required this.questionId,
    required this.currentQuestion,
    required this.currentOptions,
    required this.currentCorrectAnswer,
    required this.topicId,
  });

  @override
  _EditQuestionPageState createState() => _EditQuestionPageState();
}

class _EditQuestionPageState extends State<EditQuestionPage> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [];
  String? _selectedCorrectAnswer;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();

    // Initialize controllers with the current question and options
    _questionController.text = widget.currentQuestion;
    for (var option in widget.currentOptions) {
      _optionControllers.add(TextEditingController(text: option));
    }
    _selectedCorrectAnswer = widget.currentCorrectAnswer;
  }

  // Function to update the question in Firestore
  Future<void> _updateQuestion() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // Create a list of options from the controllers
        List<String> options = _optionControllers
            .map((controller) => controller.text.trim())
            .toList();

        // Update the question in Firestore
        await FirebaseFirestore.instance
            .collection(db_subjects) // Adjust if necessary
            .doc(widget.topicId) // Replace with actual topic ID
            .collection(db_question)
            .doc(widget.questionId) // The ID of the question being edited
            .update({
          'question': _questionController.text.trim(),
          'options': options,
          'answer': _selectedCorrectAnswer,
        });

        // Show a success message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Question updated successfully!")),
        );

        // Go back to the previous screen
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text("Failed to update question. Please try again.")),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    // Dispose controllers when done
    _questionController.dispose();
    for (var controller in _optionControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Edit Question"),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Question field
              TextFormField(
                controller: _questionController,
                decoration: InputDecoration(
                  labelText: "Question",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please enter the question";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),

              // Options fields
              for (int i = 0; i < 4; i++) ...[
                TextFormField(
                  controller: _optionControllers[i],
                  decoration: InputDecoration(
                    labelText: "Option ${i + 1}",
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return "Please enter option ${i + 1}";
                    }
                    return null;
                  },
                ),
                SizedBox(height: 15.0),
              ],

              // Correct answer dropdown
              DropdownButtonFormField<String>(
                value: _selectedCorrectAnswer,
                items: _optionControllers
                    .map((controller) => controller.text.trim())
                    .toList()
                    .map((option) => DropdownMenuItem<String>(
                          value: option,
                          child: Text(option),
                        ))
                    .toList(),
                onChanged: (newValue) {
                  setState(() {
                    _selectedCorrectAnswer = newValue;
                  });
                },
                decoration: InputDecoration(
                  labelText: "Correct Answer",
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Please select the correct answer";
                  }
                  return null;
                },
              ),
              SizedBox(height: 20.0),

              // Save button
              ElevatedButton(
                onPressed: _isLoading ? null : _updateQuestion,
                child: _isLoading
                    ? CircularProgressIndicator(color: Colors.white)
                    : Text("Update Question"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
