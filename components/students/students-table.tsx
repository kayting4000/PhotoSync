'use client'

import { useState } from "react"
import { createClient } from "@/lib/supabase/client"
import {
  Table,
  TableBody,
  TableCell,
  TableHead,
  TableHeader,
  TableRow,
} from "@/components/ui/table"
import { Button } from "@/components/ui/button"
import { Input } from "@/components/ui/input"
import {
  DropdownMenu,
  DropdownMenuContent,
  DropdownMenuItem,
  DropdownMenuTrigger,
} from "@/components/ui/dropdown-menu"
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
import { MoreHorizontal, Pencil, Trash2, Search } from "lucide-react"
import type { Student } from "@/lib/types"
import { useRouter } from "next/navigation"
import { EditStudentDialog } from "./edit-student-dialog"
import { Card, CardContent, CardHeader, CardTitle } from "@/components/ui/card"
import { Badge } from "@/components/ui/badge"

export function StudentsTable({ students }: { students: Student[] }) {
  const [search, setSearch] = useState("")
  const [deleteId, setDeleteId] = useState<string | null>(null)
  const [editStudent, setEditStudent] = useState<Student | null>(null)
  const router = useRouter()

  const filteredStudents = students.filter(
    (student) =>
      student.student_id.toLowerCase().includes(search.toLowerCase()) ||
      student.first_name.toLowerCase().includes(search.toLowerCase()) ||
      student.last_name.toLowerCase().includes(search.toLowerCase()) ||
      student.course.toLowerCase().includes(search.toLowerCase())
  )

  const handleDelete = async () => {
    if (!deleteId) return
    const supabase = createClient()
    await supabase.from("students").delete().eq("id", deleteId)
    setDeleteId(null)
    router.refresh()
  }

  return (
    <Card>
      <CardHeader>
        <div className="flex items-center justify-between">
          <CardTitle>Student Records</CardTitle>
          <div className="relative w-64">
            <Search className="absolute left-2 top-2.5 h-4 w-4 text-muted-foreground" />
            <Input
              placeholder="Search students..."
              value={search}
              onChange={(e) => setSearch(e.target.value)}
              className="pl-8"
            />
          </div>
        </div>
      </CardHeader>
      <CardContent>
        {filteredStudents.length === 0 ? (
          <div className="flex flex-col items-center justify-center py-10 text-center">
            <p className="text-muted-foreground mb-2">No students found</p>
            <p className="text-sm text-muted-foreground">
              {students.length === 0
                ? "Add your first student to get started"
                : "Try adjusting your search"}
            </p>
          </div>
        ) : (
          <Table>
            <TableHeader>
              <TableRow>
                <TableHead>Student ID</TableHead>
                <TableHead>Name</TableHead>
                <TableHead>Email</TableHead>
                <TableHead>Course</TableHead>
                <TableHead>Year</TableHead>
                <TableHead className="w-[70px]"></TableHead>
              </TableRow>
            </TableHeader>
            <TableBody>
              {filteredStudents.map((student) => (
                <TableRow key={student.id}>
                  <TableCell className="font-medium">{student.student_id}</TableCell>
                  <TableCell>{student.first_name} {student.last_name}</TableCell>
                  <TableCell>{student.email || "-"}</TableCell>
                  <TableCell>
                    <Badge variant="secondary">{student.course}</Badge>
                  </TableCell>
                  <TableCell>{student.year_level}</TableCell>
                  <TableCell>
                    <DropdownMenu>
                      <DropdownMenuTrigger asChild>
                        <Button variant="ghost" size="icon">
                          <MoreHorizontal className="h-4 w-4" />
                          <span className="sr-only">Actions</span>
                        </Button>
                      </DropdownMenuTrigger>
                      <DropdownMenuContent align="end">
                        <DropdownMenuItem onClick={() => setEditStudent(student)}>
                          <Pencil className="mr-2 h-4 w-4" />
                          Edit
                        </DropdownMenuItem>
                        <DropdownMenuItem
                          onClick={() => setDeleteId(student.id)}
                          className="text-destructive"
                        >
                          <Trash2 className="mr-2 h-4 w-4" />
                          Delete
                        </DropdownMenuItem>
                      </DropdownMenuContent>
                    </DropdownMenu>
                  </TableCell>
                </TableRow>
              ))}
            </TableBody>
          </Table>
        )}
      </CardContent>

      <AlertDialog open={!!deleteId} onOpenChange={() => setDeleteId(null)}>
        <AlertDialogContent>
          <AlertDialogHeader>
            <AlertDialogTitle>Delete Student</AlertDialogTitle>
            <AlertDialogDescription>
              Are you sure you want to delete this student? This action cannot be undone.
            </AlertDialogDescription>
          </AlertDialogHeader>
          <AlertDialogFooter>
            <AlertDialogCancel>Cancel</AlertDialogCancel>
            <AlertDialogAction onClick={handleDelete} className="bg-destructive text-destructive-foreground hover:bg-destructive/90">
              Delete
            </AlertDialogAction>
          </AlertDialogFooter>
        </AlertDialogContent>
      </AlertDialog>

      {editStudent && (
        <EditStudentDialog
          student={editStudent}
          open={!!editStudent}
          onOpenChange={() => setEditStudent(null)}
        />
      )}
    </Card>
  )
}
