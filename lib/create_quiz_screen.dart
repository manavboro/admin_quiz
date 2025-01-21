import 'package:admin_quiz/db_constant.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddQuestionScreen extends StatefulWidget {
  @override
  _AddQuestionScreenState createState() => _AddQuestionScreenState();
}

class _AddQuestionScreenState extends State<AddQuestionScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _questionController = TextEditingController();
  final List<TextEditingController> _optionControllers = [
    TextEditingController(),
    TextEditingController(),
    TextEditingController(),
    TextEditingController()
  ];
  String? _selectedTopicId;
  int? _correctAnswerIndex;
  bool _isSaving = false;

  /// Fetch topics from Firestore
  Future<List<Map<String, dynamic>>> _fetchTopics() async {
    final querySnapshot =
        await FirebaseFirestore.instance.collection(db_subjects).get();
    return querySnapshot.docs
        .map((doc) => {'id': doc.id, 'topicName': doc['topicName']})
        .toList();
  }

  /// Save question to Firestore
  Future<void> _saveQuestion() async {
    if (!_formKey.currentState!.validate() ||
        _selectedTopicId == null ||
        _correctAnswerIndex == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete all fields.')),
      );
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      final options = _optionControllers
          .map((controller) => controller.text.trim())
          .toList();

      final docRef = FirebaseFirestore.instance
          .collection(db_subjects)
          .doc(_selectedTopicId)
          .collection(db_question)
          .doc();
      final questionId = docRef.id;
      await FirebaseFirestore.instance
          .collection(db_subjects)
          .doc(_selectedTopicId)
          .collection(db_question)
          .add({
        'id': questionId,
        'question': _questionController.text.trim(),
        'options': options,
        'answer': options[_correctAnswerIndex!],
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Question added successfully!')),
      );

      // Reset form
      _formKey.currentState!.reset();
      _questionController.clear();
      for (var controller in _optionControllers) {
        controller.clear();
      }
      setState(() {
        _selectedTopicId = null;
        _correctAnswerIndex = null;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error saving question: $error')),
      );
    } finally {
      setState(() {
        _isSaving = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Question'),
        backgroundColor: Colors.deepPurple,
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchTopics(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
                child: Text('Error loading topics: ${snapshot.error}'));
          }

          final topics = snapshot.data!;
          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Topic Dropdown
                    DropdownButtonFormField<String>(
                      value: _selectedTopicId,
                      items: topics
                          .map((topic) => DropdownMenuItem<String>(
                                value: topic['id'] as String,
                                child: Text(topic['topicName'] as String),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedTopicId = value;
                        });
                      },
                      decoration: InputDecoration(
                        labelText: 'Select Topic',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null) {
                          return 'Please select a topic.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Question Input
                    TextFormField(
                      controller: _questionController,
                      decoration: InputDecoration(
                        labelText: 'Question',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter a question.';
                        }
                        return null;
                      },
                    ),
                    SizedBox(height: 20),

                    // Options
                    Text(
                      'Options',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    for (int i = 0; i < _optionControllers.length; i++)
                      Padding(
                        padding: const EdgeInsets.only(top: 10.0),
                        child: TextFormField(
                          controller: _optionControllers[i],
                          decoration: InputDecoration(
                            labelText: 'Option ${i + 1}',
                            border: OutlineInputBorder(),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter option ${i + 1}.';
                            }
                            return null;
                          },
                        ),
                      ),
                    SizedBox(height: 20),

                    // Correct Answer Selector
                    Text(
                      'Select Correct Answer',
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    Column(
                      children: List.generate(
                        _optionControllers.length,
                        (index) => RadioListTile<int>(
                          title: Text('Option ${index + 1}'),
                          value: index,
                          groupValue: _correctAnswerIndex,
                          onChanged: (value) {
                            setState(() {
                              _correctAnswerIndex = value;
                            });
                          },
                        ),
                      ),
                    ),
                    SizedBox(height: 20),

                    // Save Button
                    if (_isSaving)
                      Center(child: CircularProgressIndicator())
                    else
                      ElevatedButton(
                        onPressed: _saveQuestion,
                        child: Text('Save Question'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.deepPurple,
                          padding: EdgeInsets.symmetric(vertical: 12),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
