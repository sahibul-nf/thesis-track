enum UserRole {
  student('Student'),
  lecturer('Lecturer'),
  admin('Admin');

  final String value;
  const UserRole(this.value);

  factory UserRole.fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value.toLowerCase() == value.toLowerCase(),
      orElse: () => throw ArgumentError('Invalid user role: $value'),
    );
  }

  @override
  String toString() => value;
}