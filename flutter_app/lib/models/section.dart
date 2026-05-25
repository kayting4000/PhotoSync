class Section {
  final String? id;
  final String subjectId;
  final String sectionLabel;  // A, B, C, D, E
  final String roomNumber;    // Room 101, Lab A, etc.
  final DateTime? createdAt;

  Section({
    this.id,
    required this.subjectId,
    required this.sectionLabel,
    required this.roomNumber,
    this.createdAt,
  });

  factory Section.fromJson(Map<String, dynamic> json) {
    return Section(
      id: json['id'],
      subjectId: json['subject_id'] ?? '',
      sectionLabel: json['section_label'] ?? 'A',
      roomNumber: json['room_number'] ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson({String? userId}) {
    return {
      if (userId != null) 'user_id': userId,
      'subject_id': subjectId,
      'section_label': sectionLabel,
      'room_number': roomNumber,
    };
  }

  String get displayName {
    return 'Section $sectionLabel (Room $roomNumber)';
  }

  Section copyWith({
    String? id,
    String? subjectId,
    String? sectionLabel,
    String? roomNumber,
    DateTime? createdAt,
  }) {
    return Section(
      id: id ?? this.id,
      subjectId: subjectId ?? this.subjectId,
      sectionLabel: sectionLabel ?? this.sectionLabel,
      roomNumber: roomNumber ?? this.roomNumber,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}