import 'package:admin_quiz/create_topic_screen.dart';
import 'package:admin_quiz/pages/questions_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../app_colors.dart';
import '../db_constant.dart';
import '../providers.dart';

class SubjectListPage extends ConsumerWidget {
  const SubjectListPage({super.key});

  //
  // // Handle refresh when user pulls down
  // Future<void> _onRefresh() async {
  //   await _fetchQuestions(widget.topic.id);
  // }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectsAsync = ref.watch(subjectsProvider); // Watch subjects
    final isDeleting = ref.watch(isDeletingProvider); // Watch deletion state

    return Scaffold(
      appBar: AppBar(
        backgroundColor: primaryColor,
        title: Text(
          'Subjects',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        onPressed: () {
          Navigator.push(
              context, MaterialPageRoute(builder: (x) => CreateTopicScreen()));
        },
        child: Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
      body: Stack(
        children: [
          subjectsAsync.when(
            data: (subjects) {
              if (subjects.isEmpty) {
                return Center(child: Text('No subjects found.'));
              }

              return RefreshIndicator(
                onRefresh: ()async {
                  ref.read(subjectsProvider);
                },
                child: ListView.separated(
                  separatorBuilder: (c, i) {
                    return Divider();
                  },
                  itemCount: subjects.length,
                  itemBuilder: (context, index) {
                    final subject = subjects[index];
                    return ListTile(
                      onTap: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (x) => QuestionsPage(
                                      topic: subject,
                                    )));
                      },
                      onLongPress: () {
                        _showDeleteDialog(context, ref, subject.id);
                      },
                      leading: Text(
                        '${index + 1}',
                        style: TextStyle(fontSize: 20),
                      ),
                      title: Text(subject.topicName),
                    );
                  },
                ),
              );
            },
            loading: () => Center(child: CircularProgressIndicator()),
            error: (err, _) => Center(child: Text('Error: $err')),
          ),
          if (isDeleting)
            Container(
              color: Colors.black54,
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }

  void _showDeleteDialog(
      BuildContext context, WidgetRef ref, String subjectId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Subject'),
          content: Text('Are you sure you want to delete this subject?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
              },
              child: Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context); // Close dialog
                await _deleteSubject(ref, subjectId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
              ),
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _deleteSubject(WidgetRef ref, String subjectId) async {
    final firestore = ref.read(firestoreProvider);
    final isDeleting = ref.read(isDeletingProvider.notifier);

    try {
      isDeleting.state = true;

      final subjectRef = firestore.collection(db_subjects).doc(subjectId);

      // Delete sub-collections (e.g., questions)
      final questionsSnapshot = await subjectRef.collection(db_question).get();
      for (var doc in questionsSnapshot.docs) {
        await subjectRef.collection(db_question).doc(doc.id).delete();
      }

      // Delete the subject document
      await subjectRef.delete();

      // Refresh the subjects list
      ref.refresh(subjectsProvider);

      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text('Subject deleted successfully.')),
      );
    } catch (e) {
      print('Error deleting subject: $e');
      ScaffoldMessenger.of(ref.context).showSnackBar(
        SnackBar(content: Text('Failed to delete subject.')),
      );
    } finally {
      isDeleting.state = false;
    }
  }
}
