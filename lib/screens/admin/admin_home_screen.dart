import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/startup_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';

class AdminHomeScreen extends ConsumerWidget {
  const AdminHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pendingAsync = ref.watch(pendingStartupsProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Ventures Lab Admin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ref.read(authNotifierProvider.notifier).signOut();
              if (context.mounted) {
                Navigator.of(context).pushReplacementNamed('/login');
              }
            },
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(24),
            color: AppTheme.backgroundDark,
            child: userAsync.when(
              data: (user) => Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Startup Verification',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Review and verify ALU student startups',
                    style: TextStyle(color: Colors.white60, fontSize: 13),
                  ),
                ],
              ),
              loading: () => const SizedBox.shrink(),
              error: (_, __) => const SizedBox.shrink(),
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(
              'Pending Verification',
              style: Theme.of(context).textTheme.titleSmall,
            ),
          ),

          // Pending startups list
          Expanded(
            child: pendingAsync.when(
              data: (startups) {
                if (startups.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.verified_outlined,
                            size: 64, color: AppTheme.textGrey),
                        const SizedBox(height: 16),
                        Text(
                          'No pending startups',
                          style: Theme.of(context)
                              .textTheme
                              .bodyMedium
                              ?.copyWith(color: AppTheme.textGrey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'All startups have been reviewed',
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textGrey),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: startups.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, index) {
                    return _PendingStartupCard(
                      startup: startups[index],
                      adminUid: userAsync.value?.uid ?? '',
                    );
                  },
                );
              },
              loading: () =>
                  const Center(child: CircularProgressIndicator()),
              error: (e, _) => Center(child: Text('Error: $e')),
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingStartupCard extends ConsumerWidget {
  final StartupModel startup;
  final String adminUid;

  const _PendingStartupCard({
    required this.startup,
    required this.adminUid,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Startup name and industry
            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryRed.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.rocket_launch_outlined,
                      color: AppTheme.primaryRed, size: 22),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(startup.name,
                          style: Theme.of(context).textTheme.titleSmall),
                      Text(startup.industry,
                          style: Theme.of(context)
                              .textTheme
                              .bodySmall
                              ?.copyWith(color: AppTheme.textGrey)),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // Description
            Text(
              startup.description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: AppTheme.textGrey),
            ),

            const SizedBox(height: 16),

            // Approve and reject buttons
            // Tapping either triggers updateVerificationStatus
            // which updates Firestore and the stream rebuilds this list
            // — the card disappears in real time without a refresh
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _verify(context, ref, 'verified'),
                    style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.successGreen),
                    child: const Text('Approve'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _verify(context, ref, 'rejected'),
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

  Future<void> _verify(
      BuildContext context, WidgetRef ref, String status) async {
    await ref
        .read(startupNotifierProvider.notifier)
        .updateVerificationStatus(
          startupId: startup.id,
          status: status,
          verifiedByUid: adminUid,
        );

    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Startup ${status == 'verified' ? 'approved' : 'rejected'} successfully'),
          backgroundColor: status == 'verified'
              ? AppTheme.successGreen
              : AppTheme.errorRed,
        ),
      );
    }
  }
}