package service

import (
	"context"
	"fmt"
	"log"
	"strconv"
	"strings"
	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/service"

	"github.com/google/uuid"
	gomail "gopkg.in/gomail.v2"
)

type emailService struct {
	smtpHost        string
	smtpPort        string
	smtpUsername    string
	smtpPassword    string
	smtpSenderEmail string
	smtpSenderName  string
}

func NewEmailService(smtpHost string, smtpPort string, smtpUsername string, smtpPassword string, smtpSenderEmail string, smtpSenderName string) service.EmailService {
	return &emailService{
		smtpHost:        smtpHost,
		smtpPort:        smtpPort,
		smtpUsername:    smtpUsername,
		smtpPassword:    smtpPassword,
		smtpSenderEmail: smtpSenderEmail,
		smtpSenderName:  smtpSenderName,
	}
}

func (s *emailService) sendEmail(to string, subject string, body string) error {
	m := gomail.NewMessage()
	m.SetHeader("From", s.smtpSenderEmail)
	m.SetHeader("To", to)
	m.SetHeader("Subject", subject)
	m.SetBody("text/html", body)

	port, err := strconv.Atoi(s.smtpPort)
	if err != nil {
		return err
	}

	d := gomail.Dialer{
		Host:     s.smtpHost,
		Port:     port,
		Username: s.smtpUsername,
		Password: s.smtpPassword,
	}

	return d.DialAndSend(m)
}

func (s *emailService) SendThesisSubmissionNotification(ctx context.Context, to string, studentName string, thesisTitle string, supervisorName string) error {
	subject := "📚 New Thesis Proposal Submission"
	body := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
			<div style="max-width: 600px; margin: 0 auto; padding: 20px;">
				<h2 style="color: #2c3e50; border-bottom: 2px solid #3498db; padding-bottom: 10px;">New Thesis Proposal Submission</h2>
				
				<p style="margin: 20px 0;">Dear Admin,</p>
				
				<div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
					<p style="margin: 0;">A new thesis proposal has been submitted for tracking:</p>
					<ul style="list-style-type: none; padding-left: 0;">
						<li style="margin: 10px 0;"><strong>Student:</strong> %s</li>
						<li style="margin: 10px 0;"><strong>Title:</strong> %s</li>
						<li style="margin: 10px 0;"><strong>Requested Supervisor:</strong> %s</li>
					</ul>
				</div>

				<p>Please review and process the thesis proposal submission in the tracking system.</p>

				<div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
					<p style="margin: 0;">Best regards,<br>%s</p>
				</div>
			</div>
		</body>
		</html>
	`, studentName, thesisTitle, supervisorName, s.smtpSenderName)

	return s.sendEmail(to, subject, body)
}

func (s *emailService) SendThesisApprovedNotification(ctx context.Context, to string, studentName string, thesisTitle string) error {
	subject := "✅ Thesis Proposal Approved"
	body := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
			<div style="max-width: 600px; margin: 0 auto; padding: 20px;">
				<h2 style="color: #2c3e50; border-bottom: 2px solid #27ae60; padding-bottom: 10px;">Thesis Proposal Approved</h2>
				
				<p style="margin: 20px 0;">Dear %s,</p>
				
				<div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
					<p style="margin: 0;">Your thesis proposal has been approved and registered in the tracking system:</p>
					<ul style="list-style-type: none; padding-left: 0;">
						<li style="margin: 10px 0;"><strong>Title:</strong> %s</li>
					</ul>
				</div>

				<p>You can now start working on your thesis and submit your progress through the system. Please coordinate with your supervisor for the next steps.</p>

				<div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
					<p style="margin: 0;">Best regards,<br>%s</p>
				</div>
			</div>
		</body>
		</html>
	`, studentName, thesisTitle, s.smtpSenderName)

	return s.sendEmail(to, subject, body)
}

