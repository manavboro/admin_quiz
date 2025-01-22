import 'package:admin_quiz/models/topic.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../repository/subject_repository.dart';

// Repository Provider
final subjectRepositoryProvider = Provider<SubjectRepository>((ref) {
  return SubjectRepository(FirebaseFirestore.instance);
});

// Subject List StateNotifier
final subjectListProvider = StateNotifierProvider<SubjectListNotifier, AsyncValue<List<Topic>>>((ref) {
  final repository = ref.read(subjectRepositoryProvider);
  return SubjectListNotifier(repository);
});

// SubjectListNotifier Class
class SubjectListNotifier extends StateNotifier<AsyncValue<List<Topic>>> {
  final SubjectRepository _repository;

  SubjectListNotifier(this._repository) : super(const AsyncLoading()) {
    _fetchSubjects(); // Fetch subjects on initialization
  }

  Future<void> _fetchSubjects() async {
    try {
      final subjects = await _repository.fetchSubjects();
      state = AsyncValue.data(subjects);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> deleteSubject(String subjectId) async {
    try {
      if (state is AsyncData<List<Topic>>) {
        // Optimistically update UI
        final currentSubjects = (state as AsyncData<List<Topic>>).value;
        state = AsyncValue.data(
          currentSubjects.where((subject) => subject.id != subjectId).toList(),
        );

        // Delete from Firestore
        await _repository.deleteSubject(subjectId);
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
      throw Exception('Failed to delete subject: $e');
    }
  }

  Future<void> refreshSubjects() async {
    state = const AsyncLoading();
    await _fetchSubjects();
  }
}
