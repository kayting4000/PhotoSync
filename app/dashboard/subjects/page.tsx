"use client"

import { useEffect, useState } from "react"
import { apiClient } from "@/lib/api-client"
import { SubjectsManager } from "@/components/subjects/subjects-manager"
import type { Subject, Exam } from "@/lib/types"

interface ExamWithSubject extends Exam {
  subject?: Subject
}

export default function SubjectsPage() {
  const [subjects, setSubjects] = useState<Subject[]>([])
  const [exams, setExams] = useState<ExamWithSubject[]>([])
  const [loading, setLoading] = useState(true)

  const fetchData = async () => {
    setLoading(true)
    try {
      const [subRes, exRes] = await Promise.all([
        apiClient<{ items: Subject[] }>("/subjects/"),
        apiClient<{ items: Exam[] }>("/exams/"),
      ])

      const subjectMap = new Map(subRes.items.map((s) => [s.id, s]))
      const examsWithSubject = exRes.items.map((e) => ({
        ...e,
        subject: subjectMap.get(e.subject_id),
      }))

      setSubjects(subRes.items)
      setExams(examsWithSubject)
    } catch {
      // ignore
    } finally {
      setLoading(false)
    }
  }

  useEffect(() => {
    fetchData()
  }, [])

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Subjects & Exams</h1>
        <p className="text-muted-foreground">
          Manage subjects and create exams with configurable scoring
        </p>
      </div>

      {loading ? (
        <p className="text-muted-foreground">Loading…</p>
      ) : (
        <SubjectsManager subjects={subjects} exams={exams} onRefresh={fetchData} />
      )}
    </div>
  )
}