package entities

import (
	"time"

	"github.com/google/uuid"
)

type Student struct {
	ID         uuid.UUID `gorm:"type:uuid;primary_key"`
	Name       string
	NIM        string
	Email      string
	Department string
	Year       string
	CreatedAt  time.Time
}
