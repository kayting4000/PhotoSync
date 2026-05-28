"use client"

import dynamic from "next/dynamic"
import { Skeleton } from "@/components/ui/skeleton"

const TestScanner = dynamic(
  () => import("@/components/scanner/test-scanner").then(mod => ({ default: mod.TestScanner })),
  {
    ssr: false,
    loading: () => (
      <div className="grid gap-6 lg:grid-cols-2">
        <Skeleton className="h-[500px]" />
        <Skeleton className="h-[500px]" />
      </div>
    ),
  }
)

interface ClientScannerWrapperProps {
  students: any[]
  exams: any[]
}

export default function ClientScannerWrapper({ students, exams }: ClientScannerWrapperProps) {
  return <TestScanner students={students} exams={exams} />
}