class AppUser {
  final String uid;
  final String name;
  final String email;
  final String role; // 'student' or 'staff'

  const AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.role,
  });

  bool get isStaff => role == 'staff';

  String get firstName => name.trim().isEmpty ? 'there' : name.trim().split(' ').first;

  String get initials {
    final parts = name.trim().split(' ').where((p) => p.isNotEmpty).toList();
    if (parts.isEmpty) return '?';
    if (parts.length == 1) return parts.first[0].toUpperCase();
    return (parts.first[0] + parts.last[0]).toUpperCase();
  }

  factory AppUser.fromMap(String uid, Map<String, dynamic> m) => AppUser(
        uid: uid,
        name: (m['name'] ?? '') as String,
        email: (m['email'] ?? '') as String,
        role: (m['role'] ?? 'student') as String,
      );
}
