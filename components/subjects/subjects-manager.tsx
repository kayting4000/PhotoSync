'use client'

import { useState } from "react"
import { createClient } from "@/lib/supabase/client"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
  DialogTrigger,
} from "@/components/ui/dialog"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
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
import { Plus, Trash2 } from "lucide-react"
import type { Subject, Exam } from "@/lib/types"
import { useRouter } from "next/navigation"
import {
  AlertDialog,
  AlertDialogAction,
  AlertDialogCancel,
  AlertDialogContent,
  AlertDialogDescription,
  AlertDialogFooter,
  AlertDialogHeader,
  AlertDialogTitle,
} from "@/components/ui/alert-dialog"

interface SubjectsManagerProps {
  subjects: Subject[]
  exams: (Exam & { subject: Subject })[]
}

export function SubjectsManager({ subjects, exams }: SubjectsManagerProps) {
  const [subjectDialogOpen, setSubjectDialogOpen] = useState(false)
  const [examDialogOpen, setExamDialogOpen] = useState(false)
  const [deleteSubjectId, setDeleteSubjectId] = useState<string | null>(null)
  const [deleteExamId, setDeleteExamId] = useState<string | null>(null)
  const [isLoading, setIsLoading] = useState(false)
  const router = useRouter()

  const handleAddSubject = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setIsLoading(true)
    const formData = new FormData(e.currentTarget)
    const data = {
      code: formData.get("code") as string,
      name: formData.get("name") as string,
      units: parseInt(formData.get("units") as string),
    }

    try {
      const supabase = createClient()
      await supabase.from("subjects").insert(data)
      setSubjectDialogOpen(false)
      router.refresh()
    } finally {
      setIsLoading(false)
    }
  }

  const handleAddExam = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setIsLoading(true)
    const formData = new FormData(e.currentTarget)
    const data = {
      subject_id: formData.get("subject_id") as string,
      name: formData.get("name") as string,
      exam_type: formData.get("exam_type") as string,
      total_items: parseInt(formData.get("total_items") as string),
      points_per_item: parseFloat(formData.get("points_per_item") as string),
      passing_score: parseFloat(formData.get("passing_score") as string) || null,
    }

    try {
      const supabase = createClient()
      await supabase.from("exams").insert(data)
      setExamDialogOpen(false)
      router.refresh()
    } finally {
      setIsLoading(false)
    }
  }

  const handleDeleteSubject = async () => {
    if (!deleteSubjectId) return
    const supabase = createClient()
    await supabase.from("subjects").delete().eq("id", deleteSubjectId)
    setDeleteSubjectId(null)
    router.refresh()
  }

  const handleDeleteExam = async () => {
    if (!deleteExamId) return
    const supabase = createClient()
    await supabase.from("exams").delete().eq("id", deleteExamId)
    setDeleteExamId(null)
    router.refresh()
  }

  const examTypeColors: Record<string, string> = {
    quiz: "bg-blue-100 text-blue-800",
    midterm: "bg-amber-100 text-amber-800",
    final: "bg-purple-100 text-purple-800",
    assignment: "bg-emerald-100 text-emerald-800",
  }

  return (
    <Tabs defaultValue="subjects" className="space-y-4">
      <TabsList>
        <TabsTrigger value="subjects">Subjects</TabsTrigger>
        <TabsTrigger value="exams">Exams</TabsTrigger>
      </TabsList>

      <TabsContent value="subjects">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle>Subjects</CardTitle>
              <CardDescription>List of all registered subjects</CardDescription>
            </div>
            <Dialog open={subjectDialogOpen} onOpenChange={setSubjectDialogOpen}>
              <DialogTrigger asChild>
                <Button>
                  <Plus className="mr-2 h-4 w-4" />
                  Add Subject
                </Button>
              </DialogTrigger>
              <DialogContent>
                <form onSubmit={handleAddSubject}>
                  <DialogHeader>
                    <DialogTitle>Add New Subject</DialogTitle>
                    <DialogDescription>Enter the subject details.</DialogDescription>
                  </DialogHeader>
                  <div className="grid gap-4 py-4">
                    <div className="grid gap-2">
                      <Label htmlFor="code">Subject Code</Label>
                      <Input id="code" name="code" placeholder="e.g., CS101" required />
                    </div>
                    <div className="grid gap-2">
                      <Label htmlFor="name">Subject Name</Label>
                      <Input id="name" name="name" placeholder="e.g., Introduction to Computing" required />
                    </div>
                    <div className="grid gap-2">
                      <Label htmlFor="units">Units</Label>
                      <Input id="units" name="units" type="number" min="1" max="6" defaultValue="3" required />
                    </div>
                  </div>
                  <DialogFooter>
                    <Button type="button" variant="outline" onClick={() => setSubjectDialogOpen(false)}>
                      Cancel
                    </Button>
                    <Button type="submit" disabled={isLoading}>
                      {isLoading ? "Adding..." : "Add Subject"}
                    </Button>
                  </DialogFooter>
                </form>
              </DialogContent>
            </Dialog>
          </CardHeader>
          <CardContent>
            {subjects.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-10 text-center">
                <p className="text-muted-foreground mb-2">No subjects yet</p>
                <p className="text-sm text-muted-foreground">Add your first subject to get started</p>
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Code</TableHead>
                    <TableHead>Name</TableHead>
                    <TableHead>Units</TableHead>
                    <TableHead className="w-[70px]"></TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {subjects.map((subject) => (
                    <TableRow key={subject.id}>
                      <TableCell className="font-medium">{subject.code}</TableCell>
                      <TableCell>{subject.name}</TableCell>
                      <TableCell>{subject.units}</TableCell>
                      <TableCell>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => setDeleteSubjectId(subject.id)}
                        >
                          <Trash2 className="h-4 w-4 text-destructive" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </CardContent>
        </Card>
      </TabsContent>

      <TabsContent value="exams">
        <Card>
          <CardHeader className="flex flex-row items-center justify-between">
            <div>
              <CardTitle>Exams</CardTitle>
              <CardDescription>Manage exams with configurable scoring</CardDescription>
            </div>
            <Dialog open={examDialogOpen} onOpenChange={setExamDialogOpen}>
              <DialogTrigger asChild>
                <Button disabled={subjects.length === 0}>
                  <Plus className="mr-2 h-4 w-4" />
                  Create Exam
                </Button>
              </DialogTrigger>
              <DialogContent>
                <form onSubmit={handleAddExam}>
                  <DialogHeader>
                    <DialogTitle>Create New Exam</DialogTitle>
                    <DialogDescription>Configure the exam settings and scoring.</DialogDescription>
                  </DialogHeader>
                  <div className="grid gap-4 py-4">
                    <div className="grid gap-2">
                      <Label htmlFor="subject_id">Subject</Label>
                      <Select name="subject_id" required>
                        <SelectTrigger>
                          <SelectValue placeholder="Select subject" />
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
                    <div className="grid gap-2">
                      <Label htmlFor="name">Exam Name</Label>
                      <Input id="name" name="name" placeholder="e.g., Quiz 1" required />
                    </div>
                    <div className="grid gap-2">
                      <Label htmlFor="exam_type">Exam Type</Label>
                      <Select name="exam_type" required>
                        <SelectTrigger>
                          <SelectValue placeholder="Select type" />
                        </SelectTrigger>
                        <SelectContent>
                          <SelectItem value="quiz">Quiz</SelectItem>
                          <SelectItem value="midterm">Midterm</SelectItem>
                          <SelectItem value="final">Final</SelectItem>
                          <SelectItem value="assignment">Assignment</SelectItem>
                        </SelectContent>
                      </Select>
                    </div>
                    <div className="grid grid-cols-2 gap-4">
                      <div className="grid gap-2">
                        <Label htmlFor="total_items">Total Items</Label>
                        <Input id="total_items" name="total_items" type="number" min="1" required />
                      </div>
                      <div className="grid gap-2">
                        <Label htmlFor="points_per_item">Points per Item</Label>
                        <Input id="points_per_item" name="points_per_item" type="number" step="0.5" min="0.5" defaultValue="1" required />
                      </div>
                    </div>
                    <div className="grid gap-2">
                      <Label htmlFor="passing_score">Passing Score (optional)</Label>
                      <Input id="passing_score" name="passing_score" type="number" step="0.5" />
                    </div>
                  </div>
                  <DialogFooter>
                    <Button type="button" variant="outline" onClick={() => setExamDialogOpen(false)}>
                      Cancel
                    </Button>
                    <Button type="submit" disabled={isLoading}>
                      {isLoading ? "Creating..." : "Create Exam"}
                    </Button>
                  </DialogFooter>
                </form>
              </DialogContent>
            </Dialog>
          </CardHeader>
          <CardContent>
            {exams.length === 0 ? (
              <div className="flex flex-col items-center justify-center py-10 text-center">
                <p className="text-muted-foreground mb-2">No exams yet</p>
                <p className="text-sm text-muted-foreground">
                  {subjects.length === 0
                    ? "Add a subject first, then create exams"
                    : "Create your first exam to start scanning"}
                </p>
              </div>
            ) : (
              <Table>
                <TableHeader>
                  <TableRow>
                    <TableHead>Subject</TableHead>
                    <TableHead>Exam Name</TableHead>
                    <TableHead>Type</TableHead>
                    <TableHead>Items</TableHead>
                    <TableHead>Points/Item</TableHead>
                    <TableHead>Max Score</TableHead>
                    <TableHead className="w-[70px]"></TableHead>
                  </TableRow>
                </TableHeader>
                <TableBody>
                  {exams.map((exam) => (
                    <TableRow key={exam.id}>
                      <TableCell className="font-medium">{exam.subject?.code}</TableCell>
                      <TableCell>{exam.name}</TableCell>
                      <TableCell>
                        <Badge className={examTypeColors[exam.exam_type]} variant="secondary">
                          {exam.exam_type}
                        </Badge>
                      </TableCell>
                      <TableCell>{exam.total_items}</TableCell>
                      <TableCell>{exam.points_per_item}</TableCell>
                      <TableCell>{exam.total_items * exam.points_per_item}</TableCell>
                      <TableCell>
                        <Button
                          variant="ghost"
                          size="icon"
                          onClick={() => setDeleteExamId(exam.id)}
                        >
                          <Trash2 className="h-4 w-4 text-destructive" />
                        </Button>
                      </TableCell>
                    </TableRow>
                  ))}
                </TableBody>
              </Table>
            )}
          </CardContent>
        </Card>
      </TabsContent>

      <AlertDialog open={!!deleteSubjectId} onOpenChange={() => setDeleteSubjectId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Subject</AlertDialogTitle>
            <AlertDialogDescription>
              This will also delete all associated exams and results. This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleDeleteSubject} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      <AlertDialog open={!!deleteExamId} onOpenChange={() => setDeleteExamId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Exam</AlertDialogTitle>
            <AlertDialogDescription>
              This will also delete all associated results. This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleDeleteExam} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>
    </Tabs>
  )
}
