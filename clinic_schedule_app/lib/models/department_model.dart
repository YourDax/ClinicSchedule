class DepartmentModel {
  final int id;
  final String name;

  DepartmentModel({required this.id, required this.name});
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is DepartmentModel &&
              runtimeType == other.runtimeType &&
              id == other.id;
  @override
  int get hashCode => id.hashCode;
  factory DepartmentModel.fromJson(Map<String, dynamic> json) {
    return DepartmentModel(
      id: json['id'],
      name: json['name'],
    );
  }
}
