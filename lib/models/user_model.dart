class UserModel {
  final String uid;
  final String email;
  final String displayName;
  final String role; // 'student', 'startup_admin', 'ventures_lab_admin'
  final List<String> skillTags;
  final String bio;
  final String profileImageUrl;
  final DateTime createdAt;

  const UserModel({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.skillTags = const [],
    this.bio = '',
    this.profileImageUrl = '',
    required this.createdAt,
  });

  // Converts a Firestore document into a UserModel object
  // We use this every time we read a user from Firestore
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'] ?? '',
      role: map['role'] ?? 'student',
      skillTags: List<String>.from(map['skillTags'] ?? []),
      bio: map['bio'] ?? '',
      profileImageUrl: map['profileImageUrl'] ?? '',
      createdAt: map['createdAt']?.toDate() ?? DateTime.now(),
    );
  }

  // Converts a UserModel object into a Map so we can write it to Firestore
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'role': role,
      'skillTags': skillTags,
      'bio': bio,
      'profileImageUrl': profileImageUrl,
      'createdAt': createdAt,
    };
  }

  // Creates a copy of this model with specific fields changed
  // Useful when updating a user profile without rewriting every field
  UserModel copyWith({
    String? displayName,
    String? bio,
    String? profileImageUrl,
    List<String>? skillTags,
  }) {
    return UserModel(
      uid: uid,
      email: email,
      displayName: displayName ?? this.displayName,
      role: role,
      skillTags: skillTags ?? this.skillTags,
      bio: bio ?? this.bio,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt,
    );
  }
}