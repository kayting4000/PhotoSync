"""
Enhanced email templates for grade reports and transcripts.
Professional report card styling with better visual hierarchy.
"""
from datetime import datetime


def grade_report_template(
    student_name: str,
    exam_name: str,
    subject_code: str,
    subject_name: str,
    percentage: float,
    grade: str,
    grade_point: float,
    remarks: str,
    custom_message: str = None,
) -> str:
    """
    Enhanced grade report email template with report card styling.
    """
    # Determine grade color
    if percentage >= 90:
        grade_color = "#10b981"  # Green
        grade_bg = "#ecfdf5"
    elif percentage >= 80:
        grade_color = "#3b82f6"  # Blue
        grade_bg = "#eff6ff"
    elif percentage >= 70:
        grade_color = "#f59e0b"  # Amber
        grade_bg = "#fffbeb"
    else:
        grade_color = "#ef4444"  # Red
        grade_bg = "#fef2f2"
    
    remarks_color = "#10b981" if remarks == "Passed" else "#ef4444"
    
    return f"""
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
          }}
          .container {{
            max-width: 600px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
            overflow: hidden;
          }}
          .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 20px;
            text-align: center;
          }}
          .header h1 {{
            margin: 0;
            font-size: 32px;
            font-weight: 700;
          }}
          .header p {{
            margin: 8px 0 0 0;
            opacity: 0.9;
            font-size: 14px;
          }}
          .content {{
            padding: 40px;
          }}
          .greeting {{
            font-size: 16px;
            color: #1f2937;
            margin-bottom: 24px;
          }}
          .greeting strong {{
            color: #667eea;
          }}
          .report-card {{
            background: #f9fafb;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            padding: 24px;
            margin: 24px 0;
          }}
          .report-row {{
            display: flex;
            justify-content: space-between;
            padding: 12px 0;
            border-bottom: 1px solid #e5e7eb;
          }}
          .report-row:last-child {{
            border-bottom: none;
          }}
          .report-label {{
            font-weight: 600;
            color: #6b7280;
            font-size: 14px;
          }}
          .report-value {{
            color: #1f2937;
            font-weight: 500;
          }}
          .grade-display {{
            background: {grade_bg};
            border: 2px solid {grade_color};
            border-radius: 8px;
            padding: 20px;
            text-align: center;
            margin: 24px 0;
          }}
          .grade-display .label {{
            color: #6b7280;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
          }}
          .grade-display .grade {{
            font-size: 48px;
            font-weight: 700;
            color: {grade_color};
            margin: 0;
          }}
          .grade-display .percentage {{
            font-size: 18px;
            color: {grade_color};
            margin: 8px 0 0 0;
          }}
          .grade-display .gpa {{
            font-size: 14px;
            color: #6b7280;
            margin: 8px 0 0 0;
          }}
          .status {{
            background: {remarks_color};
            color: white;
            padding: 12px 16px;
            border-radius: 6px;
            text-align: center;
            font-weight: 600;
            margin: 16px 0;
          }}
          .message-box {{
            background: #fef3c7;
            border-left: 4px solid #f59e0b;
            padding: 16px;
            margin: 24px 0;
            border-radius: 4px;
          }}
          .message-box strong {{
            color: #92400e;
          }}
          .message-box p {{
            margin: 8px 0;
            color: #78350f;
            font-size: 14px;
          }}
          .footer {{
            background: #f3f4f6;
            padding: 20px;
            text-align: center;
            border-top: 1px solid #e5e7eb;
            font-size: 12px;
            color: #6b7280;
          }}
          .divider {{
            height: 1px;
            background: #e5e7eb;
            margin: 24px 0;
          }}
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>📊 Grade Report</h1>
            <p>PhotoSync Academic System</p>
          </div>
          
          <div class="content">
            <div class="greeting">
              Dear <strong>{student_name}</strong>,
            </div>
            
            <p style="color: #4b5563; line-height: 1.6;">
              Your grade report for <strong>{subject_code} - {subject_name}</strong> is now available. 
              Please review your performance details below.
            </p>
            
            <div class="report-card">
              <div class="report-row">
                <span class="report-label">Exam Name</span>
                <span class="report-value">{exam_name}</span>
              </div>
              <div class="report-row">
                <span class="report-label">Subject Code</span>
                <span class="report-value">{subject_code}</span>
              </div>
              <div class="report-row">
                <span class="report-label">Subject Name</span>
                <span class="report-value">{subject_name}</span>
              </div>
            </div>
            
            <div class="grade-display">
              <div class="label">Your Grade</div>
              <div class="grade">{grade}</div>
              <div class="percentage">{percentage:.1f}%</div>
              <div class="gpa">Grade Point: {grade_point:.2f}</div>
            </div>
            
            <div class="status">{remarks}</div>
            
            {f'<div class="message-box"><strong>📝 Message from Instructor:</strong><p>{custom_message}</p></div>' if custom_message else ''}
            
            <div class="divider"></div>
            
            <p style="color: #6b7280; font-size: 13px; line-height: 1.6;">
              If you have any questions about your grade, please contact your instructor or visit the PhotoSync portal 
              to view more details about your academic performance.
            </p>
          </div>
          
          <div class="footer">
            <p style="margin: 0;">This is an automated message from PhotoSync Academic System</p>
            <p style="margin: 4px 0 0 0;">Generated on {datetime.now().strftime('%B %d, %Y at %I:%M %p')}</p>
          </div>
        </div>
      </body>
    </html>
    """


