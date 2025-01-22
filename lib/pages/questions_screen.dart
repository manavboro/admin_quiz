import 'dart:convert';
import 'dart:io';

import 'package:admin_quiz/UTILS/app_colors.dart';
import 'package:admin_quiz/UTILS/db_constant.dart';
import 'package:admin_quiz/pages/edit_question_page.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import 'create_quiz_screen.dart';
import '../models/topic.dart';

class QuestionsPage extends StatefulWidget {
  final Topic topic; // Topic ID passed to this page

  const QuestionsPage({super.key, required this.topic});

  @override
  _QuestionsPageState createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late String jsonString;

  // Fetch questions for the specific topic
  Future<List<Map<String, dynamic>>> _fetchQuestions(String topicId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(db_subjects)
          .doc(topicId)
          .collection(db_question)
          .get();

      var data = snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>) // Convert to map
          .toList();

      // Convert the list of questions to JSON
      jsonString = jsonEncode(data);
      print(jsonString);

      return data;
    } catch (e) {
      print("Error fetching questions: $e");
      return [];
    }
  }

  // Handle refresh when user pulls down
  Future<void> _onRefresh() async {
    setState(() {


    });
  }


  Future<void> deleteQuestion(String topicId, String questionId) async {
    try {
      // Reference the question document in Firestore
      await FirebaseFirestore.instance
          .collection(db_subjects) // Replace with your collection
          .doc(topicId) // Topic ID
          .collection(db_question) // Sub-collection
          .doc(questionId) // Question ID
          .delete();

      setState(() {

      });
      print('Question deleted successfully');
    } catch (e) {
      print('Failed to delete question: $e');
      throw e; // Optionally rethrow to handle in the UI
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddQuestionScreen()),
          );
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      appBar: AppBar(
        backgroundColor: primaryColor,
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Questions',
          style: TextStyle(color: Colors.white),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              saveAndShareJson(jsonString);
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: Text('Export', style: TextStyle(color: Colors.white)),
            ),
          )
        ],
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: _fetchQuestions(widget.topic.id),
        // Fetch questions for the selected topic
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('No questions found.'));
          }

          List<Map<String, dynamic>> questions = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _onRefresh,
            child: ListView.separated(
              separatorBuilder: (ctx, index) {
                return Divider();
              },
              itemCount: questions.length,
              itemBuilder: (context, index) {
                var question = questions[index];
                return ListTile(

                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => EditQuestionPage(
                                topicId: widget.topic.id,
                                questionId: question['id'],
                                currentQuestion: question['question'],
                                currentOptions: question['options'],
                                currentCorrectAnswer: question['answer'],
                              )),
                    );
                  },
                  onLongPress: ()async {
                    final confirm = await showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: Text('Delete Question'),
                        content: Text('Are you sure you want to delete this question?'),
                        actions: [
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () => Navigator.of(context).pop(false),
                          ),
                          TextButton(
                            child: Text('Delete'),
                            onPressed: () => Navigator.of(context).pop(true),
                          ),
                        ],
                      ),
                    );

                    if (confirm == true) {
                      deleteQuestion(widget.topic.id,question['id'],);
                    }
                  },
                  leading: Text(
                    '${index + 1}',
                    style: TextStyle(fontSize: 20),
                  ),
                  title: Text(question['question']),
                  subtitle: Text('Answer: ${question['answer']}'),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> saveAndShareJson(String jsonString) async {
    try {
      // Get the temporary directory
      final directory = await getTemporaryDirectory();
      final filePath =
          '${directory.path}/${widget.topic.topicName.toLowerCase()}.json';

      // Save the JSON string to a file
      final file = File(filePath);
      await file.writeAsString(jsonString);

      // Share the file
      Share.shareXFiles([XFile(filePath)], text: 'Exported Questions');
    } catch (e) {
      print('Error saving and sharing JSON file: $e');
    }
  }

  void export() {
    Share.share(
      jsonString,
      subject: 'Exported Questions',
    );
  }
}
