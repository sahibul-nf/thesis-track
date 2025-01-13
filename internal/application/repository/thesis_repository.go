package repository

import (
	"context"
	"errors"

	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type thesisRepository struct {
	db *gorm.DB
}

func NewThesisRepository(db *gorm.DB) repository.ThesisRepository {
	return &thesisRepository{
		db: db,
	}
}

func (r *thesisRepository) Create(ctx context.Context, thesis *entity.Thesis) error {
	if err := r.db.WithContext(ctx).Create(thesis).Error; err != nil {
		return err
	}
	return r.db.WithContext(ctx).Preload("Student").First(thesis, thesis.ID).Error
}

func (r *thesisRepository) Update(ctx context.Context, thesis *entity.Thesis) error {
	return r.db.WithContext(ctx).Save(thesis).Error
}

func (r *thesisRepository) Delete(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Delete(&entity.Thesis{}, id).Error
}

func (r *thesisRepository) FindByID(ctx context.Context, id uuid.UUID) (*entity.Thesis, error) {
	var thesis entity.Thesis
	err := r.db.WithContext(ctx).
		Preload("Student").
		Preload("ThesisLectures").
		Preload("ThesisLectures.Lecture").
		First(&thesis, id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return &thesis, nil
}

func (r *thesisRepository) FindByStudentID(ctx context.Context, studentID uuid.UUID) ([]entity.Thesis, error) {
	var theses []entity.Thesis
	err := r.db.WithContext(ctx).
		Preload("Student").
		Preload("ThesisLectures").
		Preload("ThesisLectures.Lecture").
		Where("student_id = ?", studentID).
		Find(&theses).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return theses, nil
}

func (r *thesisRepository) FindAll(ctx context.Context) ([]entity.Thesis, error) {
	var theses []entity.Thesis
	err := r.db.WithContext(ctx).
		Preload("Student").
		Preload("ThesisLectures").
		Preload("ThesisLectures.Lecture").
		Find(&theses).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, nil
		}
		return nil, err
	}
	return theses, nil
}

func (r *thesisRepository) UpdateStatus(ctx context.Context, id uuid.UUID, status string) error {
	return r.db.WithContext(ctx).
		Model(&entity.Thesis{}).
		Where("id = ?", id).
		Update("status", status).Error
} 