class StartupModel {
  final String id;
  final String adminUid;
  final String name;
  final String description;
  final String industry;
  final String logoUrl;
  final String verificationStatus; // 'pending', 'verified', 'rejected'
  final String verifiedBy;
  final DateTime? verifiedAt;
  final DateTime createdAt;

  const StartupModel({
    required this.id,
    required this.adminUid,
    required this.name,
    required this.description,
    required this.industry,
    this.logoUrl = '',
    this.verificationStatus = 'pending',
    this.verifiedBy = '',
    this.verifiedAt,
    required this.createdAt,
  });

  factory StartupModel.fromMap(Map<String, dynamic> map, String docId) {
    return StartupModel(
      id: docId,
      adminUid: map['adminUid'] ?? '',
      name: map['name'] ?? '',
      description: map['description'] ?? '',
      industry: map['industry'] ?? '',
      logoUrl: map['logoUrl'] ?? '',
      verificationStatus: map['verificationStatus'] ?? 'pending',
      verifiedBy: map['verifiedBy'] ?? '',
      verifiedAt: map['verifiedAt']?.toDate(),
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'adminUid': adminUid,
      'name': name,
      'description': description,
      'industry': industry,
      'logoUrl': logoUrl,
      'verificationStatus': verificationStatus,
      'verifiedBy': verifiedBy,
      'verifiedAt': verifiedAt,
      'createdAt': createdAt,
    };
  }

  StartupModel copyWith({
    String? name,
    String? description,
    String? industry,
    String? logoUrl,
    String? verificationStatus,
    String? verifiedBy,
    DateTime? verifiedAt,
  }) {
    return StartupModel(
      id: id,
      adminUid: adminUid,
      name: name ?? this.name,
      description: description ?? this.description,
      industry: industry ?? this.industry,
      logoUrl: logoUrl ?? this.logoUrl,
      verificationStatus: verificationStatus ?? this.verificationStatus,
      verifiedBy: verifiedBy ?? this.verifiedBy,
      verifiedAt: verifiedAt ?? this.verifiedAt,
      createdAt: createdAt,
    );
  }
}