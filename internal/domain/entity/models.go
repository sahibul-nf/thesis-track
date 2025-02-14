package entity

import (
	"encoding/json"
	"time"

	"github.com/google/uuid"
)

type ThesisStatus string

const (
	Proposed    ThesisStatus = "Proposed" // meaning the thesis is proposed by student
	InProgress  ThesisStatus = "In Progress" // meaning the thesis is in progress by student
	DraftReady  ThesisStatus = "Draft Ready" // meaning the thesis is approved/ACC. by supervisor and ready to be reviewed by examiner
	UnderReview ThesisStatus = "Under Review" // meaning the student has submitted the final thesis document after revision expected by examiner and waiting for review by admin
	Completed   ThesisStatus = "Completed" // meaning the thesis is already approved by admin and marked as completed (final state)
)

type Student struct {
	ID         uuid.UUID `json:"id" gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
	Name       string    `json:"name"`
	NIM        string    `json:"nim" gorm:"unique"`
	Email      string    `json:"email"`
	Department string    `json:"department"`
	Year       string    `json:"year"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

type Lecture struct {
	ID         uuid.UUID `json:"id" gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
	Name       string    `json:"name"`
	NIDN       string    `json:"nidn" gorm:"unique"`
	Email      string    `json:"email"`
	Department string    `json:"department"`
	CreatedAt  time.Time `json:"created_at"`
	UpdatedAt  time.Time `json:"updated_at"`
}

type Admin struct {
	ID        uuid.UUID `json:"id" gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
	Name      string    `json:"name"`
	Email     string    `json:"email"`
	CreatedAt time.Time `json:"created_at"`
	UpdatedAt time.Time `json:"updated_at"`
}

type Thesis struct {
	ID               uuid.UUID  `json:"id" gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
	StudentID        uuid.UUID  `json:"student_id" gorm:"not null"`
	Title            string     `json:"title" gorm:"not null"`
	Abstract         string     `json:"abstract" gorm:"not null"`
	ResearchField    string     `json:"research_field" gorm:"not null"`
	Status           string     `json:"status" gorm:"default:Proposed"` // Proposed, In Progress, Draft Ready, Completed
	SubmissionDate   time.Time  `json:"submission_date" gorm:"not null"`
	CompletedDate    *time.Time `json:"completed_date,omitempty"`
	DraftDocumentURL string     `json:"draft_document_url"`
	FinalDocumentURL string     `json:"final_document_url"`
	CreatedAt        time.Time  `json:"created_at"`
	UpdatedAt        time.Time  `json:"updated_at"`

	// Relations
	Student        Student         `json:"student" gorm:"foreignKey:StudentID"`
	ThesisLectures []ThesisLecture `json:"-" gorm:"foreignKey:ThesisID"`
}

type Progress struct {
	ID                  uuid.UUID `json:"id" gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
	ThesisID            uuid.UUID `json:"thesis_id"`
	ReviewerID          uuid.UUID `json:"reviewer_id"`
	ProgressDescription string    `json:"progress_description"`
	DocumentURL         string    `json:"document_url"`
	Status              string    `json:"status" gorm:"default:Pending"` // Pending, Reviewed, Rejected
	AchievementDate     time.Time `json:"achievement_date"`
	CreatedAt           time.Time `json:"created_at"`
	UpdatedAt           time.Time `json:"updated_at"`

	// Relations
	Thesis   Thesis  `json:"-" gorm:"foreignKey:ThesisID"`
	Reviewer Lecture `json:"reviewer" gorm:"foreignKey:ReviewerID"`
}

type Comment struct {
	ID         uuid.UUID     `json:"id" gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
	ProgressID uuid.UUID     `json:"progress_id" gorm:"not null"`
	UserID     uuid.UUID     `json:"user_id" gorm:"not null"`
	UserType   string        `json:"user_type" gorm:"not null"` // Student, Lecture
	ParentID   *uuid.UUID    `json:"parent_id" gorm:"default:null"`
	Content    string        `json:"content" gorm:"not null"`
	CreatedAt  time.Time     `json:"created_at"`
	UpdatedAt  time.Time     `json:"updated_at"`

	// Relations
	Progress Progress    `json:"-" gorm:"foreignKey:ProgressID"`
	Replies  []*Comment  `json:"replies" gorm:"foreignKey:ParentID;constraint:OnUpdate:CASCADE,OnDelete:CASCADE;"`
	User     interface{} `json:"user" gorm:"-"`
}

type ThesisLecture struct {
	ID        uuid.UUID `json:"id" gorm:"type:uuid;primary_key;default:uuid_generate_v4()"`
	ThesisID  uuid.UUID `json:"thesis_id" gorm:"not null"`
	LectureID uuid.UUID `json:"lecture_id" gorm:"not null"`
	Role      string    `json:"role" gorm:"default:Supervisor"`  // Supervisor, Examiner
	ApprovedAt *time.Time `json:"approved_at"`                    // Null jika belum di-approve

	// Relations
	Thesis  Thesis  `json:"thesis" gorm:"foreignKey:ThesisID"`
	Lecture Lecture `json:"lecture" gorm:"foreignKey:LectureID"`
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
