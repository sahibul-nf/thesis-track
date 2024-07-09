package entities

import (
    "time"
    "github.com/google/uuid"
)

type Lecture struct {
    ID        uuid.UUID `gorm:"type:uuid;primary_key"`
    Name      string
    NIDN      string
    Email     string
    Department string
    CreatedAt time.Time
}
