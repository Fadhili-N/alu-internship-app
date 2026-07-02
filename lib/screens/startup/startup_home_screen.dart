import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../models/opportunity_model.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';
import '../../providers/startup_provider.dart';

class StartupHomeScreen extends ConsumerWidget {
  const StartupHomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(currentStartupProvider);
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('My Startup'),
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
      body: startupAsync.when(
        data: (startup) {
          if (startup == null) {
            return const Center(child: Text('Startup profile not found.'));
          }

          return Column(
            children: [
              // Startup header
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                color: AppTheme.backgroundDark,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AppTheme.primaryRed,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.rocket_launch_rounded,
                            color: Colors.white,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                startup.name,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                startup.industry,
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        // Verification badge
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.getStatusColor(
                                    startup.verificationStatus)
                                .withOpacity(0.2),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: AppTheme.getStatusColor(
                                  startup.verificationStatus),
                            ),
                          ),
                          child: Text(
                            startup.verificationStatus[0].toUpperCase() +
                                startup.verificationStatus.substring(1),
                            style: TextStyle(
                              color: AppTheme.getStatusColor(
                                  startup.verificationStatus),
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Opportunities section
              Expanded(
                child: userAsync.when(
                  data: (user) {
                    if (user == null) return const SizedBox.shrink();

                    final opportunitiesAsync = ref
                        .watch(startupOpportunitiesProvider(startup.id));

                    return opportunitiesAsync.when(
                      data: (opportunities) {
                        return Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                  16, 16, 16, 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Posted Opportunities',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleSmall,
                                  ),
                                  // Only verified startups can post
                                  if (startup.verificationStatus ==
                                      'verified')
                                    TextButton.icon(
                                      onPressed: () =>
                                          Navigator.of(context).pushNamed(
                                        '/create-opportunity',
                                        arguments: {
                                          'startupId': startup.id,
                                          'startupName': startup.name,
                                        },
                                      ),
                                      icon: const Icon(Icons.add, size: 18),
                                      label: const Text('Post New'),
                                    ),
                                ],
                              ),
                            ),
                            Expanded(
                              child: opportunities.isEmpty
                                  ? Center(
                                      child: Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          const Icon(
                                            Icons.work_outline,
                                            size: 64,
                                            color: AppTheme.textGrey,
                                          ),
                                          const SizedBox(height: 16),
                                          Text(
                                            startup.verificationStatus ==
                                                    'verified'
                                                ? 'No opportunities posted yet'
                                                : 'Get verified to post opportunities',
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodyMedium
                                                ?.copyWith(
                                                  color: AppTheme.textGrey,
                                                ),
                                          ),
                                        ],
                                      ),
                                    )
                                  : ListView.separated(
                                      padding: const EdgeInsets.all(16),
                                      itemCount: opportunities.length,
                                      separatorBuilder: (_, __) =>
                                          const SizedBox(height: 12),
                                      itemBuilder: (context, index) {
                                        return _StartupOpportunityCard(
                                          opportunity: opportunities[index],
                                          onTap: () =>
                                              Navigator.of(context).pushNamed(
                                            '/applicants',
                                            arguments: opportunities[index].id,
                                          ),
                                        );
                                      },
                                    ),
                            ),
                          ],
                        );
                      },
                      loading: () => const Center(
                          child: CircularProgressIndicator()),
                      error: (e, _) => Center(child: Text('Error: $e')),
                    );
                  },
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (e, _) => Center(child: Text('Error: $e')),
                ),
              ),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _StartupOpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback onTap;

  const _StartupOpportunityCard({
    required this.opportunity,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      opportunity.title,
                      style: Theme.of(context).textTheme.titleSmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${opportunity.type} · ${opportunity.duration}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textGrey,
                          ),
                    ),
                  ],
                ),
              ),
              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: opportunity.status == 'open'
                      ? AppTheme.successGreen.withOpacity(0.1)
                      : AppTheme.textGrey.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  opportunity.status[0].toUpperCase() +
                      opportunity.status.substring(1),
                  style: TextStyle(
                    color: opportunity.status == 'open'
                        ? AppTheme.successGreen
                        : AppTheme.textGrey,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppTheme.textGrey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}