import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';

class CreateOpportunityScreen extends ConsumerStatefulWidget {
  final String startupId;
  final String startupName;

  const CreateOpportunityScreen({
    super.key,
    required this.startupId,
    required this.startupName,
  });

  @override
  ConsumerState<CreateOpportunityScreen> createState() =>
      _CreateOpportunityScreenState();
}

class _CreateOpportunityScreenState
    extends ConsumerState<CreateOpportunityScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _durationController = TextEditingController();
  final _skillTagController = TextEditingController();

  String _selectedType = 'part-time';
  bool _isPaid = false;
  bool _isLoading = false;

  // Skill tags are built up interactively
  // Student adds one tag at a time and they appear as chips
  final List<String> _skillTags = [];

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _durationController.dispose();
    _skillTagController.dispose();
    super.dispose();
  }

  void _addSkillTag() {
    final tag = _skillTagController.text.trim();
    if (tag.isEmpty) return;
    if (_skillTags.contains(tag)) {
      _skillTagController.clear();
      return;
    }
    setState(() {
      _skillTags.add(tag);
      _skillTagController.clear();
    });
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_skillTags.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add at least one required skill.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    final adminUid = ref.read(currentUserProvider).value?.uid ?? '';

    final success = await ref
        .read(opportunityNotifierProvider.notifier)
        .createOpportunity(
          startupId: widget.startupId,
          startupName: widget.startupName,
          startupAdminUid: adminUid,
          title: _titleController.text.trim(),
          description: _descriptionController.text.trim(),
          requiredSkillTags: _skillTags,
          type: _selectedType,
          duration: _durationController.text.trim(),
          isPaid: _isPaid,
        );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Opportunity posted successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.of(context).pop();
    } else {
      final error = ref.read(opportunityNotifierProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to post opportunity.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(title: const Text('Post Opportunity')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title
              TextFormField(
                controller: _titleController,
                validator: (v) =>
                    Validators.validateRequired(v, 'Title'),
                decoration: const InputDecoration(
                  labelText: 'Opportunity Title',
                  prefixIcon: Icon(Icons.work_outline),
                ),
              ),

              const SizedBox(height: 16),

              // Description
              TextFormField(
                controller: _descriptionController,
                maxLines: 4,
                validator: (v) =>
                    Validators.validateRequired(v, 'Description'),
                decoration: const InputDecoration(
                  labelText: 'Description',
                  prefixIcon: Icon(Icons.description_outlined),
                  alignLabelWithHint: true,
                ),
              ),

              const SizedBox(height: 16),

              // Type selector
              Text(
                'Opportunity Type',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),
              Row(
                children: ['part-time', 'full-time', 'project-based']
                    .map((type) {
                  return Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () =>
                            setState(() => _selectedType = type),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          padding:
                              const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _selectedType == type
                                ? AppTheme.primaryRed
                                : AppTheme.surfaceWhite,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(
                              color: _selectedType == type
                                  ? AppTheme.primaryRed
                                  : const Color(0xFFE5E7EB),
                            ),
                          ),
                          child: Text(
                            type,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: _selectedType == type
                                  ? Colors.white
                                  : AppTheme.textGrey,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),

              // Duration
              TextFormField(
                controller: _durationController,
                validator: (v) =>
                    Validators.validateRequired(v, 'Duration'),
                decoration: const InputDecoration(
                  labelText: 'Duration (e.g. 3 months)',
                  prefixIcon: Icon(Icons.calendar_today_outlined),
                ),
              ),

              const SizedBox(height: 16),

              // Paid toggle
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Is this opportunity paid?',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  Switch(
                    value: _isPaid,
                    activeColor: AppTheme.primaryRed,
                    onChanged: (value) =>
                        setState(() => _isPaid = value),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Skill tags
              Text(
                'Required Skills',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 8),

              // Tag input row
              Row(
                children: [
                  Expanded(
                    child: TextFormField(
                      controller: _skillTagController,
                      decoration: const InputDecoration(
                        hintText: 'e.g. Flutter, Marketing',
                        prefixIcon: Icon(Icons.tag),
                      ),
                      onFieldSubmitted: (_) => _addSkillTag(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: _addSkillTag,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(60, 52),
                    ),
                    child: const Icon(Icons.add),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Tags display
              if (_skillTags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _skillTags.map((tag) {
                    return Chip(
                      label: Text(tag),
                      deleteIcon: const Icon(Icons.close, size: 16),
                      onDeleted: () =>
                          setState(() => _skillTags.remove(tag)),
                      backgroundColor:
                          AppTheme.primaryRed.withOpacity(0.08),
                      labelStyle: const TextStyle(
                        color: AppTheme.primaryRed,
                        fontSize: 12,
                      ),
                      side: BorderSide(
                        color: AppTheme.primaryRed.withOpacity(0.3),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 32),

              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Post Opportunity'),
              ),

              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }
}