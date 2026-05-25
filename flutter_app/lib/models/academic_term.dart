class AcademicTerm {
  final String? id;
  final String name;
  final String termType;  // "preliminary", "mid-semester", "final"
  final int percentageWeight;  // 10-90%
  final DateTime startDate;
  final DateTime endDate;
  final bool isCurrent;
  final DateTime? createdAt;

  AcademicTerm({
    this.id,
    required this.name,
    required this.termType,
    this.percentageWeight = 33,
    required this.startDate,
    required this.endDate,
    this.isCurrent = false,
    this.createdAt,
  });

  factory AcademicTerm.fromJson(Map<String, dynamic> json) {
    return AcademicTerm(
      id: json['id'],
      name: json['name'],
      termType: json['term_type'] ?? 'preliminary',
      percentageWeight: json['percentage_weight'] ?? 33,
      startDate: DateTime.parse(json['start_date']),
      endDate: DateTime.parse(json['end_date']),
      isCurrent: json['is_current'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson({String? userId}) {
    return {
      if (userId != null) 'user_id': userId,
      'name': name,
      'term_type': termType,
      'percentage_weight': percentageWeight,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'is_current': isCurrent,
    };
  }

  String get displayName {
    return '$name ($termType)';
  }

  AcademicTerm copyWith({
    String? id,
    String? name,
    String? termType,
    int? percentageWeight,
    DateTime? startDate,
    DateTime? endDate,
    bool? isCurrent,
    DateTime? createdAt,
  }) {
    return AcademicTerm(
      id: id ?? this.id,
      name: name ?? this.name,
      termType: termType ?? this.termType,
      percentageWeight: percentageWeight ?? this.percentageWeight,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isCurrent: isCurrent ?? this.isCurrent,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}