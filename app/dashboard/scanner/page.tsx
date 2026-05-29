"use client"

import { useEffect, useState } from "react"
import { apiClient } from "@/lib/api-client"
import { Skeleton } from "@/components/ui/skeleton"
import ClientScannerWrapper from "@/components/scanner/client-scanner-wrapper"
import type { Student, Exam, Subject } from "@/lib/types"

interface ExamWithSubject extends Exam {
  subject?: Subject
}

export default function ScannerPage() {
  const [students, setStudents] = useState<Student[]>([])
  const [exams, setExams] = useState<ExamWithSubject[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    Promise.all([
      apiClient<{ items: Student[] }>("/students/"),
      apiClient<{ items: ExamWithSubject[] }>("/exams/"),
    ])
      .then(([s, e]) => {
        setStudents(s.items)
        setExams(e.items)
      })
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Test Paper Scanner</h1>
        <p className="text-muted-foreground">
          Scan test papers to detect check marks and automatically calculate scores
        </p>
      </div>

      {loading ? (
        <div className="grid gap-6 lg:grid-cols-2">
          <Skeleton className="h-[500px]" />
          <Skeleton className="h-[500px]" />
        </div>
      ) : (
        <ClientScannerWrapper students={students} exams={exams} />
      )}
    </div>
  )
}