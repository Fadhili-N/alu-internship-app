import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/startup_model.dart';
import '../services/startup_service.dart';
import 'auth_provider.dart';

// Single shared instance of StartupService
final startupServiceProvider = Provider<StartupService>((ref) {
  return StartupService();
});

// Streams all pending startups for the ventures lab admin screen
// Rebuilds automatically whenever a startup's verification status changes
final pendingStartupsProvider = StreamProvider<List<StartupModel>>((ref) {
  return ref.watch(startupServiceProvider).getPendingStartups();
});

// Streams all verified startups for the student discovery screen
final verifiedStartupsProvider = StreamProvider<List<StartupModel>>((ref) {
  return ref.watch(startupServiceProvider).getVerifiedStartups();
});

// Fetches the startup profile belonging to the currently logged in startup admin
// Depends on currentUserProvider — rebuilds when the logged in user changes
final currentStartupProvider = FutureProvider<StartupModel?>((ref) async {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) async {
      if (user == null) return null;
      if (user.role != 'startup_admin') return null;
      return ref
          .read(startupServiceProvider)
          .getStartupByAdminUid(user.uid);
    },
    loading: () => null,
    error: (_, __) => null,
  );
});

// Manages startup creation and verification actions
class StartupNotifier extends StateNotifier<String?> {
  final StartupService _startupService;

  StartupNotifier(this._startupService) : super(null);

  // Called when a startup admin completes registration
  Future<bool> createStartup({
    required String adminUid,
    required String name,
    required String description,
    required String industry,
  }) async {
    state = null;
    try {
      await _startupService.createStartup(
        adminUid: adminUid,
        name: name,
        description: description,
        industry: industry,
      );
      return true;
    } catch (e) {
      state = e.toString();
      return false;
    }
  }

  // Called by ventures lab admin to approve or reject a startup
  // This is the action that triggers real time updates across the app
  Future<bool> updateVerificationStatus({
    required String startupId,
    required String status,
    required String verifiedByUid,
  }) async {
    state = null;
    try {
      await _startupService.updateVerificationStatus(
        startupId: startupId,
        status: status,
        verifiedByUid: verifiedByUid,
      );
      return true;
    } catch (e) {
      state = e.toString();
      return false;
    }
  }

  // Called when startup admin updates their profile
  Future<bool> updateStartup({
    required String startupId,
    required Map<String, dynamic> data,
  }) async {
    state = null;
    try {
      await _startupService.updateStartup(
        startupId: startupId,
        data: data,
      );
      return true;
    } catch (e) {
      state = e.toString();
      return false;
    }
  }
}

final startupNotifierProvider =
    StateNotifierProvider<StartupNotifier, String?>((ref) {
  return StartupNotifier(ref.read(startupServiceProvider));
});