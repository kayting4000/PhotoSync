class Subject {
  final String? id;
  final String code;
  final String name;
  final int units;
  final DateTime? createdAt;

  Subject({
    this.id,
    required this.code,
    required this.name,
    this.units = 3,
    this.createdAt,
  });

  factory Subject.fromJson(Map<String, dynamic> json) {
    return Subject(
      id: json['id'],
      code: json['code'],
      name: json['name'],
      units: json['units'] ?? 3,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'code': code,
        'name': name,
        'units': units,
      };
}
