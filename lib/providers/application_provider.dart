import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/application_model.dart';
import '../services/application_service.dart';
import 'auth_provider.dart';
import 'startup_provider.dart';

// Single shared instance of ApplicationService
final applicationServiceProvider = Provider<ApplicationService>((ref) {
  return ApplicationService();
});

// Streams all applications submitted by the currently logged in student
// This is what powers the student's "My Applications" tracking screen
// When a startup admin updates a status, this stream emits a new list
// and the tracking screen rebuilds automatically — no manual refresh needed
final myApplicationsProvider =
    StreamProvider<List<ApplicationModel>>((ref) {
  final userAsync = ref.watch(currentUserProvider);

  return userAsync.when(
    data: (user) {
      if (user == null) return const Stream.empty();
      if (user.role != 'student') return const Stream.empty();
      return ref
          .watch(applicationServiceProvider)
          .getApplicationsByStudent(user.uid);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Streams all applications received by the currently logged in startup
// Powers the startup admin's applicants screen
final startupApplicationsProvider =
    StreamProvider<List<ApplicationModel>>((ref) {
  final startupAsync = ref.watch(currentStartupProvider);

  return startupAsync.when(
    data: (startup) {
      if (startup == null) return const Stream.empty();
      return ref
          .watch(applicationServiceProvider)
          .getApplicationsByStartup(startup.id);
    },
    loading: () => const Stream.empty(),
    error: (_, __) => const Stream.empty(),
  );
});

// Streams applications for a specific opportunity
// Used when a startup admin taps on one opportunity to see its applicants
final opportunityApplicationsProvider =
    StreamProvider.family<List<ApplicationModel>, String>(
        (ref, opportunityId) {
  return ref
      .watch(applicationServiceProvider)
      .getApplicationsByOpportunity(opportunityId);
});

// Manages application submission, status updates and withdrawal
class ApplicationNotifier extends StateNotifier<String?> {
  final ApplicationService _applicationService;

  ApplicationNotifier(this._applicationService) : super(null);

  // Called when a student submits an application
  Future<bool> submitApplication({
    required String opportunityId,
    required String startupId,
    required String startupAdminUid,
    required String studentUid,
    required String studentName,
    required String coverNote,
  }) async {
    state = null;
    try {
      await _applicationService.createApplication(
        opportunityId: opportunityId,
        startupId: startupId,
        startupAdminUid: startupAdminUid,
        studentUid: studentUid,
        studentName: studentName,
        coverNote: coverNote,
      );
      return true;
    } catch (e) {
      state = e.toString();
      return false;
    }
  }

  // Called by startup admin to move an application through the pipeline
  // submitted → reviewing → accepted or rejected
  Future<bool> updateStatus({
    required String applicationId,
    required String status,
  }) async {
    state = null;
    try {
      await _applicationService.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
      );
      return true;
    } catch (e) {
      state = e.toString();
      return false;
    }
  }

  // Called when a student withdraws their application
  Future<bool> withdrawApplication(String applicationId) async {
    state = null;
    try {
      await _applicationService.withdrawApplication(applicationId);
      return true;
    } catch (e) {
      state = e.toString();
      return false;
    }
  }
}

final applicationNotifierProvider =
    StateNotifierProvider<ApplicationNotifier, String?>((ref) {
  return ApplicationNotifier(ref.read(applicationServiceProvider));
});