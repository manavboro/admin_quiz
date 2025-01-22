import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../UTILS/app_colors.dart';
import 'create_topic_screen.dart';
import '../manager/navigation_manager.dart';
import '../providers/subject_list_provider.dart';
import '../pages/questions_screen.dart';

class SubjectListPage extends ConsumerWidget {
  const SubjectListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final subjectListAsync = ref.watch(subjectListProvider);

    return Scaffold(
      appBar: _buildAppBar(),
      floatingActionButton: _buildFloatingActionButton(context),
      body: subjectListAsync.when(
        data: (subjects) => subjects.isEmpty
            ? const Center(child: Text('No subjects found.'))
            : _buildSubjectList(context, ref, subjects),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: primaryColor,
      title: const Text('Subjects', style: TextStyle(color: Colors.white)),
      centerTitle: true,
    );
  }

  FloatingActionButton _buildFloatingActionButton(BuildContext context) {
    return FloatingActionButton(
      backgroundColor: primaryColor,
      onPressed: () {
        NavigationManager.instance.navigateTo(context, const CreateTopicScreen());
      },
      child: const Icon(Icons.add, color: Colors.white),
    );
  }

  Widget _buildSubjectList(
      BuildContext context, WidgetRef ref, List subjects) {
    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(subjectListProvider);
      },
      child: ListView.separated(
        separatorBuilder: (_, __) => const Divider(),
        itemCount: subjects.length,
        itemBuilder: (context, index) {
          final subject = subjects[index];
          return ListTile(
            onTap: () => NavigationManager.instance.navigateTo(
              context,
              QuestionsPage(topic: subject),
            ),
            onLongPress: () => _showDeleteDialog(context, ref, subject.id),
            leading: Text('${index + 1}', style: const TextStyle(fontSize: 20)),
            title: Text(subject.topicName),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String subjectId) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Subject'),
        content: const Text('Are you sure you want to delete this subject?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => _deleteSubject(context, ref, subjectId),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteSubject(
      BuildContext context, WidgetRef ref, String subjectId) async {
    Navigator.pop(context); // Close dialog
    try {
      await ref.read(subjectListProvider.notifier).deleteSubject(subjectId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Subject deleted')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to delete subject: $e')),
      );
    }
  }
}
