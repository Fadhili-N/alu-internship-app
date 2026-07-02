import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/opportunity_provider.dart';

class OpportunityDetailScreen extends ConsumerWidget {
  final String opportunityId;

  const OpportunityDetailScreen({
    super.key,
    required this.opportunityId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final opportunityAsync =
        ref.watch(opportunityByIdProvider(opportunityId));
    final userAsync = ref.watch(currentUserProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(title: const Text('Opportunity Details')),
      body: opportunityAsync.when(
        data: (opportunity) {
          if (opportunity == null) {
            return const Center(child: Text('Opportunity not found.'));
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.backgroundDark,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        opportunity.startupName,
                        style: const TextStyle(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.w600,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        opportunity.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      // Meta row
                      Row(
                        children: [
                          _MetaBadge(
                            icon: Icons.access_time,
                            label: opportunity.type,
                          ),
                          const SizedBox(width: 8),
                          _MetaBadge(
                            icon: Icons.calendar_today,
                            label: opportunity.duration,
                          ),
                          const SizedBox(width: 8),
                          _MetaBadge(
                            icon: Icons.attach_money,
                            label: opportunity.isPaid ? 'Paid' : 'Unpaid',
                            color: opportunity.isPaid
                                ? AppTheme.successGreen
                                : AppTheme.textGrey,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // Description
                Text(
                  'About this opportunity',
                  style: Theme.of(context).textTheme.titleSmall,
                ),
                const SizedBox(height: 8),
                Text(
                  opportunity.description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textGrey,
                        height: 1.6,
                      ),
                ),

                const SizedBox(height: 24),

                // Required skills
                if (opportunity.requiredSkillTags.isNotEmpty) ...[
                  Text(
                    'Required Skills',
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: opportunity.requiredSkillTags.map((skill) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryRed.withOpacity(0.08),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.primaryRed.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          skill,
                          style: const TextStyle(
                            color: AppTheme.primaryRed,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 24),
                ],

                const SizedBox(height: 16),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),

      // Apply button fixed at bottom
      bottomNavigationBar: opportunityAsync.when(
        data: (opportunity) {
          if (opportunity == null) return const SizedBox.shrink();
          return userAsync.when(
            data: (user) => Padding(
              padding: const EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pushNamed(
                  '/apply',
                  arguments: {
                    'opportunityId': opportunity.id,
                    'startupId': opportunity.startupId,
                    'opportunityTitle': opportunity.title,
                    'studentUid': user?.uid ?? '',
                    'studentName': user?.displayName ?? '',
                  },
                ),
                child: const Text('Apply Now'),
              ),
            ),
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          );
        },
        loading: () => const SizedBox.shrink(),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

class _MetaBadge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _MetaBadge({
    required this.icon,
    required this.label,
    this.color = Colors.white70,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          label,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}