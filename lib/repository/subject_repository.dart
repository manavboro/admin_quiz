import 'package:admin_quiz/UTILS/db_constant.dart';
import 'package:admin_quiz/models/topic.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SubjectRepository {
  final FirebaseFirestore _firestore;

  SubjectRepository(this._firestore);

  Future<List<Topic>> fetchSubjects() async {
    try {
      final snapshot = await _firestore.collection(db_subjects).get();
      return snapshot.docs
          .map((doc) => Topic.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Failed to fetch subjects: $e');
    }
  }


  Future<void> deleteSubject(String subjectId) async {
    try {
      await _firestore.collection(db_subjects).doc(subjectId).delete();
    } catch (e) {
      throw Exception('Failed to delete subject: $e');
    }
  }
}