func (s *emailService) SendProgressSubmissionNotification(ctx context.Context, to string, studentName string, progressTitle string) error {
	subject := "📝 New Progress Report Submission"
	body := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
			<div style="max-width: 600px; margin: 0 auto; padding: 20px;">
				<h2 style="color: #2c3e50; border-bottom: 2px solid #27ae60; padding-bottom: 10px;">New Progress Report Submission</h2>
				
				<p style="margin: 20px 0;">Dear Lecturer,</p>
				
				<div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
					<p style="margin: 0;">A new progress report has been submitted for your review:</p>
					<ul style="list-style-type: none; padding-left: 0;">
						<li style="margin: 10px 0;"><strong>Student:</strong> %s</li>
						<li style="margin: 10px 0;"><strong>Progress Title:</strong> %s</li>
					</ul>
				</div>

				<p>Your timely review will help maintain the student's momentum in their research journey. Please provide your feedback through the system.</p>

				<div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
					<p style="margin: 0;">Best regards,<br>%s</p>
				</div>
			</div>
		</body>
		</html>
	`, studentName, progressTitle, s.smtpSenderName)

	return s.sendEmail(to, subject, body)
}

func (s *emailService) SendProgressApprovalNotification(ctx context.Context, to string, studentName string, progressTitle string, status string) error {
	var statusColor, statusEmoji string
	switch status {
	case "Approved":
		statusColor = "#27ae60"
		statusEmoji = "✅"
	case "Rejected":
		statusColor = "#e74c3c"
		statusEmoji = "❌"
	default: // Pending
		statusColor = "#f1c40f"
		statusEmoji = "⏳"
	}

	subject := fmt.Sprintf("%s Progress Report Status Update", statusEmoji)
	body := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
			<div style="max-width: 600px; margin: 0 auto; padding: 20px;">
				<h2 style="color: #2c3e50; border-bottom: 2px solid %s; padding-bottom: 10px;">Progress Report Review Update</h2>
				
				<p style="margin: 20px 0;">Dear %s,</p>
				
				<div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
					<p style="margin: 0;">Your progress report has been reviewed:</p>
					<ul style="list-style-type: none; padding-left: 0;">
						<li style="margin: 10px 0;"><strong>Progress Title:</strong> %s</li>
						<li style="margin: 10px 0;">
							<strong>Status:</strong> 
							<span style="color: %s; font-weight: bold;">%s</span>
						</li>
					</ul>
				</div>

				<p>Please check your dashboard for detailed feedback and next steps.</p>

				<div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
					<p style="margin: 0;">Best regards,<br>%s</p>
				</div>
			</div>
		</body>
		</html>
	`, statusColor, studentName, progressTitle, statusColor, status, s.smtpSenderName)

	return s.sendEmail(to, subject, body)
}

