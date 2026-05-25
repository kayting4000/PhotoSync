class Exam {
  final String? id;
  final String subjectId;
  final String name;
  final String componentType;  // "exam", "quiz", "assignment", "oral"
  final int totalItems;
  final double pointsPerItem;
  final double? passingScore;
  final String? termId;
  final DateTime? createdAt;

  Exam({
    this.id,
    required this.subjectId,
    required this.name,
    required this.componentType,
    required this.totalItems,
    this.pointsPerItem = 1.0,
    this.passingScore,
    this.termId,
    this.createdAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      subjectId: json['subject_id'],
      name: json['name'],
      componentType: json['component_type'] ?? 'exam',
      totalItems: json['total_items'],
      pointsPerItem: (json['points_per_item'] ?? 1.0).toDouble(),
      passingScore: json['passing_score']?.toDouble(),
      termId: json['term_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson({String? userId}) => {
        if (userId != null) 'user_id': userId,
        'subject_id': subjectId,
        'name': name,
        'component_type': componentType,
        'total_items': totalItems,
        'points_per_item': pointsPerItem,
        'passing_score': passingScore,
        if (termId != null) 'term_id': termId,
      };

  Exam copyWith({
    String? id,
    String? subjectId,
    String? name,
    String? componentType,
    int? totalItems,
    double? pointsPerItem,
    double? passingScore,
    String? termId,
    DateTime? createdAt,
  }) {
    return Exam(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      name: name ?? this.name,
      componentType: componentType ?? this.componentType,
      totalItems: totalItems ?? this.totalItems,
      pointsPerItem: pointsPerItem ?? this.pointsPerItem,
      passingScore: passingScore ?? this.passingScore,
      termId: termId ?? this.termId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
