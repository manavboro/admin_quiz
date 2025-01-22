import 'package:admin_quiz/SERVICE/FirebaseOperationService.dart';
import 'package:admin_quiz/models/topic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final firestoreProvider = Provider<FirebaseFirestore>((ref) {
  return FirebaseFirestore.instance;
});

// Subjects Provider
final subjectsProvider = FutureProvider<List<Topic>>((ref) async {
  final firestore = ref.read(firestoreProvider);
  final snapshot = await firestore.collection(dbFamilyMember).get();
  return snapshot.docs.map((doc) {
    return Topic.fromMap(doc.data());
  }).toList();
});

// Deletion State Provider
final isDeletingProvider = StateProvider<bool>((ref) => false);
