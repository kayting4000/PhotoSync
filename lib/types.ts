export interface Student {
  id: string
  student_id: string
  first_name: string
  last_name: string
  email: string | null
  course: string
  year_level: number
  created_at: string
  updated_at: string
}

export interface Subject {
  id: string
  code: string
  name: string
  units: number
  created_at: string
}

export interface Exam {
  id: string
  subject_id: string
  name: string
  exam_type: 'quiz' | 'midterm' | 'final' | 'assignment'
  total_items: number
  points_per_item: number
  passing_score: number | null
  created_at: string
  subject?: Subject
}

export interface ExamResult {
  id: string
  student_id: string
  exam_id: string
  correct_answers: number
  total_score: number
  percentage: number | null
  grade: string | null
  remarks: string | null
  scanned_image_url: string | null
  created_at: string
  student?: Student
  exam?: Exam
}

export interface StudentSubject {
  id: string
  student_id: string
  subject_id: string
  semester: string
  academic_year: string
  final_grade: number | null
  grade_equivalent: string | null
  created_at: string
  student?: Student
  subject?: Subject
}

export interface ScoringRule {
  id: string
  exam_id: string
  section_name: string | null
  item_start: number
  item_end: number
  points_per_item: number
  created_at: string
}

export interface GradeEquivalent {
  minPercentage: number
  maxPercentage: number
  grade: string
  equivalent: number
}

export const GRADE_SCALE: GradeEquivalent[] = [
  { minPercentage: 97, maxPercentage: 100, grade: 'A+', equivalent: 1.0 },
  { minPercentage: 93, maxPercentage: 96.99, grade: 'A', equivalent: 1.25 },
  { minPercentage: 90, maxPercentage: 92.99, grade: 'A-', equivalent: 1.5 },
  { minPercentage: 87, maxPercentage: 89.99, grade: 'B+', equivalent: 1.75 },
  { minPercentage: 83, maxPercentage: 86.99, grade: 'B', equivalent: 2.0 },
  { minPercentage: 80, maxPercentage: 82.99, grade: 'B-', equivalent: 2.25 },
  { minPercentage: 77, maxPercentage: 79.99, grade: 'C+', equivalent: 2.5 },
  { minPercentage: 73, maxPercentage: 76.99, grade: 'C', equivalent: 2.75 },
  { minPercentage: 70, maxPercentage: 72.99, grade: 'C-', equivalent: 3.0 },
  { minPercentage: 0, maxPercentage: 69.99, grade: 'F', equivalent: 5.0 },
]

export function calculateGrade(percentage: number): { grade: string; equivalent: number } {
  for (const scale of GRADE_SCALE) {
    if (percentage >= scale.minPercentage && percentage <= scale.maxPercentage) {
      return { grade: scale.grade, equivalent: scale.equivalent }
    }
  }
  return { grade: 'F', equivalent: 5.0 }
}

export function calculateGPA(grades: number[]): number {
  if (grades.length === 0) return 0
  const sum = grades.reduce((acc, grade) => acc + grade, 0)
  return Math.round((sum / grades.length) * 100) / 100
}
