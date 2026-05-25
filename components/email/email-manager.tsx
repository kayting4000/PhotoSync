'use client'

import { useState, useMemo } from "react"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { Checkbox } from "@/components/ui/checkbox"
import { Badge } from "@/components/ui/badge"
import { Mail, Send, CheckCircle, AlertCircle, Users } from "lucide-react"
import type { Student, Subject, ExamResult, Exam } from "@/lib/types"
import { calculateGrade } from "@/lib/types"
import { Label } from "@/components/ui/label"
import { Textarea } from "@/components/ui/textarea"
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"

interface EmailManagerProps {
  students: Student[]
  results: (ExamResult & { student: Student; exam: Exam & { subject: Subject } })[]
  subjects: Subject[]
}

interface EmailStatus {
  studentId: string
  status: 'pending' | 'sending' | 'sent' | 'error'
  message?: string
}

export function EmailManager({ students, results, subjects }: EmailManagerProps) {
  const [selectedSubject, setSelectedSubject] = useState<string>("")
  const [selectedStudents, setSelectedStudents] = useState<string[]>([])
  const [customMessage, setCustomMessage] = useState("")
  const [emailStatuses, setEmailStatuses] = useState<EmailStatus[]>([])
  const [isSending, setIsSending] = useState(false)

  // Get students with results for selected subject
  const studentsWithResults = useMemo(() => {
    if (!selectedSubject) return []
    
    const studentResultsMap = new Map<string, {
      student: Student
      results: (ExamResult & { exam: Exam & { subject: Subject } })[]
      avgPercentage: number
      grade: string
    }>()

    for (const result of results) {
      if (result.exam.subject_id !== selectedSubject) continue
      if (!result.student?.email) continue

      const existing = studentResultsMap.get(result.student_id)
      if (existing) {
        existing.results.push(result)
        const totalPercentage = existing.results.reduce((sum, r) => sum + (r.percentage ?? 0), 0)
        existing.avgPercentage = totalPercentage / existing.results.length
        existing.grade = calculateGrade(existing.avgPercentage).grade
      } else {
        studentResultsMap.set(result.student_id, {
          student: result.student,
          results: [result],
          avgPercentage: result.percentage ?? 0,
          grade: calculateGrade(result.percentage ?? 0).grade,
        })
      }
    }

    return Array.from(studentResultsMap.values())
  }, [selectedSubject, results])

  const handleSelectAll = (checked: boolean) => {
    if (checked) {
      setSelectedStudents(studentsWithResults.map(s => s.student.id))
    } else {
      setSelectedStudents([])
    }
  }

  const handleSelectStudent = (studentId: string, checked: boolean) => {
    if (checked) {
      setSelectedStudents([...selectedStudents, studentId])
    } else {
      setSelectedStudents(selectedStudents.filter(id => id !== studentId))
    }
  }

  const handleSendEmails = async () => {
    if (selectedStudents.length === 0) return

    setIsSending(true)
    setEmailStatuses(selectedStudents.map(id => ({
      studentId: id,
      status: 'pending'
    })))

    const selectedSubjectData = subjects.find(s => s.id === selectedSubject)

    for (const studentId of selectedStudents) {
      setEmailStatuses(prev => prev.map(s => 
        s.studentId === studentId ? { ...s, status: 'sending' } : s
      ))

      const studentData = studentsWithResults.find(s => s.student.id === studentId)
      if (!studentData) continue

      try {
        const response = await fetch('/api/email/send', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            to: studentData.student.email,
            studentName: `${studentData.student.first_name} ${studentData.student.last_name}`,
            subjectCode: selectedSubjectData?.code,
            subjectName: selectedSubjectData?.name,
            results: studentData.results.map(r => ({
              examName: r.exam.name,
              score: r.total_score,
              maxScore: r.exam.total_items * r.exam.points_per_item,
              percentage: r.percentage,
              grade: r.grade,
              remarks: r.remarks,
            })),
            averagePercentage: studentData.avgPercentage,
            finalGrade: studentData.grade,
            customMessage,
          }),
        })

        if (!response.ok) throw new Error('Failed to send email')
        
        const data = await response.json()
        
        // Check for email service configuration error
        if (!data.success) {
          throw new Error(data.message || 'Failed to send email')
        }

        setEmailStatuses(prev => prev.map(s => 
          s.studentId === studentId ? { ...s, status: 'sent' } : s
        ))
      } catch (error) {
        const errorMessage = error instanceof Error ? error.message : 'Failed to send'
        setEmailStatuses(prev => prev.map(s => 
          s.studentId === studentId ? { ...s, status: 'error', message: errorMessage } : s
        ))
      }

      // Small delay between emails
      await new Promise(resolve => setTimeout(resolve, 500))
    }

    setIsSending(false)
  }

  const sentCount = emailStatuses.filter(s => s.status === 'sent').length
  const errorCount = emailStatuses.filter(s => s.status === 'error').length

  return (
    <div className="grid gap-6 lg:grid-cols-3">
      <div className="lg:col-span-2">
        <Card>
          <CardHeader>
            <CardTitle>Select Recipients</CardTitle>
            <CardDescription>
              Choose students to send their grade reports
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid gap-2">
              <Label>Filter by Subject</Label>
              <Select value={selectedSubject} onValueChange={(v) => {
                setSelectedSubject(v)
                setSelectedStudents([])
                setEmailStatuses([])
              }}>
                <SelectTrigger>
                  <SelectValue placeholder="Select a subject" />
                </SelectTrigger>
                <SelectContent>
                  {subjects.map((subject) => (
                    <SelectItem key={subject.id} value={subject.id}>
                      {subject.code} - {subject.name}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            {selectedSubject && studentsWithResults.length === 0 ? (
              <Alert>
                <AlertCircle className="h-4 w-4" />
                <AlertTitle>No eligible students</AlertTitle>
                <AlertDescription>
                  No students with email addresses have results for this subject.
                </AlertDescription>
              </Alert>
            ) : selectedSubject ? (
              <div className="space-y-4">
                <div className="flex items-center justify-between">
                  <div className="flex items-center space-x-2">
                    <Checkbox
                      id="select-all"
                      checked={selectedStudents.length === studentsWithResults.length}
                      onCheckedChange={handleSelectAll}
                    />
                    <label htmlFor="select-all" className="text-sm font-medium">
                      Select All ({studentsWithResults.length} students)
                    </label>
                  </div>
                  <Badge variant="outline">
                    {selectedStudents.length} selected
                  </Badge>
                </div>

                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead className="w-[50px]"></TableHead>
                      <TableHead>Student</TableHead>
                      <TableHead>Email</TableHead>
                      <TableHead>Exams</TableHead>
                      <TableHead>Average</TableHead>
                      <TableHead>Grade</TableHead>
                      <TableHead>Status</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {studentsWithResults.map((data) => {
                      const status = emailStatuses.find(s => s.studentId === data.student.id)
                      return (
                        <TableRow key={data.student.id}>
                          <TableCell>
                            <Checkbox
                              checked={selectedStudents.includes(data.student.id)}
                              onCheckedChange={(checked) => 
                                handleSelectStudent(data.student.id, checked as boolean)
                              }
                              disabled={isSending}
                            />
                          </TableCell>
                          <TableCell className="font-medium">
                            {data.student.first_name} {data.student.last_name}
                          </TableCell>
                          <TableCell className="text-sm text-muted-foreground">
                            {data.student.email}
                          </TableCell>
                          <TableCell>{data.results.length}</TableCell>
                          <TableCell>{data.avgPercentage.toFixed(1)}%</TableCell>
                          <TableCell>
                            <Badge variant="outline">{data.grade}</Badge>
                          </TableCell>
                          <TableCell>
                            {status?.status === 'sent' && (
                              <Badge className="bg-emerald-100 text-emerald-800">
                                <CheckCircle className="mr-1 h-3 w-3" />
                                Sent
                              </Badge>
                            )}
                            {status?.status === 'sending' && (
                              <Badge variant="secondary">Sending...</Badge>
                            )}
                            {status?.status === 'error' && (
                              <Badge variant="destructive">
                                <AlertCircle className="mr-1 h-3 w-3" />
                                Error
                              </Badge>
                            )}
                          </TableCell>
                        </TableRow>
                      )
                    })}
                  </TableBody>
                </Table>
              </div>
            ) : (
              <div className="flex flex-col items-center justify-center py-10 text-center">
                <Users className="h-10 w-10 text-muted-foreground mb-4" />
                <p className="text-muted-foreground">Select a subject to view students</p>
              </div>
            )}
          </CardContent>
        </Card>
      </div>

      <div className="space-y-6">
        <Card>
          <CardHeader>
            <CardTitle>Email Settings</CardTitle>
            <CardDescription>
              Customize the email message
            </CardDescription>
          </CardHeader>
          <CardContent className="space-y-4">
            <div className="grid gap-2">
              <Label>Custom Message (optional)</Label>
              <Textarea
                placeholder="Add a personal message to include in the email..."
                value={customMessage}
                onChange={(e) => setCustomMessage(e.target.value)}
                rows={4}
              />
            </div>

            <Button
              onClick={handleSendEmails}
              disabled={selectedStudents.length === 0 || isSending}
              className="w-full"
            >
              <Send className="mr-2 h-4 w-4" />
              {isSending 
                ? `Sending... (${sentCount}/${selectedStudents.length})`
                : `Send to ${selectedStudents.length} Student${selectedStudents.length !== 1 ? 's' : ''}`
              }
            </Button>

            {emailStatuses.length > 0 && !isSending && (
              <div className="space-y-2">
                {sentCount > 0 && (
                  <Alert>
                    <CheckCircle className="h-4 w-4" />
                    <AlertTitle>Emails Sent</AlertTitle>
                    <AlertDescription>
                      Successfully sent {sentCount} email{sentCount !== 1 ? 's' : ''}.
                    </AlertDescription>
                  </Alert>
                )}
                {errorCount > 0 && (
                  <Alert variant="destructive">
                    <AlertCircle className="h-4 w-4" />
                    <AlertTitle>Errors</AlertTitle>
                    <AlertDescription>
                      {emailStatuses.find(s => s.status === 'error')?.message || `Failed to send ${errorCount} email${errorCount !== 1 ? 's' : ''}.`}
                    </AlertDescription>
                  </Alert>
                )}
              </div>
            )}
          </CardContent>
        </Card>

        <Card>
          <CardHeader>
            <CardTitle>Email Preview</CardTitle>
            <CardDescription>
              What students will receive
            </CardDescription>
          </CardHeader>
          <CardContent>
            <div className="rounded-lg border bg-muted/30 p-4 space-y-3 text-sm">
              <div className="flex items-center gap-2">
                <Mail className="h-4 w-4 text-primary" />
                <span className="font-medium">Grade Report - [Subject Name]</span>
              </div>
              <div className="space-y-2 text-muted-foreground">
                <p>Dear [Student Name],</p>
                <p>Here are your exam results for [Subject]:</p>
                <ul className="list-disc list-inside space-y-1">
                  <li>Quiz 1: 85% (B+)</li>
                  <li>Midterm: 78% (C+)</li>
                </ul>
                <p><strong>Average:</strong> 81.5%</p>
                <p><strong>Grade:</strong> B-</p>
                {customMessage && (
                  <p className="pt-2 border-t">{customMessage}</p>
                )}
              </div>
            </div>
          </CardContent>
        </Card>
      </div>
    </div>
  )
}
