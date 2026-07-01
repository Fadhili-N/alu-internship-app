import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/startup_model.dart';

class StartupService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // CREATE — registers a new startup with 'pending' verification status
  // Only called after a user selects the 'startup_admin' role during registration
  Future<StartupModel> createStartup({
    required String adminUid,
    required String name,
    required String description,
    required String industry,
  }) async {
    try {
      // Let Firestore generate the document ID automatically
      final docRef = _firestore.collection('startups').doc();

      final startup = StartupModel(
        id: docRef.id,
        adminUid: adminUid,
        name: name,
        description: description,
        industry: industry,
        createdAt: DateTime.now(),
      );

      await docRef.set(startup.toMap());
      return startup;
    } catch (e) {
      throw 'Failed to create startup. Please try again.';
    }
  }

  // READ — fetches a single startup by its document ID
  Future<StartupModel?> getStartupById(String startupId) async {
    try {
      final doc =
          await _firestore.collection('startups').doc(startupId).get();
      if (!doc.exists) return null;
      return StartupModel.fromMap(doc.data()!, doc.id);
    } catch (e) {
      throw 'Failed to fetch startup.';
    }
  }

  // READ — fetches the startup belonging to a specific admin user
  // Used after login to load the startup admin's own startup profile
  Future<StartupModel?> getStartupByAdminUid(String adminUid) async {
    try {
      final query = await _firestore
          .collection('startups')
          .where('adminUid', isEqualTo: adminUid)
          .limit(1)
          .get();

      if (query.docs.isEmpty) return null;
      return StartupModel.fromMap(query.docs.first.data(), query.docs.first.id);
    } catch (e) {
      throw 'Failed to fetch startup profile.';
    }
  }

  // READ — streams all pending startups for the ventures lab admin screen
  // Using a stream means the admin screen updates in real time as new
  // startups register without needing a manual refresh
  Stream<List<StartupModel>> getPendingStartups() {
    return _firestore
        .collection('startups')
        .where('verificationStatus', isEqualTo: 'pending')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StartupModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // READ — streams all verified startups for the student discovery screen
  Stream<List<StartupModel>> getVerifiedStartups() {
    return _firestore
        .collection('startups')
        .where('verificationStatus', isEqualTo: 'verified')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => StartupModel.fromMap(doc.data(), doc.id))
            .toList());
  }

  // UPDATE — ventures lab admin approves or rejects a startup
  // This is our most important live demo moment for the State Management
  // criterion — flipping this field triggers real time UI updates everywhere
  Future<void> updateVerificationStatus({
    required String startupId,
    required String status, // 'verified' or 'rejected'
    required String verifiedByUid,
  }) async {
    try {
      await _firestore.collection('startups').doc(startupId).update({
        'verificationStatus': status,
        'verifiedBy': verifiedByUid,
        'verifiedAt': DateTime.now(),
      });
    } catch (e) {
      throw 'Failed to update verification status.';
    }
  }

  // UPDATE — startup admin updates their own startup profile
  Future<void> updateStartup({
    required String startupId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await _firestore.collection('startups').doc(startupId).update(data);
    } catch (e) {
      throw 'Failed to update startup profile.';
    }
  }
}