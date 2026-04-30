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
import { Tabs, TabsContent, TabsList, TabsTrigger } from "@/components/ui/tabs"
import { Badge } from "@/components/ui/badge"
import { Calculator, FileText, TrendingUp } from "lucide-react"
import type { Student, Subject, ExamResult, Exam } from "@/lib/types"
import { calculateGrade, GRADE_SCALE } from "@/lib/types"
import { Label } from "@/components/ui/label"

interface GradesManagerProps {
  students: Student[]
  results: (ExamResult & { student: Student; exam: Exam & { subject: Subject } })[]
  subjects: Subject[]
}

export function GradesManager({ students, results, subjects }: GradesManagerProps) {
  const [selectedStudent, setSelectedStudent] = useState<string>("")
  const [selectedSubject, setSelectedSubject] = useState<string>("")

  // Calculate GPA for selected student
  const studentGPA = useMemo(() => {
    if (!selectedStudent) return null
    
    const studentResults = results.filter(r => r.student_id === selectedStudent)
    if (studentResults.length === 0) return null

    // Group results by subject
    const subjectGrades: Record<string, { percentages: number[]; units: number }> = {}
    
    for (const result of studentResults) {
      const subjectId = result.exam.subject_id
      const units = result.exam.subject?.units ?? 3
      
      if (!subjectGrades[subjectId]) {
        subjectGrades[subjectId] = { percentages: [], units }
      }
      subjectGrades[subjectId].percentages.push(result.percentage ?? 0)
    }

    // Calculate weighted GPA
    let totalWeightedPoints = 0
    let totalUnits = 0
    const subjectBreakdown: { code: string; name: string; avgPercentage: number; grade: string; equivalent: number; units: number }[] = []

    for (const [subjectId, data] of Object.entries(subjectGrades)) {
      const subject = subjects.find(s => s.id === subjectId)
      const avgPercentage = data.percentages.reduce((a, b) => a + b, 0) / data.percentages.length
      const gradeResult = calculateGrade(avgPercentage)
      
      totalWeightedPoints += gradeResult.equivalent * data.units
      totalUnits += data.units

      subjectBreakdown.push({
        code: subject?.code ?? "Unknown",
        name: subject?.name ?? "Unknown",
        avgPercentage,
        grade: gradeResult.grade,
        equivalent: gradeResult.equivalent,
        units: data.units,
      })
    }

    const gpa = totalUnits > 0 ? totalWeightedPoints / totalUnits : 0

    return {
      gpa: Math.round(gpa * 100) / 100,
      totalUnits,
      subjectBreakdown,
      totalExams: studentResults.length,
    }
  }, [selectedStudent, results, subjects])

  // Filter results by subject
  const filteredResults = useMemo(() => {
    return results.filter(r => {
      if (selectedSubject && r.exam.subject_id !== selectedSubject) return false
      return true
    })
  }, [results, selectedSubject])

  const selectedStudentData = students.find(s => s.id === selectedStudent)

  return (
    <Tabs defaultValue="results" className="space-y-4">
      <TabsList>
        <TabsTrigger value="results">
          <FileText className="mr-2 h-4 w-4" />
          All Results
        </TabsTrigger>
        <TabsTrigger value="gpa">
          <Calculator className="mr-2 h-4 w-4" />
          GPA Calculator
        </TabsTrigger>
        <TabsTrigger value="scale">
          <TrendingUp className="mr-2 h-4 w-4" />
          Grading Scale
        </TabsTrigger>
      </TabsList>

      <TabsContent value="results">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle>Exam Results</CardTitle>
              <CardDescription>All recorded exam results</CardDescription>
            </div>
            <div className="w-48">
              <Select value={selectedSubject} onValueChange={setSelectedSubject}>
                <SelectTrigger>
                  <SelectValue placeholder="Filter by subject" />
                </SelectTrigger>
                <SelectContent>
                  <SelectItem value="all">All Subjects</SelectItem>
                  {subjects.map((subject) => (
                    <SelectItem key={subject.id} value={subject.id}>
                      {subject.code}
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>
          </CardHeader>
          <CardContent>
            {filteredResults.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-10 text-center">
                <p className="text-muted-foreground mb-2">No results yet</p>
                <p className="text-sm text-muted-foreground">
                  Scan test papers to record exam results
                </p>
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Student</TableHead>
                    <TableHead>Subject</TableHead>
                    <TableHead>Exam</TableHead>
                    <TableHead>Score</TableHead>
                    <TableHead>Percentage</TableHead>
                    <TableHead>Grade</TableHead>
                    <TableHead>Status</TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {filteredResults.map((result) => (
                    <TableRow key={result.id}>
                      <TableCell className="font-medium">
                        {result.student?.first_name} {result.student?.last_name}
                      </TableCell>
                      <TableCell>{result.exam?.subject?.code}</TableCell>
                      <TableCell>{result.exam?.name}</TableCell>
                      <TableCell>
                        {result.total_score} / {result.exam?.total_items * result.exam?.points_per_item}
                      </TableCell>
                      <TableCell>{result.percentage?.toFixed(1)}%</TableCell>
                      <TableCell>
                        <Badge variant="outline">{result.grade}</Badge>
                      </TableCell>
                      <TableCell>
                        <Badge variant={result.remarks === "Passed" ? "default" : "destructive"}>
                          {result.remarks}
                        </Badge>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </CardContent>
        </Card>
      </TabsContent>

      <TabsContent value="gpa">
        <div className="grid gap-6 lg:grid-cols-2">
          <Card>
            <CardHeader>
              <CardTitle>GPA Calculator</CardTitle>
              <CardDescription>
                Calculate GPA based on exam results
              </CardDescription>
            </CardHeader>
            <CardContent className="space-y-4">
              <div className="grid gap-2">
                <Label>Select Student</Label>
                <Select value={selectedStudent} onValueChange={setSelectedStudent}>
                  <SelectTrigger>
                    <SelectValue placeholder="Choose a student" />
                  </SelectTrigger>
                  <SelectContent>
                    {students.map((student) => (
                      <SelectItem key={student.id} value={student.id}>
                        {student.student_id} - {student.first_name} {student.last_name}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>

              {selectedStudentData && studentGPA && (
                <div className="space-y-4 pt-4 border-t">
                  <div className="text-center">
                    <p className="text-sm text-muted-foreground">
                      {selectedStudentData.first_name} {selectedStudentData.last_name}
                    </p>
                    <p className="text-xs text-muted-foreground">
                      {selectedStudentData.course} - Year {selectedStudentData.year_level}
                    </p>
                  </div>

                  <div className="flex items-center justify-center">
                    <div className="text-center">
                      <p className="text-5xl font-bold text-primary">
                        {studentGPA.gpa.toFixed(2)}
                      </p>
                      <p className="text-sm text-muted-foreground mt-1">
                        General Weighted Average
                      </p>
                    </div>
                  </div>

                  <div className="grid grid-cols-2 gap-4 text-center">
                    <div>
                      <p className="text-2xl font-semibold">{studentGPA.totalExams}</p>
                      <p className="text-sm text-muted-foreground">Exams Taken</p>
                    </div>
                    <div>
                      <p className="text-2xl font-semibold">{studentGPA.totalUnits}</p>
                      <p className="text-sm text-muted-foreground">Total Units</p>
                    </div>
                  </div>
                </div>
              )}

              {selectedStudent && !studentGPA && (
                <div className="flex flex-col items-center justify-center py-6 text-center">
                  <p className="text-muted-foreground">No exam results found</p>
                  <p className="text-sm text-muted-foreground mt-1">
                    This student has no recorded exam results yet
                  </p>
                </div>
              )}
            </CardContent>
          </Card>

          <Card>
            <CardHeader>
              <CardTitle>Subject Breakdown</CardTitle>
              <CardDescription>
                Performance by subject
              </CardDescription>
            </CardHeader>
            <CardContent>
              {studentGPA && studentGPA.subjectBreakdown.length > 0 ? (
                <Table>
                  <TableHeader>
                    <TableRow>
                      <TableHead>Subject</TableHead>
                      <TableHead>Average</TableHead>
                      <TableHead>Grade</TableHead>
                      <TableHead>Units</TableHead>
                    </TableRow>
                  </TableHeader>
                  <TableBody>
                    {studentGPA.subjectBreakdown.map((subject) => (
                      <TableRow key={subject.code}>
                        <TableCell>
                          <div>
                            <p className="font-medium">{subject.code}</p>
                            <p className="text-xs text-muted-foreground">{subject.name}</p>
                          </div>
                        </TableCell>
                        <TableCell>{subject.avgPercentage.toFixed(1)}%</TableCell>
                        <TableCell>
                          <Badge variant="outline">
                            {subject.grade} ({subject.equivalent.toFixed(2)})
                          </Badge>
                        </TableCell>
                        <TableCell>{subject.units}</TableCell>
                      </TableRow>
                    ))}
                  </TableBody>
                </Table>
              ) : (
                <div className="flex flex-col items-center justify-center py-10 text-center">
                  <Calculator className="h-10 w-10 text-muted-foreground mb-4" />
                  <p className="text-muted-foreground">No data to display</p>
                  <p className="text-sm text-muted-foreground mt-1">
                    Select a student with exam results
                  </p>
                </div>
              )}
            </CardContent>
          </Card>
        </div>
      </TabsContent>

      <TabsContent value="scale">
        <Card>
          <CardHeader>
            <CardTitle>Grading Scale</CardTitle>
            <CardDescription>
              Reference for grade calculations
            </CardDescription>
          </CardHeader>
          <CardContent>
            <Table>
              <TableHeader>
                <TableRow>
                  <TableHead>Percentage Range</TableHead>
                  <TableHead>Letter Grade</TableHead>
                  <TableHead>Grade Point</TableHead>
                  <TableHead>Description</TableHead>
                </TableRow>
              </TableHeader>
              <TableBody>
                {GRADE_SCALE.map((scale) => (
                  <TableRow key={scale.grade}>
                    <TableCell>
                      {scale.minPercentage}% - {scale.maxPercentage}%
                    </TableCell>
                    <TableCell>
                      <Badge variant="outline">{scale.grade}</Badge>
                    </TableCell>
                    <TableCell>{scale.equivalent.toFixed(2)}</TableCell>
                    <TableCell>
                      {scale.equivalent <= 1.5 ? "Excellent" :
                       scale.equivalent <= 2.0 ? "Very Good" :
                       scale.equivalent <= 2.5 ? "Good" :
                       scale.equivalent <= 3.0 ? "Satisfactory" : "Failing"}
                    </TableCell>
                  </TableRow>
                ))}
              </TableBody>
            </Table>
          </CardContent>
        </Card>
      </TabsContent>
    </Tabs>
  )
}
