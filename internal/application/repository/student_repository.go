package repository

import (
	"context"

	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type studentRepository struct {
	db *gorm.DB
}

func NewStudentRepository(db *gorm.DB) repository.StudentRepository {
	return &studentRepository{
		db: db,
	}
}

func (r *studentRepository) Create(ctx context.Context, student *entity.Student) error {
	return r.db.WithContext(ctx).Create(student).Error
}

func (r *studentRepository) Update(ctx context.Context, student *entity.Student) error {
	return r.db.WithContext(ctx).Save(student).Error
}

func (r *studentRepository) Delete(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Delete(&entity.Student{}, id).Error
}

func (r *studentRepository) FindByID(ctx context.Context, id uuid.UUID) (*entity.Student, error) {
	var student entity.Student
	err := r.db.WithContext(ctx).First(&student, id).Error
	if err != nil {
		return nil, err
	}
	return &student, nil
}

func (r *studentRepository) FindByEmail(ctx context.Context, email string) (*entity.Student, error) {
	var student entity.Student
	err := r.db.WithContext(ctx).Where("email = ?", email).First(&student).Error
	if err != nil {
		return nil, err
	}
	return &student, nil
}

func (r *studentRepository) FindAll(ctx context.Context) ([]entity.Student, error) {
	var students []entity.Student
	err := r.db.WithContext(ctx).Find(&students).Error
	if err != nil {
		return nil, err
	}
	return students, nil
} 