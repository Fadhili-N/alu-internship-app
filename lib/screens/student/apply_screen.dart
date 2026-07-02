import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../core/utils/validators.dart';
import '../../providers/application_provider.dart';

class ApplyScreen extends ConsumerStatefulWidget {
  final String opportunityId;
  final String startupId;
  final String opportunityTitle;
  final String studentUid;
  final String studentName;

  const ApplyScreen({
    super.key,
    required this.opportunityId,
    required this.startupId,
    required this.opportunityTitle,
    required this.studentUid,
    required this.studentName,
  });

  @override
  ConsumerState<ApplyScreen> createState() => _ApplyScreenState();
}

class _ApplyScreenState extends ConsumerState<ApplyScreen> {
  final _formKey = GlobalKey<FormState>();
  final _coverNoteController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _coverNoteController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final success =
        await ref.read(applicationNotifierProvider.notifier).submitApplication(
              opportunityId: widget.opportunityId,
              startupId: widget.startupId,
              studentUid: widget.studentUid,
              studentName: widget.studentName,
              coverNote: _coverNoteController.text.trim(),
            );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (success) {
      // Show success then go back to home
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Application submitted successfully!'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      Navigator.of(context).pushReplacementNamed('/student-home');
    } else {
      final error = ref.read(applicationNotifierProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error ?? 'Failed to submit application.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(title: const Text('Apply')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Opportunity title card
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.backgroundDark,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Applying for',
                      style: TextStyle(
                        color: Colors.white54,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      widget.opportunityTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Text(
                'Cover Note',
                style: Theme.of(context).textTheme.titleSmall,
              ),
              const SizedBox(height: 4),
              Text(
                'Tell the startup why you are a great fit for this opportunity.',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTheme.textGrey,
                    ),
              ),

              const SizedBox(height: 12),

              TextFormField(
                controller: _coverNoteController,
                maxLines: 8,
                maxLength: 500,
                validator: (v) =>
                    Validators.validateRequired(v, 'Cover note'),
                decoration: const InputDecoration(
                  hintText:
                      'Introduce yourself, highlight relevant skills and experience, and explain why you are interested in this role...',
                  alignLabelWithHint: true,
                ),
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
                    : const Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}