package entity

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ThesisStatus string

const (
	ThesisPending     ThesisStatus = "Pending"      // Thesis tracking request is waiting for admin approve to can be track on the system
	ThesisInProgress  ThesisStatus = "In Progress"  // meaning the thesis is in progress by student
	ThesisUnderReview ThesisStatus = "Under Review" // meaning the examiner has reviewed the thesis and it is under review by admin with the student should upload the final document
	ThesisCompleted   ThesisStatus = "Completed"    // meaning the thesis is already approved/archived by admin and marked as completed (final state)
)

var ThesisStatuses = []ThesisStatus{
	ThesisPending,
	ThesisInProgress,
	ThesisUnderReview,
	ThesisCompleted,
}

type UserType string

const (
	StudentUser UserType = "Student"
	LectureUser UserType = "Lecture"
	AdminUser   UserType = "Admin"
)

type Student struct {
	ID         uuid.UUID      `json:"id" gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
	Name       string         `json:"name"`
	NIM        string         `json:"nim" gorm:"unique"`
	Email      string         `json:"email"`
	Department string         `json:"department"`
	Year       string         `json:"year"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`
}

type Lecture struct {
	ID         uuid.UUID      `json:"id" gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
	Name       string         `json:"name"`
	NIDN       string         `json:"nidn" gorm:"unique"`
	Email      string         `json:"email"`
	Department string         `json:"department"`
	CreatedAt  time.Time      `json:"created_at"`
	UpdatedAt  time.Time      `json:"updated_at"`
	DeletedAt  gorm.DeletedAt `json:"-" gorm:"index"`
}

type Admin struct {
	ID        uuid.UUID      `json:"id" gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
	Name      string         `json:"name"`
	Email     string         `json:"email"`
	CreatedAt time.Time      `json:"created_at"`
	UpdatedAt time.Time      `json:"updated_at"`
	DeletedAt gorm.DeletedAt `json:"-" gorm:"index"`
}

type Thesis struct {
	ID               uuid.UUID    `json:"id" gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
	StudentID        uuid.UUID    `json:"student_id" gorm:"not null"`
	SupervisorID     uuid.UUID    `json:"supervisor_id" gorm:"not null"` // Main supervisor of the thesis (request by student)
	Title            string       `json:"title" gorm:"not null"`
	Abstract         string       `json:"abstract" gorm:"not null"`
	ResearchField    string       `json:"research_field" gorm:"not null"`
	Status           ThesisStatus `json:"status" gorm:"default:Pending"` // Pending, In Progress, Under Review, Completed
	IsProposalReady  bool         `json:"is_proposal_ready" gorm:"default:false"`
	IsFinalExamReady bool         `json:"is_final_exam_ready" gorm:"default:false"`
	SubmissionDate   time.Time    `json:"submission_date" gorm:"not null"`
	CompletedDate    *time.Time   `json:"completed_date,omitempty"`
	DraftDocumentURL string       `json:"draft_document_url"`
	FinalDocumentURL string       `json:"final_document_url"`
	CreatedAt        time.Time    `json:"created_at"`
	UpdatedAt        time.Time    `json:"updated_at"`

	// Relations
	Student        Student         `json:"student" gorm:"foreignKey:StudentID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	Supervisor     Lecture         `json:"supervisor" gorm:"foreignKey:SupervisorID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	ThesisLectures []ThesisLecture `json:"-" gorm:"foreignKey:ThesisID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
}

type ProgressStatus string

const (
	ProgressPending  ProgressStatus = "Pending"
	ProgressReviewed ProgressStatus = "Reviewed"
	ProgressRejected ProgressStatus = "Rejected"
)

type Progress struct {
	ID                  uuid.UUID      `json:"id" gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
	ThesisID            uuid.UUID      `json:"thesis_id"`
	ReviewerID          uuid.UUID      `json:"reviewer_id"`
	ProgressDescription string         `json:"progress_description"`
	DocumentURL         string         `json:"document_url"`
	Status              ProgressStatus `json:"status" gorm:"default:Pending"` // Pending, Reviewed, Rejected
	AchievementDate     time.Time      `json:"achievement_date"`
	CreatedAt           time.Time      `json:"created_at"`
	UpdatedAt           time.Time      `json:"updated_at"`

	// Relations
	Thesis   Thesis  `json:"-" gorm:"foreignKey:ThesisID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
	Reviewer Lecture `json:"reviewer" gorm:"foreignKey:ReviewerID;constraint:OnUpdate:CASCADE,OnDelete:RESTRICT;"`
}

