import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/theme/app_theme.dart';
import '../../providers/auth_provider.dart';
import '../../providers/startup_provider.dart';

class StartupPendingScreen extends ConsumerWidget {
  const StartupPendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final startupAsync = ref.watch(currentStartupProvider);

    return Scaffold(
      backgroundColor: AppTheme.backgroundWhite,
      appBar: AppBar(
        title: const Text('Verification Pending'),
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
          // If startup gets verified while on this screen,
          // automatically navigate to startup home
          if (startup != null &&
              startup.verificationStatus == 'verified') {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              Navigator.of(context).pushReplacementNamed('/startup-home');
            });
          }

          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppTheme.warningAmber.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.hourglass_empty_rounded,
                    size: 48,
                    color: AppTheme.warningAmber,
                  ),
                ),

                const SizedBox(height: 32),

                Text(
                  'Awaiting Verification',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 16),

                Text(
                  'Your startup ${startup?.name ?? ''} has been submitted for verification by the ALU Ventures Lab. You will be able to post opportunities once your startup is approved.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppTheme.textGrey,
                      ),
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: 48),

                // Status badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.warningAmber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppTheme.warningAmber,
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.pending_outlined,
                        color: AppTheme.warningAmber,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Status: Pending Review',
                        style: TextStyle(
                          color: AppTheme.warningAmber,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}