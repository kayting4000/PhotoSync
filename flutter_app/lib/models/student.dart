class Student {
  final String? id;
  final String studentId;
  final String firstName;
  final String lastName;
  final String? email;
  final String course;
  final int yearLevel;
  final String? sectionId;
  final DateTime? createdAt;

  Student({
    this.id,
    required this.studentId,
    required this.firstName,
    required this.lastName,
    this.email,
    required this.course,
    this.yearLevel = 1,
    this.sectionId,
    this.createdAt,
  });

  factory Student.fromJson(Map<String, dynamic> json) {
    return Student(
      id: json['id'],
      studentId: json['student_id'],
      firstName: json['first_name'],
      lastName: json['last_name'],
      email: json['email'],
      course: json['course'],
      yearLevel: json['year_level'] ?? 1,
      sectionId: json['section_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson({String? userId}) {
    return {
      if (userId != null) 'user_id': userId,
      'student_id': studentId,
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'course': course,
      'year_level': yearLevel,
      if (sectionId != null) 'section_id': sectionId,
    };
  }

  String get fullName => '$firstName $lastName';
}
