import 'package:admin_quiz/models/topic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final FirebaseFirestore _firestore = FirebaseFirestore.instance;
const String dbFamilyMember = "topics";

class FirebaseOperationService {
  Future<void> addTopic(Topic topic) async {
    try {
      await _firestore
          .collection(dbFamilyMember)
          .doc(topic.id)
          .set(topic.toMap());

      print('Topic uploaded successfully!');
    } catch (e) {
      print('Error adding topic: $e');
    }
  }

  Future<List<Map<String, dynamic>>> _fetchQuestions(String topicId) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection('topics')
          .doc(topicId)
          .collection('questions')
          .get();

      return snapshot.docs
          .map((doc) => doc.data() as Map<String, dynamic>) // Convert to map
          .toList();
    } catch (e) {
      print("Error fetching questions: $e");
      return [];
    }
  }
}

// Function to delete a subject and its sub-collections (if any)
Future<void> deleteSubject(String subjectId) async {
  try {
    // Reference to the subject document
    DocumentReference subjectRef =
    _firestore.collection(dbFamilyMember).doc(subjectId);

    // Delete all sub-collections (e.g., "questions")
    QuerySnapshot questionsSnapshot =
    await subjectRef.collection('questions').get();

    for (var doc in questionsSnapshot.docs) {
      await subjectRef.collection('questions').doc(doc.id).delete();
    }

    // Finally, delete the subject document
    await subjectRef.delete();

    print("Subject deleted successfully.");
  } catch (e) {
    print("Error deleting subject: $e");
    throw Exception('Failed to delete subject.');
  }
}
