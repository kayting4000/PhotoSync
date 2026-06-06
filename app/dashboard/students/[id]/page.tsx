"use client"

import { useEffect, useState } from "react"
import { useParams, useRouter } from "next/navigation"
import { apiClient } from "@/lib/api-client"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardHeader, CardTitle, CardDescription } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"
import { ArrowLeft, BookOpen, Folder, GraduationCap } from "lucide-react"
import type { Student, Subject } from "@/lib/types"

interface StudentSubjectEntry {
  id: string
  subject_id: string
  section_id: string | null
  semester: string
  academic_year: string
  final_grade: number | null
  grade_equivalent: string | null
}

interface Section {
  id: string
  section_label: string
  subject_id: string | null
  room_number: string | null
}

export default function StudentFolderPage() {
  const { id } = useParams<{ id: string }>()
  const router = useRouter()

  const [student, setStudent] = useState<Student | null>(null)
  const [enrollments, setEnrollments] = useState<StudentSubjectEntry[]>([])
  const [subjectMap, setSubjectMap] = useState<Map<string, Subject>>(new Map())
  const [sectionMap, setSectionMap] = useState<Map<string, Section>>(new Map())
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    async function load() {
      try {
        const [studRes, enrollRes, subRes, secRes] = await Promise.all([
          apiClient<{ items: Student[] }>("/students/"),
          apiClient<{ items: StudentSubjectEntry[] }>(`/student-subjects/?student_id=${id}`),
          apiClient<{ items: Subject[] }>("/subjects/"),
          apiClient<{ items: Section[] }>("/sections/").catch(() => ({ items: [] as Section[] })),
        ])

        setStudent(studRes.items.find((s) => s.id === id) ?? null)
        setEnrollments(enrollRes.items)
        setSubjectMap(new Map(subRes.items.map((s) => [s.id, s])))
        setSectionMap(new Map(secRes.items.map((s) => [s.id, s])))
      } catch {
        // ignore
      } finally {
        setLoading(false)
      }
    }
    load()
  }, [id])

  if (loading) return <p className="text-muted-foreground p-6">Loading…</p>
  if (!student) return <p className="text-muted-foreground p-6">Student not found.</p>

  return (
    <div className="space-y-6">
      <div className="flex items-center gap-3">
        <Button variant="ghost" size="icon" onClick={() => router.push("/dashboard/students")}>
          <ArrowLeft className="h-4 w-4" />
        </Button>
        <div className="flex items-center gap-2">
          <Folder className="h-6 w-6 text-amber-500" />
          <div>
            <h1 className="text-2xl font-bold tracking-tight">
              {student.first_name} {student.last_name}
            </h1>
            <p className="text-sm text-muted-foreground">
              {student.student_id} · {student.course} · Year {student.year_level}
            </p>
          </div>
        </div>
      </div>

      {/* Student Info */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-base">
            <GraduationCap className="h-4 w-4" />
            Student Information
          </CardTitle>
        </CardHeader>
        <CardContent className="grid grid-cols-2 md:grid-cols-4 gap-4 text-sm">
          <div>
            <p className="text-muted-foreground">Student ID</p>
            <p className="font-medium">{student.student_id}</p>
          </div>
          <div>
            <p className="text-muted-foreground">Course</p>
            <p className="font-medium">{student.course}</p>
          </div>
          <div>
            <p className="text-muted-foreground">Year Level</p>
            <p className="font-medium">Year {student.year_level}</p>
          </div>
          <div>
            <p className="text-muted-foreground">Email</p>
            <p className="font-medium">{student.email ?? "—"}</p>
          </div>
        </CardContent>
      </Card>

      {/* Subjects Preview */}
      <Card>
        <CardHeader>
          <CardTitle className="flex items-center gap-2 text-base">
            <BookOpen className="h-4 w-4" />
            Subjects Preview
          </CardTitle>
          <CardDescription>
            {enrollments.length} subject{enrollments.length !== 1 ? "s" : ""} enrolled
          </CardDescription>
        </CardHeader>
        <CardContent>
          {enrollments.length === 0 ? (
            <div className="flex flex-col items-center justify-center py-10 text-center">
              <BookOpen className="h-8 w-8 text-muted-foreground mb-3" />
              <p className="text-muted-foreground">No subjects enrolled yet</p>
              <p className="text-sm text-muted-foreground mt-1">
                Enroll this student in subjects via the Subjects page
              </p>
            </div>
          ) : (
            <div className="grid gap-3 sm:grid-cols-2 lg:grid-cols-3">
              {enrollments.map((entry) => {
                const subject = subjectMap.get(entry.subject_id)
                const section = entry.section_id ? sectionMap.get(entry.section_id) : null
                return (
                  <div
                    key={entry.id}
                    className="rounded-xl border p-4 space-y-2 hover:bg-muted/40 transition-colors"
                  >
                    <div className="flex items-start justify-between gap-2">
                      <div>
                        <p className="font-semibold text-sm">
                          {subject?.code ?? "Unknown"}
                        </p>
                        <p className="text-xs text-muted-foreground line-clamp-1">
                          {subject?.name ?? "—"}
                        </p>
                      </div>
                      {subject && (
                        <Badge variant="secondary" className="text-xs shrink-0">
                          {subject.units} units
                        </Badge>
                      )}
                    </div>

                    <div className="flex flex-wrap gap-1">
                      {section && (
                        <Badge variant="outline" className="text-xs">
                          Sec: {section.section_label}
                          {section.room_number ? ` · ${section.room_number}` : ""}
                        </Badge>
                      )}
                      <Badge variant="outline" className="text-xs">
                        {entry.semester}
                      </Badge>
                      <Badge variant="outline" className="text-xs">
                        {entry.academic_year}
                      </Badge>
                    </div>

                    {entry.final_grade != null && (
                      <p className="text-xs font-medium text-primary">
                        Final Grade: {entry.final_grade}
                        {entry.grade_equivalent ? ` (${entry.grade_equivalent})` : ""}
                      </p>
                    )}
                  </div>
                )
              })}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  )
}
