package entities

import (
	"time"

	"github.com/google/uuid"
)

type Progress struct {
	ID                  uuid.UUID `gorm:"type:uuid;primary_key"`
	ThesisID            uuid.UUID
	ProgressDescription string
	DocumentURL         string
	Status              string
	Comment             string
	AchievementDate     time.Time
}
