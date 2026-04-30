import { NextRequest, NextResponse } from "next/server"
import { Resend } from "resend"

// Lazy initialization to avoid build-time errors
function getResendClient() {
  if (!process.env.RESEND_API_KEY) {
    return null
  }
  return new Resend(process.env.RESEND_API_KEY)
}

interface ExamResultData {
  examName: string
  score: number
  maxScore: number
  percentage: number
  grade: string
  remarks: string
}

interface EmailRequestBody {
  to: string
  studentName: string
  subjectCode: string
  subjectName: string
  results: ExamResultData[]
  averagePercentage: number
  finalGrade: string
  customMessage?: string
}

export async function POST(request: NextRequest) {
  try {
    const body: EmailRequestBody = await request.json()
    const {
      to,
      studentName,
      subjectCode,
      subjectName,
      results,
      averagePercentage,
      finalGrade,
      customMessage,
    } = body

    if (!to || !studentName || !subjectCode || !results) {
      return NextResponse.json(
        { error: "Missing required fields" },
        { status: 400 }
      )
    }

    const resultsHtml = results
      .map(
        (r) => `
        <tr>
          <td style="padding: 8px; border: 1px solid #e5e7eb;">${r.examName}</td>
          <td style="padding: 8px; border: 1px solid #e5e7eb; text-align: center;">${r.score} / ${r.maxScore}</td>
          <td style="padding: 8px; border: 1px solid #e5e7eb; text-align: center;">${r.percentage?.toFixed(1)}%</td>
          <td style="padding: 8px; border: 1px solid #e5e7eb; text-align: center;">${r.grade}</td>
          <td style="padding: 8px; border: 1px solid #e5e7eb; text-align: center;">
            <span style="color: ${r.remarks === 'Passed' ? '#16a34a' : '#dc2626'}; font-weight: 500;">
              ${r.remarks}
            </span>
          </td>
        </tr>
      `
      )
      .join("")

    const htmlContent = `
      <!DOCTYPE html>
      <html>
        <head>
          <meta charset="utf-8">
          <meta name="viewport" content="width=device-width, initial-scale=1.0">
        </head>
        <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; color: #1f2937;">
          <div style="text-align: center; margin-bottom: 24px;">
            <h1 style="color: #2563eb; margin: 0; font-size: 24px;">EduScan</h1>
            <p style="color: #6b7280; margin: 4px 0 0 0;">Grade Report</p>
          </div>
          
          <div style="background: #f9fafb; border-radius: 8px; padding: 20px; margin-bottom: 24px;">
            <p style="margin: 0 0 16px 0;">Dear <strong>${studentName}</strong>,</p>
            <p style="margin: 0;">Here are your exam results for <strong>${subjectCode} - ${subjectName}</strong>:</p>
          </div>

          <table style="width: 100%; border-collapse: collapse; margin-bottom: 24px;">
            <thead>
              <tr style="background: #f3f4f6;">
                <th style="padding: 12px 8px; border: 1px solid #e5e7eb; text-align: left;">Exam</th>
                <th style="padding: 12px 8px; border: 1px solid #e5e7eb; text-align: center;">Score</th>
                <th style="padding: 12px 8px; border: 1px solid #e5e7eb; text-align: center;">Percentage</th>
                <th style="padding: 12px 8px; border: 1px solid #e5e7eb; text-align: center;">Grade</th>
                <th style="padding: 12px 8px; border: 1px solid #e5e7eb; text-align: center;">Status</th>
              </tr>
            </thead>
            <tbody>
              ${resultsHtml}
            </tbody>
          </table>

          <div style="background: linear-gradient(to right, #2563eb, #3b82f6); border-radius: 8px; padding: 20px; color: white; text-align: center; margin-bottom: 24px;">
            <p style="margin: 0 0 8px 0; opacity: 0.9;">Overall Performance</p>
            <p style="margin: 0; font-size: 32px; font-weight: bold;">${averagePercentage.toFixed(1)}%</p>
            <p style="margin: 8px 0 0 0; font-size: 20px;">Grade: ${finalGrade}</p>
          </div>

          ${
            customMessage
              ? `
            <div style="background: #fef3c7; border-left: 4px solid #f59e0b; padding: 16px; margin-bottom: 24px;">
              <p style="margin: 0; color: #92400e;"><strong>Message from your instructor:</strong></p>
              <p style="margin: 8px 0 0 0; color: #78350f;">${customMessage}</p>
            </div>
          `
              : ""
          }

          <div style="text-align: center; color: #6b7280; font-size: 12px; border-top: 1px solid #e5e7eb; padding-top: 16px;">
            <p style="margin: 0;">This is an automated message from EduScan.</p>
            <p style="margin: 4px 0 0 0;">Please do not reply to this email.</p>
          </div>
        </body>
      </html>
    `

    // Check if RESEND_API_KEY is configured
    const resend = getResendClient()
    if (!resend) {
      // Return success for demo purposes
      console.log("[v0] Email would be sent to:", to)
      console.log("[v0] Subject:", `Grade Report - ${subjectCode}`)
      return NextResponse.json({ 
        success: true, 
        message: "Email simulated (RESEND_API_KEY not configured)" 
      })
    }

    const { data, error } = await resend.emails.send({
      from: "EduScan <onboarding@resend.dev>",
      to: [to],
      subject: `Grade Report - ${subjectCode} ${subjectName}`,
      html: htmlContent,
    })

    if (error) {
      console.error("[v0] Resend error:", error)
      return NextResponse.json({ error: error.message }, { status: 500 })
    }

    return NextResponse.json({ success: true, data })
  } catch (error) {
    console.error("[v0] Email send error:", error)
    return NextResponse.json(
      { error: "Failed to send email" },
      { status: 500 }
    )
  }
}
