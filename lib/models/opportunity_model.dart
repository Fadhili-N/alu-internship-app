class OpportunityModel {
  final String id;
  final String startupId;
  final String startupName; // denormalized to avoid extra Firestore reads
  final String title;
  final String description;
  final List<String> requiredSkillTags;
  final String type; // 'part-time', 'full-time', 'project-based'
  final String duration;
  final bool isPaid;
  final String status; // 'open', 'closed'
  final DateTime createdAt;

  const OpportunityModel({
    required this.id,
    required this.startupId,
    required this.startupName,
    required this.title,
    required this.description,
    this.requiredSkillTags = const [],
    required this.type,
    required this.duration,
    this.isPaid = false,
    this.status = 'open',
    required this.createdAt,
  });

  factory OpportunityModel.fromMap(Map<String, dynamic> map, String docId) {
    return OpportunityModel(
      id: docId,
      startupId: map['startupId'] ?? '',
      startupName: map['startupName'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      requiredSkillTags: List<String>.from(map['requiredSkillTags'] ?? []),
      type: map['type'] ?? 'part-time',
      duration: map['duration'] ?? '',
      isPaid: map['isPaid'] ?? false,
      status: map['status'] ?? 'open',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'startupId': startupId,
      'startupName': startupName,
      'title': title,
      'description': description,
      'requiredSkillTags': requiredSkillTags,
      'type': type,
      'duration': duration,
      'isPaid': isPaid,
      'status': status,
      'createdAt': createdAt,
    };
  }

  OpportunityModel copyWith({
    String? title,
    String? description,
    List<String>? requiredSkillTags,
    String? type,
    String? duration,
    bool? isPaid,
    String? status,
  }) {
    return OpportunityModel(
      id: id,
      startupId: startupId,
      startupName: startupName,
      title: title ?? this.title,
      description: description ?? this.description,
      requiredSkillTags: requiredSkillTags ?? this.requiredSkillTags,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      isPaid: isPaid ?? this.isPaid,
      status: status ?? this.status,
      createdAt: createdAt,
    );
  }
}