def transcript_template(
    student_name: str,
    student_id: str,
    course: str,
    year_level: str,
    transcript_rows: str,
    gpa: float,
    custom_message: str = None,
) -> str:
    """
    Enhanced official grade transcript template with professional styling.
    """
    # GPA color coding
    if gpa >= 3.5:
        gpa_color = "#10b981"
        gpa_bg = "#ecfdf5"
    elif gpa >= 3.0:
        gpa_color = "#3b82f6"
        gpa_bg = "#eff6ff"
    elif gpa >= 2.5:
        gpa_color = "#f59e0b"
        gpa_bg = "#fffbeb"
    else:
        gpa_color = "#ef4444"
        gpa_bg = "#fef2f2"
    
    return f"""
    <!DOCTYPE html>
    <html>
      <head>
        <meta charset="utf-8">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <style>
          body {{
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            margin: 0;
            padding: 20px;
          }}
          .container {{
            max-width: 700px;
            margin: 0 auto;
            background: white;
            border-radius: 12px;
            box-shadow: 0 20px 60px rgba(0, 0, 0, 0.15);
            overflow: hidden;
          }}
          .header {{
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            color: white;
            padding: 40px 20px;
            text-align: center;
            border-bottom: 4px solid #fbbf24;
          }}
          .header h1 {{
            margin: 0;
            font-size: 32px;
            font-weight: 700;
          }}
          .header p {{
            margin: 8px 0 0 0;
            opacity: 0.9;
            font-size: 14px;
          }}
          .content {{
            padding: 40px;
          }}
          .student-info {{
            background: #f9fafb;
            border: 2px solid #e5e7eb;
            border-radius: 8px;
            padding: 20px;
            margin-bottom: 30px;
          }}
          .info-row {{
            display: flex;
            justify-content: space-between;
            padding: 10px 0;
            border-bottom: 1px solid #e5e7eb;
          }}
          .info-row:last-child {{
            border-bottom: none;
          }}
          .info-label {{
            font-weight: 600;
            color: #6b7280;
            font-size: 13px;
          }}
          .info-value {{
            color: #1f2937;
            font-weight: 500;
          }}
          .section-title {{
            font-size: 18px;
            font-weight: 700;
            color: #1f2937;
            margin: 30px 0 16px 0;
            padding-bottom: 8px;
            border-bottom: 2px solid #667eea;
          }}
          .transcript-table {{
            width: 100%;
            border-collapse: collapse;
            margin-bottom: 30px;
          }}
          .transcript-table thead {{
            background: #f3f4f6;
          }}
          .transcript-table th {{
            padding: 12px;
            text-align: left;
            font-weight: 600;
            color: #374151;
            font-size: 13px;
            border-bottom: 2px solid #d1d5db;
          }}
          .transcript-table td {{
            padding: 12px;
            border-bottom: 1px solid #e5e7eb;
            color: #1f2937;
            font-size: 14px;
          }}
          .transcript-table tbody tr:hover {{
            background: #f9fafb;
          }}
          .gpa-box {{
            background: {gpa_bg};
            border: 2px solid {gpa_color};
            border-radius: 8px;
            padding: 24px;
            text-align: center;
            margin: 30px 0;
          }}
          .gpa-box .label {{
            color: #6b7280;
            font-size: 12px;
            font-weight: 600;
            text-transform: uppercase;
            letter-spacing: 0.5px;
            margin-bottom: 8px;
          }}
          .gpa-box .value {{
            font-size: 56px;
            font-weight: 700;
            color: {gpa_color};
            margin: 0;
          }}
          .gpa-box .scale {{
            font-size: 12px;
            color: #6b7280;
            margin-top: 8px;
          }}
          .message-box {{
            background: #fef3c7;
            border-left: 4px solid #f59e0b;
            padding: 16px;
            margin: 24px 0;
            border-radius: 4px;
          }}
          .message-box strong {{
            color: #92400e;
          }}
          .message-box p {{
            margin: 8px 0;
            color: #78350f;
            font-size: 14px;
          }}
          .footer {{
            background: #f3f4f6;
            padding: 20px;
            text-align: center;
            border-top: 1px solid #e5e7eb;
            font-size: 11px;
            color: #6b7280;
          }}
          .divider {{
            height: 1px;
            background: #e5e7eb;
            margin: 24px 0;
          }}
        </style>
      </head>
      <body>
        <div class="container">
          <div class="header">
            <h1>📜 Official Grade Transcript</h1>
            <p>PhotoSync Academic System</p>
          </div>
          
          <div class="content">
            <div class="student-info">
              <div class="info-row">
                <span class="info-label">Student Name</span>
                <span class="info-value">{student_name}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Student ID</span>
                <span class="info-value">{student_id}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Course</span>
                <span class="info-value">{course}</span>
              </div>
              <div class="info-row">
                <span class="info-label">Year Level</span>
                <span class="info-value">{year_level}</span>
              </div>
            </div>
            
            <h2 class="section-title">📚 Academic Record</h2>
            <table class="transcript-table">
              <thead>
                <tr>
                  <th>Subject Code</th>
                  <th>Subject Name</th>
                  <th style="text-align: center;">Units</th>
                  <th style="text-align: center;">Average Grade</th>
                </tr>
              </thead>
              <tbody>
                {transcript_rows}
              </tbody>
            </table>
            
            <div class="gpa-box">
              <div class="label">Cumulative GPA</div>
              <div class="value">{gpa:.2f}</div>
              <div class="scale">Scale: 0.00 - 4.00</div>
            </div>
            
            {f'<div class="message-box"><strong>📝 Message from Instructor:</strong><p>{custom_message}</p></div>' if custom_message else ''}
            
            <div class="divider"></div>
            
            <p style="color: #6b7280; font-size: 13px; line-height: 1.6;">
              This is your official academic transcript from PhotoSync. It contains a complete record of your grades 
              and academic performance. For inquiries or clarifications, please contact your academic advisor.
            </p>
          </div>
          
          <div class="footer">
            <p style="margin: 0;">📋 Official Document - PhotoSync Academic System</p>
            <p style="margin: 4px 0 0 0;">Generated on {datetime.now().strftime('%B %d, %Y at %I:%M %p')}</p>
          </div>
        </div>
      </body>
    </html>
    """
