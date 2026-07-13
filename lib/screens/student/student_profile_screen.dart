import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';

class StudentProfileScreen extends ConsumerStatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  ConsumerState<StudentProfileScreen> createState() =>
      _StudentProfileScreenState();
}

class _StudentProfileScreenState extends ConsumerState<StudentProfileScreen> {
  final _bioController = TextEditingController();
  final _tagController = TextEditingController();
  final List<String> _skillTags = [];
  bool _loaded = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _bioController.dispose();
    _tagController.dispose();
    super.dispose();
  }

  void _addTag() {
    final tag = _tagController.text.trim();
    if (tag.isEmpty || _skillTags.contains(tag)) return;
    setState(() {
      _skillTags.add(tag);
      _tagController.clear();
    });
  }

  Future<void> _save() async {
    final user = ref.read(currentUserProvider).value;
    if (user == null) return;
    setState(() => _isSaving = true);

    final success = await ref.read(authNotifierProvider.notifier).updateProfile(
          uid: user.uid,
          skillTags: _skillTags,
          bio: _bioController.text.trim(),
        );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      ref.invalidate(currentUserProvider);
      Navigator.of(context).pop();
    } else {
      final error = ref.read(authNotifierProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error ?? 'Failed to save profile.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final userAsync = ref.watch(currentUserProvider);

    // Prefill fields once, the first time the user's data loads
    userAsync.whenData((user) {
      if (!_loaded && user != null) {
        _bioController.text = user.bio;
        _skillTags.addAll(user.skillTags);
        _loaded = true;
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(title: const Text('My Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Bio', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 8),
            TextField(
              controller: _bioController,
              maxLines: 3,
              decoration: const InputDecoration(
                hintText: 'A short line about yourself',
              ),
            ),
            const SizedBox(height: 24),
            Text('Skill Tags', style: Theme.of(context).textTheme.titleSmall),
            const SizedBox(height: 4),
            Text(
              'These power your opportunity filter and matching.',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: AppTheme.textGrey),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _tagController,
                    decoration: const InputDecoration(
                      hintText: 'e.g. Flutter, Marketing, Design',
                    ),
                    onSubmitted: (_) => _addTag(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton(
                  onPressed: _addTag,
                  icon: const Icon(Icons.add_circle,
                      color: AppTheme.primaryRed),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: _skillTags.map((tag) {
                return Chip(
                  label: Text(tag),
                  onDeleted: () => setState(() => _skillTags.remove(tag)),
                  backgroundColor: AppTheme.primaryRed.withOpacity(0.08),
                  labelStyle: const TextStyle(color: AppTheme.primaryRed),
                  deleteIconColor: AppTheme.primaryRed,
                );
              }).toList(),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: _isSaving ? null : _save,
              child: _isSaving
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
