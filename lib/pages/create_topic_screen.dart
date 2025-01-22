import 'package:admin_quiz/models/topic.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';

import '../SERVICE/FirebaseOperationService.dart';

class CreateTopicScreen extends StatefulWidget {
  const CreateTopicScreen({super.key});

  @override
  _CreateTopicScreenState createState() => _CreateTopicScreenState();
}

class _CreateTopicScreenState extends State<CreateTopicScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  FirebaseOperationService _controller = new FirebaseOperationService();

  String? _iconPath;
  bool _isUploading = false;

  // /// Pick an icon file
  // Future<void> _pickIcon() async {
  //   final result = await FilePicker.platform.pickFiles(type: FileType.image);
  //   if (result != null && result.files.single.path != null) {
  //     setState(() {
  //       _iconPath = result.files.single.path!;
  //     });
  //   }
  // }

  /// Upload icon to Firebase Storage
  // Future<String> _uploadIcon(String topicName) async {
  //   final fileName = topicName.replaceAll(' ', '_') + '.png';
  //   final storageRef = FirebaseStorage.instance.ref().child('topic_icons/$fileName');
  //   final uploadTask = storageRef.putFile(File(_iconPath!));
  //
  //   final snapshot = await uploadTask;
  //   return await snapshot.ref.getDownloadURL();
  // }

  /// Upload topic to Firestore
  Future<void> _uploadTopic() async {
    if (!_formKey.currentState!.validate()) return;

    // if (_iconPath == null) {
    //   ScaffoldMessenger.of(context).showSnackBar(
    //     SnackBar(content: Text('Please select an icon.')),
    //   );
    //   return;
    // }

    setState(() {
      _isUploading = true;
    });

    try {
      // Check if the topic already exists in the database
      final querySnapshot = await FirebaseFirestore.instance
          .collection('topics')
          .where('topicName', isEqualTo: _nameController.text.trim())
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        // Topic already exists
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
                  'Topic already exists. Please choose a different name.')),
        );
        setState(() {
          _isUploading = false;
        });
        return;
      }

      final docRef =
          FirebaseFirestore.instance.collection(dbFamilyMember).doc();

      final topicId = docRef.id;

      // final iconUrl = await _uploadIcon(_nameController.text);
      final topic =
          Topic(topicName: _nameController.text, icon: '', id: topicId);

      await _controller.addTopic(topic);

      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Topic uploaded successfully!')));

      _nameController.clear();
      setState(() {
        _iconPath = null;
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error uploading topic: $error')));
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Create Topic',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Card(
          elevation: 8,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Title
                  Text(
                    'Add a New Topic',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 20),

                  // Topic Name Field
                  TextFormField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      labelText: 'Topic Name',
                      border: OutlineInputBorder(),
                      prefixIcon:
                          Icon(Icons.text_fields, color: Colors.deepPurple),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter a topic name.';
                      }
                      return null;
                    },
                  ),
                  SizedBox(height: 20),

                  // Icon Picker
                  // ElevatedButton.icon(
                  //   onPressed: _pickIcon,
                  //   icon: Icon(Icons.image),
                  //   label: Text('Select Icon'),
                  //   style: ElevatedButton.styleFrom(
                  //     backgroundColor: Colors.deepPurple,
                  //     padding: EdgeInsets.symmetric(vertical: 12),
                  //     textStyle: TextStyle(fontSize: 16),
                  //   ),
                  // ),
                  if (_iconPath != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Text(
                        'Icon Selected: ${_iconPath!.split('/').last}',
                        style: TextStyle(color: Colors.green),
                      ),
                    ),
                  SizedBox(height: 20),

                  // Upload Button
                  if (_isUploading)
                    Center(child: CircularProgressIndicator())
                  else
                    ElevatedButton(
                      onPressed: _uploadTopic,
                      child: Text(
                        'Upload Topic',
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple,
                        padding: EdgeInsets.symmetric(vertical: 12),
                        textStyle: TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
