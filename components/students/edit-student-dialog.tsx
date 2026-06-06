'use client'

import { useState } from "react"
import { createClient } from "@/lib/supabase/client"
import { Button } from "@/components/ui/button"
import {
  Dialog,
  DialogContent,
  DialogDescription,
  DialogFooter,
  DialogHeader,
  DialogTitle,
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
import type { Student } from "@/lib/types"
import { useRouter } from "next/navigation"

const courses = [
  "BSIT",
  "BSCS",
  "BSIS",
  "BSEd",
  "BSBA",
  "BSN",
  "BSCE",
  "BSEE",
  "BSME",
]

interface EditStudentDialogProps {
  student: Student
  open: boolean
  onOpenChange: (open: boolean) => void
}

export function EditStudentDialog({ student, open, onOpenChange }: EditStudentDialogProps) {
  const [isLoading, setIsLoading] = useState(false)
  const [error, setError] = useState<string | null>(null)
  const router = useRouter()

  const handleSubmit = async (e: React.FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    setIsLoading(true)
    setError(null)

    const formData = new FormData(e.currentTarget)
    const data = {
      student_id: formData.get("student_id") as string,
      first_name: formData.get("first_name") as string,
      last_name: formData.get("last_name") as string,
      email: formData.get("email") as string || null,
      course: formData.get("course") as string,
      year_level: parseInt(formData.get("year_level") as string),
      updated_at: new Date().toISOString(),
    }

    try {
      const supabase = createClient()
      const { error } = await supabase
        .from("students")
        .update(data)
        .eq("id", student.id)
      if (error) throw error
      onOpenChange(false)
      router.refresh()
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to update student")
    } finally {
      setIsLoading(false)
    }
  }

  return (
    <Dialog open={open} onOpenChange={onOpenChange}>
      <DialogContent className="sm:max-w-[425px]">
        <form onSubmit={handleSubmit}>
          <DialogHeader>
            <DialogTitle>Edit Student</DialogTitle>
            <DialogDescription>
              Update the student&apos;s information.
            </DialogDescription>
          </DialogHeader>
          <div className="grid gap-4 py-4">
            <div className="grid gap-2">
              <Label htmlFor="student_id">Student ID</Label>
              <Input
                id="student_id"
                name="student_id"
                defaultValue={student.student_id}
                required
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="grid gap-2">
                <Label htmlFor="first_name">First Name</Label>
                <Input
                  id="first_name"
                  name="first_name"
                  defaultValue={student.first_name}
                  required
                />
              </div>
              <div className="grid gap-2">
                <Label htmlFor="last_name">Last Name</Label>
                <Input
                  id="last_name"
                  name="last_name"
                  defaultValue={student.last_name}
                  required
                />
              </div>
            </div>
            <div className="grid gap-2">
              <Label htmlFor="email">Email (optional)</Label>
              <Input
                id="email"
                name="email"
                type="email"
                defaultValue={student.email ?? ""}
              />
            </div>
            <div className="grid grid-cols-2 gap-4">
              <div className="grid gap-2">
                <Label htmlFor="course">Course</Label>
                <Select name="course" required defaultValue={student.course}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    {courses.map((course) => (
                      <SelectItem key={course} value={course}>
                        {course}
                      </SelectItem>
                    ))}
                  </SelectContent>
                </Select>
              </div>
              <div className="grid gap-2">
                <Label htmlFor="year_level">Year Level</Label>
                <Select name="year_level" required defaultValue={String(student.year_level)}>
                  <SelectTrigger>
                    <SelectValue />
                  </SelectTrigger>
                  <SelectContent>
                    <SelectItem value="1">1st Year</SelectItem>
                    <SelectItem value="2">2nd Year</SelectItem>
                    <SelectItem value="3">3rd Year</SelectItem>
                    <SelectItem value="4">4th Year</SelectItem>
                  </SelectContent>
                </Select>
              </div>
            </div>
            {error && <p className="text-sm text-destructive">{error}</p>}
          </div>
          <DialogFooter>
            <Button type="button" variant="outline" onClick={() => onOpenChange(false)}>
              Cancel
            </Button>
            <Button type="submit" disabled={isLoading}>
              {isLoading ? "Saving..." : "Save Changes"}
            </Button>
          </DialogFooter>
        </form>
      </DialogContent>
    </Dialog>
  )
}
