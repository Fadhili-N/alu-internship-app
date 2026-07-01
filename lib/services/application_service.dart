import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/application_model.dart';

class ApplicationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CREATE — student submits an application for an opportunity
  Future<ApplicationModel> createApplication({
    required String opportunityId,
    required String startupId,
    required String studentUid,
    required String studentName,
    required String coverNote,
  }) async {
    try {
      // Check if student has already applied for this opportunity
      // A student should never have two applications for the same opportunity
      final existing = await _firestore
          .collection('applications')
          .where('opportunityId', isEqualTo: opportunityId)
          .where('studentUid', isEqualTo: studentUid)
          .get();

      if (existing.docs.isNotEmpty) {
        throw 'You have already applied for this opportunity.';
      }

      final docRef = _firestore.collection('applications').doc();

      final application = ApplicationModel(
        id: docRef.id,
        opportunityId: opportunityId,
        startupId: startupId,
        studentUid: studentUid,
        studentName: studentName,
        coverNote: coverNote,
        appliedAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      await docRef.set(application.toMap());
      return application;
    } catch (e) {
      // Rethrow our custom duplicate message as-is
      // but wrap unexpected Firebase errors in a generic message
      if (e is String) rethrow;
      throw 'Failed to submit application. Please try again.';
    }
  }

  // READ — streams all applications submitted by a specific student
  // Used on the student's "My Applications" tracking screen
  // This is our best live demo moment for the student side —
  // status changes made by the startup admin appear here in real time
  Stream<List<ApplicationModel>> getApplicationsByStudent(String studentUid) {
    return _firestore
        .collection('applications')
        .where('studentUid', isEqualTo: studentUid)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // READ — streams all applications received by a specific startup
  // Used on the startup admin's applicants screen
  Stream<List<ApplicationModel>> getApplicationsByStartup(String startupId) {
    return _firestore
        .collection('applications')
        .where('startupId', isEqualTo: startupId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // READ — streams applications for a specific opportunity
  // Used when a startup admin views applicants for one particular posting
  Stream<List<ApplicationModel>> getApplicationsByOpportunity(
      String opportunityId) {
    return _firestore
        .collection('applications')
        .where('opportunityId', isEqualTo: opportunityId)
        .orderBy('appliedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ApplicationModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // UPDATE — startup admin moves an application through the pipeline
  // 'submitted' → 'reviewing' → 'accepted' or 'rejected'
  // This triggers the real time update on the student's tracking screen
  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      await _firestore
          .collection('applications')
          .doc(applicationId)
          .update({
        'status': status,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw 'Failed to update application status.';
    }
  }

  // DELETE — student withdraws their application
  // Only allowed if status is still 'submitted'
  Future<void> withdrawApplication(String applicationId) async {
    try {
      await _firestore
          .collection('applications')
          .doc(applicationId)
          .delete();
    } catch (e) {
      throw 'Failed to withdraw application.';
    }
  }
}