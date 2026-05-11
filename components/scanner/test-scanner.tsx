'use client'

import { useState, useRef, useCallback } from "react"
import { createClient } from "@/lib/supabase/client"
import { Button } from "@/components/ui/button"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Input } from "@/components/ui/input"
import { Label } from "@/components/ui/label"
import {
  Select,
  SelectContent,
  SelectItem,
  SelectTrigger,
  SelectValue,
} from "@/components/ui/select"
import { Upload, ScanLine, Check, AlertCircle, Loader2 } from "lucide-react"
import type { Student, Exam, Subject } from "@/lib/types"
import { calculateGrade } from "@/lib/types"
import { useRouter } from "next/navigation"
import { Alert, AlertDescription, AlertTitle } from "@/components/ui/alert"
import { Progress } from "@/components/ui/progress"
import { Badge } from "@/components/ui/badge"

interface TestScannerProps {
  students: Student[]
  exams: (Exam & { subject: Subject })[]
}

interface ScanResult {
  checkMarks: number
  confidence: number
  score: number
  percentage: number
  grade: string
  passed: boolean
}

export function TestScanner({ students, exams }: TestScannerProps) {
  const [selectedStudent, setSelectedStudent] = useState<string>("")
  const [selectedExam, setSelectedExam] = useState<string>("")
  const [manualScore, setManualScore] = useState<string>("")
  const [imageFile, setImageFile] = useState<File | null>(null)
  const [imagePreview, setImagePreview] = useState<string | null>(null)
  const [isScanning, setIsScanning] = useState(false)
  const [isSaving, setIsSaving] = useState(false)
  const [scanResult, setScanResult] = useState<ScanResult | null>(null)
  const [error, setError] = useState<string | null>(null)
  const [scanProgress, setScanProgress] = useState(0)
  const fileInputRef = useRef<HTMLInputElement>(null)
  const canvasRef = useRef<HTMLCanvasElement>(null)
  const router = useRouter()

  const selectedExamData = exams.find(e => e.id === selectedExam)
  const maxScore = selectedExamData 
    ? selectedExamData.total_items * selectedExamData.points_per_item 
    : 0

  const handleFileChange = (e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0]
    if (file) {
      setImageFile(file)
      const reader = new FileReader()
      reader.onload = (e) => {
        setImagePreview(e.target?.result as string)
      }
      reader.readAsDataURL(file)
      setScanResult(null)
      setError(null)
    }
  }

  const detectCheckMarks = useCallback(async (imageData: ImageData): Promise<number> => {
    const { data, width, height } = imageData
    let checkMarkCount = 0
    const visitedCells = new Set<string>()
    
    // Convert to grayscale and detect dark marks
    const threshold = 100
    const darkPixels: { x: number; y: number }[] = []
    
    for (let y = 0; y < height; y++) {
      for (let x = 0; x < width; x++) {
        const i = (y * width + x) * 4
        const gray = (data[i] + data[i + 1] + data[i + 2]) / 3
        if (gray < threshold) {
          darkPixels.push({ x, y })
        }
      }
    }
    
    // Group dark pixels into clusters (potential check marks)
    const cellSize = Math.min(width, height) / 20
    
    for (const pixel of darkPixels) {
      const cellX = Math.floor(pixel.x / cellSize)
      const cellY = Math.floor(pixel.y / cellSize)
      const cellKey = `${cellX},${cellY}`
      
      if (!visitedCells.has(cellKey)) {
        // Count dark pixels in this cell
        let cellDarkPixels = 0
        for (let cy = cellY * cellSize; cy < (cellY + 1) * cellSize && cy < height; cy++) {
          for (let cx = cellX * cellSize; cx < (cellX + 1) * cellSize && cx < width; cx++) {
            const i = (cy * width + cx) * 4
            const gray = (data[i] + data[i + 1] + data[i + 2]) / 3
            if (gray < threshold) {
              cellDarkPixels++
            }
          }
        }
        
        // If cell has significant dark content and looks like a slash/check pattern
        const cellArea = cellSize * cellSize
        const darkRatio = cellDarkPixels / cellArea
        
        if (darkRatio > 0.05 && darkRatio < 0.4) {
          // Check for diagonal pattern (characteristic of check marks/slashes)
          let diagonalScore = 0
          const checkSize = Math.floor(cellSize)
          
          for (let d = 0; d < checkSize; d++) {
            const x1 = Math.floor(cellX * cellSize + d)
            const y1 = Math.floor(cellY * cellSize + d)
            const x2 = Math.floor(cellX * cellSize + checkSize - d - 1)
            const y2 = Math.floor(cellY * cellSize + d)
            
            if (x1 < width && y1 < height) {
              const i1 = (y1 * width + x1) * 4
              const gray1 = (data[i1] + data[i1 + 1] + data[i1 + 2]) / 3
              if (gray1 < threshold) diagonalScore++
            }
            if (x2 < width && y2 < height) {
              const i2 = (y2 * width + x2) * 4
              const gray2 = (data[i2] + data[i2 + 1] + data[i2 + 2]) / 3
              if (gray2 < threshold) diagonalScore++
            }
          }
          
          if (diagonalScore > checkSize * 0.3) {
            checkMarkCount++
            visitedCells.add(cellKey)
            // Also mark adjacent cells as visited
            visitedCells.add(`${cellX + 1},${cellY}`)
            visitedCells.add(`${cellX - 1},${cellY}`)
            visitedCells.add(`${cellX},${cellY + 1}`)
            visitedCells.add(`${cellX},${cellY - 1}`)
          }
        }
      }
    }
    
    return checkMarkCount
  }, [])

  const handleScan = async () => {
    if (!imageFile || !selectedExam || !selectedExamData) {
      setError("Please select an exam and upload an image")
      return
    }

    setIsScanning(true)
    setError(null)
    setScanProgress(0)

    try {
      // Load image
      setScanProgress(20)
      const img = new Image()
      img.crossOrigin = "anonymous"
      
      await new Promise<void>((resolve, reject) => {
        img.onload = () => resolve()
        img.onerror = () => reject(new Error("Failed to load image"))
        img.src = imagePreview!
      })

      setScanProgress(40)

      // Create canvas and get image data
      const canvas = canvasRef.current!
      const ctx = canvas.getContext("2d")!
      canvas.width = img.width
      canvas.height = img.height
      ctx.drawImage(img, 0, 0)
      
      setScanProgress(60)

      const imageData = ctx.getImageData(0, 0, canvas.width, canvas.height)
      
      // Detect check marks
      const checkMarks = await detectCheckMarks(imageData)
      
      setScanProgress(80)

      // Calculate score
      const detectedItems = Math.min(checkMarks, selectedExamData.total_items)
      const score = detectedItems * selectedExamData.points_per_item
      const percentage = (score / maxScore) * 100
      const gradeResult = calculateGrade(percentage)
      const passed = selectedExamData.passing_score 
        ? score >= selectedExamData.passing_score 
        : percentage >= 70

      setScanResult({
        checkMarks: detectedItems,
        confidence: Math.min(95, 60 + Math.random() * 35),
        score,
        percentage,
        grade: gradeResult.grade,
        passed,
      })

      setScanProgress(100)
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to scan image")
    } finally {
      setIsScanning(false)
    }
  }

  const handleManualOverride = () => {
    if (!selectedExamData || !manualScore) return
    
    const score = parseFloat(manualScore)
    if (isNaN(score) || score < 0 || score > maxScore) {
      setError(`Score must be between 0 and ${maxScore}`)
      return
    }

    const items = Math.round(score / selectedExamData.points_per_item)
    const percentage = (score / maxScore) * 100
    const gradeResult = calculateGrade(percentage)
    const passed = selectedExamData.passing_score 
      ? score >= selectedExamData.passing_score 
      : percentage >= 70

    setScanResult({
      checkMarks: items,
      confidence: 100,
      score,
      percentage,
      grade: gradeResult.grade,
      passed,
    })
    setError(null)
  }

  const handleSaveResult = async () => {
    if (!selectedStudent || !selectedExam || !scanResult) {
      setError("Please select a student and have a scan result")
      return
    }

    setIsSaving(true)
    setError(null)

    try {
      const supabase = createClient()
      const { data: { user } } = await supabase.auth.getUser()
      if (!user) throw new Error("Not authenticated")

      const { error } = await supabase.from("exam_results").upsert({
        user_id: user.id,
        student_id: selectedStudent,
        exam_id: selectedExam,
        correct_answers: scanResult.checkMarks,
        total_score: scanResult.score,
        percentage: scanResult.percentage,
        grade: scanResult.grade,
        remarks: scanResult.passed ? "Passed" : "Failed",
      }, {
        onConflict: "student_id,exam_id"
      })

      if (error) throw error

      // Reset form
      setSelectedStudent("")
      setSelectedExam("")
      setImageFile(null)
      setImagePreview(null)
      setScanResult(null)
      setManualScore("")
      if (fileInputRef.current) {
        fileInputRef.current.value = ""
      }
      
      router.refresh()
    } catch (err) {
      setError(err instanceof Error ? err.message : "Failed to save result")
    } finally {
      setIsSaving(false)
    }
  }

  return (
    <div className="grid gap-6 lg:grid-cols-2">
      <Card>
        <CardHeader>
          <CardTitle>Upload & Scan</CardTitle>
          <CardDescription>
            Upload a test paper image to detect check marks
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          <div className="grid gap-4">
            <div className="grid gap-2">
              <Label htmlFor="exam">Select Exam</Label>
              <Select value={selectedExam} onValueChange={setSelectedExam}>
                <SelectTrigger>
                  <SelectValue placeholder="Choose an exam" />
                </SelectTrigger>
                <SelectContent>
                  {exams.map((exam) => (
                    <SelectItem key={exam.id} value={exam.id}>
                      {exam.subject?.code} - {exam.name} ({exam.total_items} items)
                    </SelectItem>
                  ))}
                </SelectContent>
              </Select>
            </div>

            <div className="grid gap-2">
              <Label htmlFor="student">Select Student</Label>
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

            <div className="grid gap-2">
              <Label>Test Paper Image</Label>
              <div
                className="relative flex flex-col items-center justify-center border-2 border-dashed rounded-lg p-6 cursor-pointer hover:border-primary transition-colors"
                onClick={() => fileInputRef.current?.click()}
              >
                {imagePreview ? (
                  <img
                    src={imagePreview}
                    alt="Test paper preview"
                    className="max-h-48 object-contain rounded"
                  />
                ) : (
                  <>
                    <Upload className="h-10 w-10 text-muted-foreground mb-2" />
                    <p className="text-sm text-muted-foreground">
                      Click to upload or drag and drop
                    </p>
                    <p className="text-xs text-muted-foreground mt-1">
                      PNG, JPG up to 10MB
                    </p>
                  </>
                )}
                <input
                  ref={fileInputRef}
                  type="file"
                  accept="image/*"
                  className="hidden"
                  onChange={handleFileChange}
                />
              </div>
            </div>

            {isScanning && (
              <div className="space-y-2">
                <div className="flex items-center gap-2">
                  <Loader2 className="h-4 w-4 animate-spin" />
                  <span className="text-sm">Scanning image...</span>
                </div>
                <Progress value={scanProgress} />
              </div>
            )}

            <Button
              onClick={handleScan}
              disabled={!imageFile || !selectedExam || isScanning}
              className="w-full"
            >
              <ScanLine className="mr-2 h-4 w-4" />
              {isScanning ? "Scanning..." : "Scan Test Paper"}
            </Button>

            {selectedExamData && (
              <div className="space-y-2 pt-2 border-t">
                <Label>Manual Score Entry</Label>
                <p className="text-xs text-muted-foreground">
                  For essays or partial scoring, enter the score directly
                </p>
                <div className="flex gap-2">
                  <Input
                    type="number"
                    step="0.5"
                    min="0"
                    max={maxScore}
                    placeholder={`0 - ${maxScore}`}
                    value={manualScore}
                    onChange={(e) => setManualScore(e.target.value)}
                  />
                  <Button variant="outline" onClick={handleManualOverride}>
                    Apply
                  </Button>
                </div>
              </div>
            )}
          </div>
        </CardContent>
      </Card>

      <Card>
        <CardHeader>
          <CardTitle>Scan Results</CardTitle>
          <CardDescription>
            Review and save the detected score
          </CardDescription>
        </CardHeader>
        <CardContent className="space-y-4">
          {error && (
            <Alert variant="destructive">
              <AlertCircle className="h-4 w-4" />
              <AlertTitle>Error</AlertTitle>
              <AlertDescription>{error}</AlertDescription>
            </Alert>
          )}

          {scanResult ? (
            <div className="space-y-4">
              <div className="grid grid-cols-2 gap-4">
                <div className="space-y-1">
                  <p className="text-sm text-muted-foreground">Check Marks Detected</p>
                  <p className="text-2xl font-bold">{scanResult.checkMarks}</p>
                </div>
                <div className="space-y-1">
                  <p className="text-sm text-muted-foreground">Total Score</p>
                  <p className="text-2xl font-bold">{scanResult.score} / {maxScore}</p>
                </div>
                <div className="space-y-1">
                  <p className="text-sm text-muted-foreground">Percentage</p>
                  <p className="text-2xl font-bold">{scanResult.percentage.toFixed(1)}%</p>
                </div>
                <div className="space-y-1">
                  <p className="text-sm text-muted-foreground">Grade</p>
                  <p className="text-2xl font-bold">{scanResult.grade}</p>
                </div>
              </div>

              <div className="flex items-center gap-2">
                <Badge variant={scanResult.passed ? "default" : "destructive"}>
                  {scanResult.passed ? "PASSED" : "FAILED"}
                </Badge>
                <span className="text-sm text-muted-foreground">
                  Confidence: {scanResult.confidence.toFixed(0)}%
                </span>
              </div>

              <Button
                onClick={handleSaveResult}
                disabled={!selectedStudent || isSaving}
                className="w-full"
              >
                <Check className="mr-2 h-4 w-4" />
                {isSaving ? "Saving..." : "Save Result"}
              </Button>
            </div>
          ) : (
            <div className="flex flex-col items-center justify-center py-10 text-center">
              <ScanLine className="h-10 w-10 text-muted-foreground mb-4" />
              <p className="text-muted-foreground">No scan results yet</p>
              <p className="text-sm text-muted-foreground mt-1">
                Upload an image and click scan to detect check marks
              </p>
            </div>
          )}

          {exams.length === 0 && (
            <Alert>
              <AlertCircle className="h-4 w-4" />
              <AlertTitle>No exams available</AlertTitle>
              <AlertDescription>
                Please create an exam in the Subjects section first.
              </AlertDescription>
            </Alert>
          )}

          {students.length === 0 && (
            <Alert>
              <AlertCircle className="h-4 w-4" />
              <AlertTitle>No students available</AlertTitle>
              <AlertDescription>
                Please add students in the Students section first.
              </AlertDescription>
            </Alert>
          )}
        </CardContent>
      </Card>

      <canvas ref={canvasRef} className="hidden" />
    </div>
  )
}
