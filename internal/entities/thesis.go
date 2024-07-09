package entities

import (
	"time"

	"github.com/google/uuid"
)

type Thesis struct {
	ID             uuid.UUID `gorm:"type:uuid;primary_key"`
	StudentID      uuid.UUID
	LectureID      uuid.UUID
	Title          string
	Abstract       string
	Status         string
	SubmissionDate time.Time
	CompletedDate  time.Time
}
