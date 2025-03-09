package repository

import (
	"context"

	"thesis-track/internal/domain/entity"

	"github.com/google/uuid"
)

type StudentRepository interface {
	Create(ctx context.Context, student *entity.Student) error
	Update(ctx context.Context, student *entity.Student) error
	Delete(ctx context.Context, id uuid.UUID) error
	FindByID(ctx context.Context, id uuid.UUID) (*entity.Student, error)
	FindByEmail(ctx context.Context, email string) (*entity.Student, error)
	FindAll(ctx context.Context) ([]entity.Student, error)
}

type LectureRepository interface {
	Create(ctx context.Context, lecture *entity.Lecture) error
	Update(ctx context.Context, lecture *entity.Lecture) error
	Delete(ctx context.Context, id uuid.UUID) error
	FindByID(ctx context.Context, id uuid.UUID) (*entity.Lecture, error)
	FindByEmail(ctx context.Context, email string) (*entity.Lecture, error)
	FindAll(ctx context.Context) ([]entity.Lecture, error)
}

type AdminRepository interface {
	Create(ctx context.Context, admin *entity.Admin) error
	Update(ctx context.Context, admin *entity.Admin) error
	Delete(ctx context.Context, id uuid.UUID) error
	FindByID(ctx context.Context, id uuid.UUID) (*entity.Admin, error)
	FindByEmail(ctx context.Context, email string) (*entity.Admin, error)	
} 

type ThesisRepository interface {
	Create(ctx context.Context, thesis *entity.Thesis) (*entity.Thesis, error)
	Update(ctx context.Context, thesis *entity.Thesis) error
	Delete(ctx context.Context, id uuid.UUID) error
	FindByID(ctx context.Context, id uuid.UUID) (*entity.Thesis, error)
	FindByStudentID(ctx context.Context, studentID uuid.UUID) ([]entity.Thesis, error)
	FindAll(ctx context.Context) ([]entity.Thesis, error)
	UpdateStatus(ctx context.Context, id uuid.UUID, status string) error
	FindByLectureID(ctx context.Context, lectureID uuid.UUID, lectureRole string) ([]entity.Thesis, error)
}

type ProgressRepository interface {
	Create(ctx context.Context, progress *entity.Progress) (*entity.Progress, error)
	Update(ctx context.Context, progress *entity.Progress) (*entity.Progress, error)
	Delete(ctx context.Context, id uuid.UUID) error
	FindByID(ctx context.Context, id uuid.UUID) (*entity.Progress, error)
	FindAllByThesisID(ctx context.Context, thesisID uuid.UUID) ([]entity.Progress, error)
	FindAllByThesisIDAndLectureID(ctx context.Context, thesisID, lectureID uuid.UUID) ([]entity.Progress, error)
	FindAllByThesisIDAndLectureIDAndStatus(ctx context.Context, thesisID, lectureID uuid.UUID, status string) ([]entity.Progress, error)
	UpdateStatus(ctx context.Context, id uuid.UUID, status string, comment string) error
}

type ThesisLectureRepository interface {
	Create(ctx context.Context, thesisLecture *entity.ThesisLecture) (*entity.ThesisLecture, error)
	Update(ctx context.Context, thesisLecture *entity.ThesisLecture) error
	Delete(ctx context.Context, id uuid.UUID) error
	FindByID(ctx context.Context, id uuid.UUID) (*entity.ThesisLecture, error)
	FindByThesisID(ctx context.Context, thesisID uuid.UUID) ([]entity.ThesisLecture, error)
	FindByLectureID(ctx context.Context, lectureID uuid.UUID) ([]entity.ThesisLecture, error)
	FindByThesisAndLecture(ctx context.Context, thesisID, lectureID uuid.UUID) (*entity.ThesisLecture, error)
} 

type CommentRepository interface {
	Create(ctx context.Context, comment *entity.Comment) (*entity.Comment, error)
	FindByProgressID(ctx context.Context, progressID uuid.UUID) ([]entity.Comment, error)
	FindByID(ctx context.Context, id uuid.UUID) (*entity.Comment, error)
}