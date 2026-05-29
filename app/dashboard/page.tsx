"use client"

import { useEffect, useState } from "react"
import { apiClient } from "@/lib/api-client"
import { Users, BookOpen, FileText, TrendingUp, ChevronRight, ScanLine, Calculator, Mail, UserPlus } from "lucide-react"
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
    { label: "Total Students", value: stats.total_students, icon: Users, href: "/dashboard/students", color: "text-blue-500", bg: "from-blue-500/10 to-blue-600/5" },
    { label: "Subjects", value: stats.total_subjects, icon: BookOpen, href: "/dashboard/subjects", color: "text-emerald-500", bg: "from-emerald-500/10 to-emerald-600/5" },
    { label: "Exams Created", value: stats.total_exams, icon: FileText, href: "/dashboard/subjects", color: "text-amber-500", bg: "from-amber-500/10 to-amber-600/5" },
    { label: "Results Recorded", value: stats.total_results, icon: TrendingUp, href: "/dashboard/grades", color: "text-purple-500", bg: "from-purple-500/10 to-purple-600/5" },
  ]

  const quickActions = [
    { title: "Add Student", description: "Register a new student", href: "/dashboard/students?action=add", icon: UserPlus, color: "text-blue-500" },
    { title: "Scan Test Paper", description: "Scan and score test papers", href: "/dashboard/scanner", icon: ScanLine, color: "text-emerald-500" },
    { title: "Calculate GPA", description: "View and calculate student GPA", href: "/dashboard/grades", icon: Calculator, color: "text-amber-500" },
    { title: "Send Results", description: "Email grades to students", href: "/dashboard/email", icon: Mail, color: "text-purple-500" },
  ]

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-3xl font-bold tracking-tight text-slate-800 dark:text-slate-100">
          Dashboard
        </h1>
        <p className="text-slate-500 dark:text-slate-400 mt-1">
          Welcome to PhotoSync — Test Paper Scanner and Student Information Management System
        </p>
      </div>

      {/* Stats Grid */}
      <div className="grid gap-5 md:grid-cols-2 lg:grid-cols-4">
        {statCards.map((stat) => {
          const Icon = stat.icon
          return (
            <Link key={stat.label} href={stat.href}>
              <div className="neu-stat p-5 cursor-pointer group">
                <div className="flex items-center justify-between mb-3">
                  <span className="text-sm font-medium text-slate-500 dark:text-slate-400">
                    {stat.label}
                  </span>
                  <div className={`p-2 rounded-xl bg-gradient-to-br ${stat.bg}`}>
                    <Icon className={`h-4 w-4 ${stat.color}`} />
                  </div>
                </div>
                <div className="text-3xl font-bold text-slate-800 dark:text-slate-100">
                  {loading ? "—" : stat.value}
                </div>
              </div>
            </Link>
          )
        })}
      </div>

      {/* Quick Actions */}
      <div>
        <h2 className="text-xl font-semibold mb-4 text-slate-800 dark:text-slate-100">
          Quick Actions
        </h2>
        <div className="grid gap-4 md:grid-cols-2 lg:grid-cols-4">
          {quickActions.map((action) => {
            const Icon = action.icon
            return (
              <Link key={action.title} href={action.href}>
                <div className="neu-card p-5 h-full cursor-pointer group">
                  <div className="flex items-center justify-between mb-3">
                    <div className={`p-2 rounded-xl neu-inset`}>
                      <Icon className={`h-5 w-5 ${action.color}`} />
                    </div>
                    <ChevronRight className="h-4 w-4 text-slate-400 group-hover:translate-x-1 transition-transform" />
                  </div>
                  <h3 className="font-semibold text-slate-800 dark:text-slate-100 mb-1">
                    {action.title}
                  </h3>
                  <p className="text-sm text-slate-500 dark:text-slate-400">
                    {action.description}
                  </p>
                </div>
              </Link>
            )
          })}
        </div>
      </div>
    </div>
  )
}