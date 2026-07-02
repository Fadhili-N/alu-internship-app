import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/application_model.dart';
import '../../providers/application_provider.dart';

class ApplicantsScreen extends ConsumerWidget {
  final String opportunityId;

  const ApplicantsScreen({super.key, required this.opportunityId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final applicationsAsync =
        ref.watch(opportunityApplicationsProvider(opportunityId));

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(title: const Text('Applicants')),
      body: applicationsAsync.when(
        data: (applications) {
          if (applications.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.people_outline,
                      size: 64, color: AppTheme.textGrey),
                  const SizedBox(height: 16),
                  Text('No applicants yet',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: AppTheme.textGrey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: applications.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return _ApplicantCard(application: applications[index]);
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ApplicantCard extends ConsumerWidget {
  final ApplicationModel application;

  const _ApplicantCard({required this.application});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final statusColor = AppTheme.getStatusColor(application.status);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Name and status row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(application.studentName,
                    style: Theme.of(context).textTheme.titleSmall),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    application.status[0].toUpperCase() +
                        application.status.substring(1),
                    style: TextStyle(
                        color: statusColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 8),

            // Cover note preview
            Text(
              application.coverNote,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textGrey),
            ),

            const SizedBox(height: 12),

            // Status update buttons
            // Only show actions if not yet accepted or rejected
            if (application.status != 'accepted' &&
                application.status != 'rejected')
              Row(
                children: [
                  if (application.status == 'submitted')
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => _updateStatus(
                            context, ref, 'reviewing'),
                        child: const Text('Mark Reviewing'),
                      ),
                    ),
                  if (application.status == 'submitted')
                    const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _updateStatus(context, ref, 'accepted'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.successGreen),
                      child: const Text('Accept'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () =>
                          _updateStatus(context, ref, 'rejected'),
                      style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.errorRed),
                      child: const Text('Reject'),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _updateStatus(
      BuildContext context, WidgetRef ref, String status) async {
    await ref
        .read(applicationNotifierProvider.notifier)
        .updateStatus(applicationId: application.id, status: status);

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Application marked as $status'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
    }
  }
}