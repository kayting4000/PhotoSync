"use client"

import { useEffect, useState } from "react"
import { apiClient } from "@/lib/api-client"
import { Card, CardContent, CardDescription, CardHeader, CardTitle } from "@/components/ui/card"
import { Users, BookOpen, FileText, TrendingUp, ChevronRight } from "lucide-react"
import Link from "next/link"

interface DashboardStats {
  total_students: number
  total_subjects: number
  total_exams: number
  total_results: number
}

export default function DashboardPage() {
  const [stats, setStats] = useState<DashboardStats>({
    total_students: 0,
    total_subjects: 0,
    total_exams: 0,
    total_results: 0,
  })
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    apiClient<DashboardStats>("/dashboard/")
      .then(setStats)
      .catch(() => {})
      .finally(() => setLoading(false))
  }, [])

  const statCards = [
    { label: "Total Students", value: stats.total_students, icon: Users, href: "/dashboard/students", color: "text-blue-600" },
    { label: "Subjects", value: stats.total_subjects, icon: BookOpen, href: "/dashboard/subjects", color: "text-emerald-600" },
    { label: "Exams Created", value: stats.total_exams, icon: FileText, href: "/dashboard/subjects", color: "text-amber-600" },
    { label: "Results Recorded", value: stats.total_results, icon: TrendingUp, href: "/dashboard/grades", color: "text-purple-600" },
  ]

  const quickActions = [
    { title: "Add Student", description: "Register a new student", href: "/dashboard/students?action=add" },
    { title: "Scan Test Paper", description: "Scan and score test papers", href: "/dashboard/scanner" },
    { title: "Calculate GPA", description: "View and calculate student GPA", href: "/dashboard/grades" },
    { title: "Send Results", description: "Email grades to students", href: "/dashboard/email" },
  ]

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-3xl font-bold tracking-tight">Dashboard</h1>
        <p className="text-muted-foreground">
          Welcome to PhotoSync - Test Paper Scanner and Student Information Management System
        </p>
      </div>

      <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
        {statCards.map((stat) => {
          const Icon = stat.icon
          return (
            <Link key={stat.label} href={stat.href}>
              <Card className="hover:bg-muted/50 transition-colors">
                <CardHeader className="flex flex-row items-center justify-between space-y-0 pb-2">
                  <CardTitle className="text-sm font-medium">{stat.label}</CardTitle>
                  <Icon className={`h-4 w-4 ${stat.color}`} />
                </CardHeader>
                <CardContent>
                  <div className="text-2xl font-bold">
                    {loading ? "—" : stat.value}
                  </div>
                </CardContent>
              </Card>
            </Link>
          )
        })}
      </div>

      <div>
        <h2 className="text-xl font-semibold mb-4">Quick Actions</h2>
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {quickActions.map((action) => (
            <Link key={action.title} href={action.href}>
              <Card className="h-full hover:bg-muted/50 transition-colors cursor-pointer group">
                <CardHeader>
                  <div className="flex items-center justify-between">
                    <CardTitle className="text-lg">{action.title}</CardTitle>
                    <ChevronRight className="h-4 w-4 text-muted-foreground group-hover:translate-x-0.5 transition-transform" />
                  </div>
                  <CardDescription>{action.description}</CardDescription>
                </CardHeader>
              </Card>
            </Link>
          ))}
        </div>
      </div>
    </div>
  )
}