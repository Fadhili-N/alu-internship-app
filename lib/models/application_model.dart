class ApplicationModel {
  final String id;
  final String opportunityId;
  final String startupId;
  final String startupAdminUid; // denormalized so security rules can check ownership directly
  final String studentUid;
  final String studentName; // denormalized to avoid extra Firestore reads
  final String coverNote;
  final String status; // 'submitted', 'reviewing', 'accepted', 'rejected'
  final DateTime appliedAt;
  final DateTime updatedAt;

  const ApplicationModel({
    required this.id,
    required this.opportunityId,
    required this.startupId,
    required this.startupAdminUid,
    required this.studentUid,
    required this.studentName,
    required this.coverNote,
    this.status = 'submitted',
    required this.appliedAt,
    required this.updatedAt,
  });

  factory ApplicationModel.fromMap(Map<String, dynamic> map, String docId) {
    return ApplicationModel(
      id: docId,
      opportunityId: map['opportunityId'] ?? '',
      startupId: map['startupId'] ?? '',
      startupAdminUid: map['startupAdminUid'] ?? '',
      studentUid: map['studentUid'] ?? '',
      studentName: map['studentName'] ?? '',
      coverNote: map['coverNote'] ?? '',
      status: map['status'] ?? 'submitted',
      appliedAt: map['appliedAt']?.toDate() ?? DateTime.now(),
      updatedAt: map['updatedAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'opportunityId': opportunityId,
      'startupId': startupId,
      'startupAdminUid': startupAdminUid,
      'studentUid': studentUid,
      'studentName': studentName,
      'coverNote': coverNote,
      'status': status,
      'appliedAt': appliedAt,
      'updatedAt': updatedAt,
    };
  }

  ApplicationModel copyWith({
    String? status,
    DateTime? updatedAt,
  }) {
    return ApplicationModel(
      id: id,
      opportunityId: opportunityId,
      startupId: startupId,
      startupAdminUid: startupAdminUid,
      studentUid: studentUid,
      studentName: studentName,
      coverNote: coverNote,
      status: status ?? this.status,
      appliedAt: appliedAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}