func (s *emailService) SendThesisCompletedNotification(ctx context.Context, to string, receiverRole string, thesis *entity.Thesis) error {
	thesisTitle := thesis.Title
	studentInfo := fmt.Sprintf("%s (%s)", thesis.Student.Name, thesis.Student.NIM)
	var supervisorInfo []string
	var examinerInfo []string

	for _, supervisor := range thesis.ThesisLectures {
		if supervisor.Role == entity.SupervisorRole {
			supervisorInfo = append(supervisorInfo, fmt.Sprintf("%s (%s)", supervisor.Lecture.Name, supervisor.Lecture.NIDN))
		}

		if supervisor.Role == entity.ExaminerRole {
			examinerInfo = append(examinerInfo, fmt.Sprintf("%s (%s)", supervisor.Lecture.Name, supervisor.Lecture.NIDN))
		}
	}

	supervisorInfoString := strings.Join(supervisorInfo, "</li><li>")
	examinerInfoString := strings.Join(examinerInfo, "</li><li>")

	subject := "🎉 Thesis Completed"
	body := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
			<div style="max-width: 600px; margin: 0 auto; padding: 20px;">
				<h2 style="color: #2c3e50; border-bottom: 2px solid #27ae60; padding-bottom: 10px;">Thesis Completed</h2>
				
				<p style="margin: 20px 0;">Dear %s,</p>
				
				<div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
					<p style="margin: 0;">Your thesis has been completed and approved:</p>
					<ul style="list-style-type: none; padding-left: 0;">
						<li style="margin: 10px 0;"><strong>Title:</strong> %s</li>
						<li style="margin: 10px 0;"><strong>Student:</strong> %s</li>
						<li style="margin: 10px 0;">
							<strong>Supervisor's Involved:</strong>
							<ul style="list-style-type: disc; margin: 5px 0 5px 20px;">
								%s
							</ul>
						</li>
						<li style="margin: 10px 0;">
							<strong>Examiner's Involved:</strong>
							<ul style="list-style-type: disc; margin: 5px 0 5px 20px;">
								%s
							</ul>
						</li>
					</ul>
				</div>

				<p>Congratulations on completing your thesis! Your hard work has been recognized.</p>

				<div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
					<p style="margin: 0;">Best regards,<br>%s</p>
				</div>
			</div>
		</body>
		</html>
	`, receiverRole, thesisTitle, studentInfo,
		supervisorInfoString,
		examinerInfoString,
		s.smtpSenderName,
	)

	return s.sendEmail(to, subject, body)
}

func (s *emailService) SendThesisProposalNotification(ctx context.Context, to string, thesis *entity.Thesis) error {
	studentName := thesis.Student.Name
	studentNIM := thesis.Student.NIM
	thesisTitle := thesis.Title
	supervisorName := thesis.Supervisor.Name
	supervisorNIDN := thesis.Supervisor.NIDN

	receiverRole := ""

	if thesis.SupervisorID != uuid.Nil {
		receiverRole = "Supervisor"
	}

	subject := "📚 New Thesis Proposal Submission"
	body := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
			<div style="max-width: 600px; margin: 0 auto; padding: 20px;">
				<h2 style="color: #2c3e50; border-bottom: 2px solid #f1c40f; padding-bottom: 10px;">New Thesis Proposal Submission</h2>
				
				<p style="margin: 20px 0;">Dear %s,</p>
				
				<div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
					<p style="margin: 0;">A new thesis proposal has been submitted and is waiting for admin approval:</p>
					<ul style="list-style-type: none; padding-left: 0;">
						<li style="margin: 10px 0;"><strong>Student:</strong> %s (%s)</li>
						<li style="margin: 10px 0;"><strong>Title:</strong> %s</li>
						<li style="margin: 10px 0;"><strong>Requested Supervisor:</strong> %s (%s)</li>
					</ul>
				</div>

				<p>Please wait for admin approval. You will be notified once the proposal is approved to start tracking this thesis.</p>

				<div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
					<p style="margin: 0;">Best regards,<br>%s</p>
				</div>
			</div>
		</body>
		</html>
	`, receiverRole, studentName, studentNIM, thesisTitle, supervisorName, supervisorNIDN, s.smtpSenderName)

	return s.sendEmail(to, subject, body)
}

