class UserEntity {
  final String id;
  final String fullName;
  final String email;
  final String? phone;
  final String role;
  final String? avatarUrl;
  final bool isVerified;
  final bool isActive;

  UserEntity({
    required this.id,
    required this.fullName,
    required this.email,
    this.phone,
    required this.role,
    this.avatarUrl,
    required this.isVerified,
    required this.isActive,
  });
}
