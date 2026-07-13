import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/opportunity_model.dart';

class OpportunityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CREATE — only verified startups can post opportunities
  // The security rules enforce this on the backend, but we also
  // check verificationStatus in the UI before showing the post button
  Future<OpportunityModel> createOpportunity({
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
    try {
      final docRef = _firestore.collection('opportunities').doc();

      final opportunity = OpportunityModel(
        id: docRef.id,
        startupId: startupId,
        startupName: startupName,
        startupAdminUid: startupAdminUid,
        title: title,
        description: description,
        requiredSkillTags: requiredSkillTags,
        type: type,
        duration: duration,
        isPaid: isPaid,
        createdAt: DateTime.now(),
      );

      await docRef.set(opportunity.toMap());
      return opportunity;
    } catch (e) {
      throw 'Failed to create opportunity. Please try again.';
    }
  }

  // READ — streams all open opportunities for the student discovery screen
  // Ordered by most recent first
  Stream<List<OpportunityModel>> getOpenOpportunities() {
    return _firestore
        .collection('opportunities')
        .where('status', isEqualTo: 'open')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OpportunityModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // READ — streams opportunities posted by a specific startup
  // Used on the startup admin's home screen to see their own postings
  Stream<List<OpportunityModel>> getOpportunitiesByStartup(String startupId) {
    return _firestore
        .collection('opportunities')
        .where('startupId', isEqualTo: startupId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OpportunityModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // READ — fetches a single opportunity by ID
  // Used when navigating to the opportunity detail screen
  Future<OpportunityModel?> getOpportunityById(String opportunityId) async {
    try {
      final doc = await _firestore
          .collection('opportunities')
          .doc(opportunityId)
          .get();
      if (!doc.exists) return null;
      return OpportunityModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw 'Failed to fetch opportunity.';
    }
  }

  // READ — filters opportunities by skill tag match
  // Used on the discovery screen when a student filters by their skills
  // Firestore's arrayContains checks if a specific value exists in an array field
  Stream<List<OpportunityModel>> getOpportunitiesBySkill(String skill) {
    return _firestore
        .collection('opportunities')
        .where('status', isEqualTo: 'open')
        .where('requiredSkillTags', arrayContains: skill)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => OpportunityModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // UPDATE — startup admin opens or closes an opportunity
  Future<void> updateOpportunityStatus({
    required String opportunityId,
    required String status, // 'open' or 'closed'
  }) async {
    try {
      await _firestore
          .collection('opportunities')
          .doc(opportunityId)
          .update({'status': status});
    } catch (e) {
      throw 'Failed to update opportunity status.';
    }
  }

  // UPDATE — startup admin edits an existing opportunity
  Future<void> updateOpportunity({
    required String opportunityId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore
          .collection('opportunities')
          .doc(opportunityId)
          .update(data);
    } catch (e) {
      throw 'Failed to update opportunity.';
    }
  }

  // DELETE — startup admin removes an opportunity
  Future<void> deleteOpportunity(String opportunityId) async {
    try {
      await _firestore
          .collection('opportunities')
          .doc(opportunityId)
          .delete();
    } catch (e) {
      throw 'Failed to delete opportunity.';
    }
  }
}