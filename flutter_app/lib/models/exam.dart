class Exam {
  final String? id;
  final String subjectId;
  final String name;
  final String examType;
  final int totalItems;
  final double pointsPerItem;
  final double? passingScore;
  final DateTime? createdAt;

  Exam({
    this.id,
    required this.subjectId,
    required this.name,
    required this.examType,
    required this.totalItems,
    this.pointsPerItem = 1.0,
    this.passingScore,
    this.createdAt,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      id: json['id'],
      subjectId: json['subject_id'],
      name: json['name'],
      examType: json['exam_type'],
      totalItems: json['total_items'],
      pointsPerItem: (json['points_per_item'] ?? 1.0).toDouble(),
      passingScore: json['passing_score']?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
        'subject_id': subjectId,
        'name': name,
        'exam_type': examType,
        'total_items': totalItems,
        'points_per_item': pointsPerItem,
        'passing_score': passingScore,
      };
}
