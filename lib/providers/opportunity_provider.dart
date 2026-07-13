import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/opportunity_model.dart';
import '../services/opportunity_service.dart';
import 'startup_provider.dart';

// Single shared instance of OpportunityService
final opportunityServiceProvider = Provider<OpportunityService>((ref) {
  return OpportunityService();
});

// Streams all open opportunities for the student discovery screen
final openOpportunitiesProvider =
    StreamProvider<List<OpportunityModel>>((ref) {
  return ref.watch(opportunityServiceProvider).getOpenOpportunities();
});

// Streams opportunities for a specific startup
// Takes a startupId as a parameter using the .family modifier
// .family lets us create a provider that takes an argument
// so we can have one provider definition that works for any startupId
final startupOpportunitiesProvider =
    StreamProvider.family<List<OpportunityModel>, String>((ref, startupId) {
  return ref
      .watch(opportunityServiceProvider)
      .getOpportunitiesByStartup(startupId);
});

// Streams opportunities filtered by a specific skill tag
final opportunitiesBySkillProvider =
    StreamProvider.family<List<OpportunityModel>, String>((ref, skill) {
  return ref.watch(opportunityServiceProvider).getOpportunitiesBySkill(skill);
});

// Fetches a single opportunity by ID
// Used when navigating to the opportunity detail screen
final opportunityByIdProvider =
    FutureProvider.family<OpportunityModel?, String>((ref, opportunityId) {
  return ref
      .read(opportunityServiceProvider)
      .getOpportunityById(opportunityId);
});

// Holds the currently selected skill filter on the discovery screen
// null means no filter is active — show all open opportunities
// When a student taps a skill tag, this state updates and the
// discovery screen automatically switches between filtered and unfiltered results
final selectedSkillFilterProvider = StateProvider<String?>((ref) => null);

// Manages opportunity creation, update and delete actions
class OpportunityNotifier extends StateNotifier<String?> {
  final OpportunityService _opportunityService;

  OpportunityNotifier(this._opportunityService) : super(null);

  // Called when a verified startup admin posts a new opportunity
  Future<bool> createOpportunity({
    required String startupId,
    required String startupName,
    required String startupAdminUid,
    required String title,
    required String description,
    required List<String> requiredSkillTags,
    required String type,
    required String duration,
    required bool isPaid,
  }) async {
    state = null;
    try {
      await _opportunityService.createOpportunity(
        startupId: startupId,
        startupName: startupName,
        startupAdminUid: startupAdminUid,
        title: title,
        description: description,
        requiredSkillTags: requiredSkillTags,
        type: type,
        duration: duration,
        isPaid: isPaid,
      );
      return true;
    } catch (e) {
      state = e.toString();
      return false;
    }
  }

  // Called when startup admin opens or closes an opportunity
  Future<bool> updateOpportunityStatus({
    required String opportunityId,
    required String status,
  }) async {
    state = null;
    try {
      await _opportunityService.updateOpportunityStatus(
        opportunityId: opportunityId,
        status: status,
      );
      return true;
    } catch (e) {
      state = e.toString();
      return false;
    }
  }

  // Called when startup admin edits an opportunity
  Future<bool> updateOpportunity({
    required String opportunityId,
    required Map<String, dynamic> data,
  }) async {
    state = null;
    try {
      await _opportunityService.updateOpportunity(
        opportunityId: opportunityId,
        data: data,
      );
      return true;
    } catch (e) {
      state = e.toString();
      return false;
    }
  }

  // Called when startup admin deletes an opportunity
  Future<bool> deleteOpportunity(String opportunityId) async {
    state = null;
    try {
      await _opportunityService.deleteOpportunity(opportunityId);
      return true;
    } catch (e) {
      state = e.toString();
      return false;
    }
  }
}

final opportunityNotifierProvider =
    StateNotifierProvider<OpportunityNotifier, String?>((ref) {
  return OpportunityNotifier(ref.read(opportunityServiceProvider));
});