func (s *emailService) SendThesisLectureAssignedNotification(ctx context.Context, to string, assignerRole string, thesis *entity.Thesis) error {
	studentInfo := fmt.Sprintf("%s (%s)", thesis.Student.Name, thesis.Student.NIM)
	var supervisorInfo []string

	for _, supervisor := range thesis.ThesisLectures {
		if supervisor.Role == entity.SupervisorRole {
			supervisorInfo = append(supervisorInfo, fmt.Sprintf("%s (%s)", supervisor.Lecture.Name, supervisor.Lecture.NIDN))
		}
	}

	supervisorInfoString := strings.Join(supervisorInfo, "</li><li>")

	subject := "🎓 Thesis Lecture Assigned"
	body := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
			<div style="max-width: 600px; margin: 0 auto; padding: 20px;">
				<h2 style="color: #2c3e50; border-bottom: 2px solid #f1c40f; padding-bottom: 10px;">Thesis Lecture Assigned</h2>

				<p style="margin: 20px 0;">Dear Lecturer,</p>

				<div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
					<p style="margin: 0;">You have been assigned as a thesis <strong>%s</strong> for the following thesis:</p>
					<ul style="list-style-type: none; padding-left: 0;">
						<li style="margin: 10px 0;"><strong>Title:</strong> %s</li>
						<li style="margin: 10px 0;"><strong>Student:</strong> %s</li>
						<li style="margin: 10px 0;">
							<strong>Supervisor:</strong>
							<ul style="list-style-type: disc; margin: 5px 0 5px 20px;">
								%s
							</ul>
						</li>
					</ul>
				</div>

				<p>Now you can access the thesis and submit your feedback.</p>

				<div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
					<p style="margin: 0;">Best regards,<br>%s</p>
				</div>
			</div>
		</body>
		</html>
	`, assignerRole, thesis.Title, studentInfo, supervisorInfoString, s.smtpSenderName)

	return s.sendEmail(to, subject, body)
}

func (s *emailService) SendThesisReadyForExamNotification(ctx context.Context, to string, thesis *entity.Thesis, examType string) error {
	var examTypeText, examIcon string
	if examType == "Proposal" {
		examTypeText = "Proposal Defense"
		examIcon = "📝"
	} else {
		examTypeText = "Final Defense"
		examIcon = "🎓"
	}

	subject := fmt.Sprintf("%s Thesis Ready for %s Exam", examIcon, examType)
	body := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
			<div style="max-width: 600px; margin: 0 auto; padding: 20px;">
				<h2 style="color: #2c3e50; border-bottom: 2px solid #27ae60; padding-bottom: 10px;">Thesis Ready for %s</h2>
				
				<p style="margin: 20px 0;">Dear %s,</p>
				
				<div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
					<p style="margin: 0;">Your thesis has been approved by all supervisors and is now ready for the %s:</p>
					<ul style="list-style-type: none; padding-left: 0;">
						<li style="margin: 10px 0;"><strong>Title:</strong> %s</li>
						<li style="margin: 10px 0;"><strong>Supervisors:</strong></li>
						<ul style="list-style-type: disc; margin: 5px 0 5px 20px;">
							%s
						</ul>
					</ul>
				</div>

				<p>Please coordinate with your academic advisor for the next steps in scheduling your %s.</p>

				<div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
					<p style="margin: 0;">Best regards,<br>%s</p>
				</div>
			</div>
		</body>
		</html>
	`, examTypeText, thesis.Student.Name, examTypeText, thesis.Title,
		formatSupervisorsList(thesis.ThesisLectures),
		examTypeText, s.smtpSenderName)

	return s.sendEmail(to, subject, body)
}

