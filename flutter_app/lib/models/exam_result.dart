class ExamResult {
  final String? id;
  final String studentId;
  final String examId;
  final int correctAnswers;
  final double totalScore;
  final double? percentage;
  final String? grade;
  final String? remarks;
  final String? scannedImageUrl;
  final DateTime? createdAt;

  ExamResult({
    this.id,
    required this.studentId,
    required this.examId,
    required this.correctAnswers,
    required this.totalScore,
    this.percentage,
    this.grade,
    this.remarks,
    this.scannedImageUrl,
    this.createdAt,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) {
    return ExamResult(
      id: json['id'],
      studentId: json['student_id'],
      examId: json['exam_id'],
      correctAnswers: json['correct_answers'],
      totalScore: (json['total_score'] ?? 0.0).toDouble(),
      percentage: json['percentage']?.toDouble(),
      grade: json['grade'],
      remarks: json['remarks'],
      scannedImageUrl: json['scanned_image_url'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson({String? userId}) => {
        if (userId != null) 'user_id': userId,
        'student_id': studentId,
        'exam_id': examId,
        'correct_answers': correctAnswers,
        'total_score': totalScore,
        'percentage': percentage,
        'grade': grade,
        'remarks': remarks,
        'scanned_image_url': scannedImageUrl,
      };
}