type Comment struct {
	ID         uuid.UUID  `json:"id" gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
	ProgressID uuid.UUID  `json:"progress_id" gorm:"not null"`
	UserID     uuid.UUID  `json:"user_id" gorm:"not null"`
	UserType   UserType   `json:"user_type" gorm:"not null"` // Student, Lecture
	ParentID   *uuid.UUID `json:"parent_id" gorm:"default:null"`
	Content    string     `json:"content" gorm:"not null"`
	CreatedAt  time.Time  `json:"created_at"`
	UpdatedAt  time.Time  `json:"updated_at"`

	// Relations
	Progress Progress    `json:"-" gorm:"foreignKey:ProgressID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
	Replies  []*Comment  `json:"replies" gorm:"foreignKey:ParentID;constraint:OnUpdate:CASCADE,OnDelete:SET NULL;"`
	User     interface{} `json:"user" gorm:"-"`
}

type ThesisLecture struct {
	ID                        uuid.UUID     `json:"id" gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
	ThesisID                  uuid.UUID     `json:"thesis_id" gorm:"not null"`
	LectureID                 uuid.UUID     `json:"lecture_id" gorm:"not null"`
	Role                      LectureRole   `json:"role" gorm:"default:Supervisor"`    // Supervisor, Examiner
	ExaminerType              *ExaminerType `json:"examiner_type" gorm:"default:null"` // ProposalExaminer, FinalExaminer - null for supervisors
	ProposalDefenseApprovedAt *time.Time    `json:"proposal_defense_approved_at"`      // Null jika belum disetujui for supervisors to approve proposal defense
	FinalDefenseApprovedAt    *time.Time    `json:"final_defense_approved_at"`         // Null jika belum disetujui for supervisors to approve final defense
	FinalizeApprovedAt        *time.Time    `json:"finalize_approved_at"`              // Null jika belum disetujui for examiners to finalize the thesis

	// Relations
	Thesis  Thesis  `json:"thesis" gorm:"foreignKey:ThesisID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
	Lecture Lecture `json:"lecture" gorm:"foreignKey:LectureID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
}

type ApprovalType string

const (
	ProposalDefense ApprovalType = "ProposalDefense" // for supervisors
	FinalDefense    ApprovalType = "FinalDefense"    // for supervisors
	Finalize        ApprovalType = "Finalize"        // for examiners to finalize the thesis
)

type LectureRole string

const (
	SupervisorRole LectureRole = "Supervisor"
	ExaminerRole   LectureRole = "Examiner"
)

type ExaminerType string

const (
	ProposalDefenseExaminer ExaminerType = "ProposalDefenseExaminer"
	FinalDefenseExaminer    ExaminerType = "FinalDefenseExaminer"
)

var ExaminerTypes = []ExaminerType{
	ProposalDefenseExaminer,
	FinalDefenseExaminer,
}

// Custom JSON marshaling untuk Thesis
func (t Thesis) MarshalJSON() ([]byte, error) {
	type Alias Thesis

	// Pastikan ThesisLectures tidak nil
	if t.ThesisLectures == nil {
		t.ThesisLectures = []ThesisLecture{}
	}

	supervisors := make([]Lecture, 0)
	examiners := make([]Lecture, 0)

	for _, tl := range t.ThesisLectures {
		if tl.Lecture.ID == uuid.Nil {
			continue
		}
		switch tl.Role {
		case "Supervisor":
			supervisors = append(supervisors, tl.Lecture)
		case "Examiner":
			examiners = append(examiners, tl.Lecture)
		}
	}

	return json.Marshal(&struct {
		Alias
		Supervisors []Lecture `json:"supervisors"`
		Examiners   []Lecture `json:"examiners"`
	}{
		Alias:       Alias(t),
		Supervisors: supervisors,
		Examiners:   examiners,
	})
}

func (c Comment) MarshalJSON() ([]byte, error) {
	type Alias Comment

	// Format user data berdasarkan UserType
	var userData interface{}
	switch c.UserType {
	case "Student":
		userData = c.User.(*Student)
	case "Lecture":
		userData = c.User.(*Lecture)
	}

	return json.Marshal(&struct {
		Alias
		User interface{} `json:"user"`
	}{
		Alias: Alias(c),
		User:  userData,
	})
}