func (s *emailService) SendThesisReadyForFinalSubmissionNotification(ctx context.Context, to string, thesis *entity.Thesis) error {
	subject := "🎉 Thesis Approved - Ready for Final Submission"
	body := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
			<div style="max-width: 600px; margin: 0 auto; padding: 20px;">
				<h2 style="color: #2c3e50; border-bottom: 2px solid #27ae60; padding-bottom: 10px;">Thesis Approved by Examiners</h2>
				
				<p style="margin: 20px 0;">Dear %s,</p>
				
				<div style="background-color: #f8f9fa; padding: 15px; border-radius: 5px; margin: 20px 0;">
					<p style="margin: 0;">Congratulations! Your thesis has been approved by all examiners:</p>
					<ul style="list-style-type: none; padding-left: 0;">
						<li style="margin: 10px 0;"><strong>Title:</strong> %s</li>
						<li style="margin: 10px 0;"><strong>Examiners:</strong></li>
						<ul style="list-style-type: disc; margin: 5px 0 5px 20px;">
							%s
						</ul>
					</ul>
				</div>

				<p style="color: #e67e22; font-weight: bold;">Next Steps:</p>
				<ol style="margin: 10px 0 20px 0;">
					<li>Prepare your final thesis document incorporating all feedback</li>
					<li>Submit the final document through the system for admin verification</li>
					<li>Wait for admin approval of your final submission</li>
				</ol>

				<div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
					<p style="margin: 0;">Best regards,<br>%s</p>
				</div>
			</div>
		</body>
		</html>
	`, thesis.Student.Name, thesis.Title,
		formatFinalDefenseExaminersList(thesis.ThesisLectures),
		s.smtpSenderName)

	return s.sendEmail(to, subject, body)
}

func (s *emailService) SendThesisFinalDocumentUploadedNotification(ctx context.Context, studentEmail string, thesis *entity.Thesis) error {
	studentName := thesis.Student.Name
	thesisTitle := thesis.Title
	documentURL := thesis.FinalDocumentURL

	subject := "📚 Final Thesis Document Archive"
	
	// Send to student
	studentBody := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
			<div style="max-width: 600px; margin: 0 auto; padding: 20px;">
				<h2 style="color: #2c3e50;">Final Thesis Document Archived</h2>
				
				<p>Dear %s,</p>

				<p>Your final thesis document for <strong>"%s"</strong> has been successfully archived in our system.</p>

				<p>Please ensure you have provided the required hard/soft copies to your supervisors and final defense examiners as per the traditional process.</p>

				<p>Document Link: <a href="%s" style="color: #3498db;">Access Document</a></p>

				<div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
					<p style="margin: 0;">Best regards,<br>%s</p>
				</div>
			</div>
		</body>
		</html>
	`, studentName, thesisTitle, documentURL, s.smtpSenderName)

	err := s.sendEmail(studentEmail, subject, studentBody)
	if err != nil {
		return fmt.Errorf("failed to send email to student: %w", err)
	}

	// Send only to supervisors and final defense examiners
	lectureBody := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
			<div style="max-width: 600px; margin: 0 auto; padding: 20px;">
				<h2 style="color: #2c3e50;">Final Thesis Document Archive Notice</h2>
				
				<p>Dear Sir/Madam,</p>

				<p>This is to inform you that the final thesis document has been archived in our system for:</p>
				<ul style="margin: 10px 0;">
					<li>Student: %s</li>
					<li>Thesis Title: %s</li>
				</ul>

				<p>You can access the archived document through this link if needed:</p>
				<p><a href="%s" style="color: #3498db;">Access Document</a></p>

				<p>Note: The student should provide you with the required hard/soft copy separately as per the traditional process.</p>

				<div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
					<p style="margin: 0;">Best regards,<br>%s</p>
				</div>
			</div>
		</body>
		</html>
	`, studentName, thesisTitle, documentURL, s.smtpSenderName)

	// Send only to supervisors and final defense examiners
	for _, thesisLecture := range thesis.ThesisLectures {
		// Skip if not a supervisor or final defense examiner
		if thesisLecture.Role != entity.SupervisorRole && 
		   (thesisLecture.ExaminerType == nil || *thesisLecture.ExaminerType != entity.FinalDefenseExaminer) {
			continue
		}

		err = s.sendEmail(thesisLecture.Lecture.Email, subject, lectureBody)
		if err != nil {
			// Log error but continue sending to other recipients
			log.Printf("Failed to send email to %s: %v", thesisLecture.Lecture.Email, err)
		}
	}

	return nil
}

func (s *emailService) SendThesisDraftDocumentUploadedNotification(ctx context.Context, studentEmail string, thesis *entity.Thesis) error {
	studentName := thesis.Student.Name
	thesisTitle := thesis.Title
	documentURL := thesis.DraftDocumentURL

	subject := "📝 Thesis Draft Document Available for Final Defense"
	
	// Send to student
	studentBody := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
			<div style="max-width: 600px; margin: 0 auto; padding: 20px;">
				<h2 style="color: #2c3e50;">Thesis Draft Document Uploaded</h2>
				
				<p>Dear %s,</p>

				<p>Your thesis draft document for <strong>"%s"</strong> has been successfully uploaded.</p>

				<p>Important Reminders:</p>
				<ul style="margin: 10px 0;">
					<li>Please ensure to provide hard copies of your draft to your supervisors and final defense examiners at least one day before the defense.</li>
					<li>This will allow them to properly review your work before the defense session.</li>
				</ul>

				<p>Document Link: <a href="%s" style="color: #3498db;">Access Document</a></p>

				<div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
					<p style="margin: 0;">Best regards,<br>%s</p>
				</div>
			</div>
		</body>
		</html>
	`, studentName, thesisTitle, documentURL, s.smtpSenderName)

	err := s.sendEmail(studentEmail, subject, studentBody)
	if err != nil {
		return fmt.Errorf("failed to send email to student: %w", err)
	}

	// Send to supervisors and final defense examiners
	lectureBody := fmt.Sprintf(`
		<html>
		<body style="font-family: Arial, sans-serif; line-height: 1.6; color: #333;">
			<div style="max-width: 600px; margin: 0 auto; padding: 20px;">
				<h2 style="color: #2c3e50;">Thesis Draft Available for Final Defense Review</h2>
				
				<p>Dear Sir/Madam,</p>

				<p>A thesis draft has been uploaded for final defense preparation by:</p>
				<ul style="margin: 10px 0;">
					<li><strong>Student:</strong> %s</li>
					<li><strong>Thesis Title:</strong> %s</li>
				</ul>

				<p>You can access the draft document through this link:</p>
				<p><a href="%s" style="color: #3498db;">Access Document</a></p>

				<p>Note: The student will provide you with a hard copy of the draft at least one day before the defense session for your detailed review.</p>

				<div style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
					<p style="margin: 0;">Best regards,<br>%s</p>
				</div>
			</div>
		</body>
		</html>
	`, studentName, thesisTitle, documentURL, s.smtpSenderName)

	// Send only to supervisors and final defense examiners
	for _, thesisLecture := range thesis.ThesisLectures {
		// Skip if not a supervisor or final defense examiner
		if thesisLecture.Role != entity.SupervisorRole && 
		   (thesisLecture.ExaminerType == nil || *thesisLecture.ExaminerType != entity.FinalDefenseExaminer) {
			continue
		}

		err = s.sendEmail(thesisLecture.Lecture.Email, subject, lectureBody)
		if err != nil {
			// Log error but continue sending to other recipients
			log.Printf("Failed to send email to %s: %v", thesisLecture.Lecture.Email, err)
		}
	}

	return nil
}

// Helper function to format supervisors list
func formatSupervisorsList(thesisLectures []entity.ThesisLecture) string {
	var supervisors []string
	for _, tl := range thesisLectures {
		if tl.Role == entity.SupervisorRole {
			supervisors = append(supervisors, fmt.Sprintf("<li>%s (%s)</li>", tl.Lecture.Name, tl.Lecture.NIDN))
		}
	}
	return strings.Join(supervisors, "")
}

// Helper function to format final defense examiners list
func formatFinalDefenseExaminersList(thesisLectures []entity.ThesisLecture) string {
	var examiners []string
	for _, tl := range thesisLectures {
		if tl.Role == entity.ExaminerRole && tl.ExaminerType != nil && *tl.ExaminerType == entity.FinalDefenseExaminer {
			examiners = append(examiners, fmt.Sprintf("<li>%s (%s)</li>", tl.Lecture.Name, tl.Lecture.NIDN))
		}
	}
	return strings.Join(examiners, "")
}