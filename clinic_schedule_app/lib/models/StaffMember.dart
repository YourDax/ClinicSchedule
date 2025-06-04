class StaffMember {
  final String fullName;
  final String role; // 'Доктор' или 'Медсестра'

  StaffMember({
    required this.fullName,
    required this.role,
  });

  factory StaffMember.fromJson(Map<String, dynamic> json) {
    return StaffMember(
      fullName: json['fullName'],
      role: json['role'],
    );
  }
}