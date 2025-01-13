package repository

import (
	"context"

	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type lectureRepository struct {
	db *gorm.DB
}

func NewLectureRepository(db *gorm.DB) repository.LectureRepository {
	return &lectureRepository{
		db: db,
	}
}

func (r *lectureRepository) Create(ctx context.Context, lecture *entity.Lecture) error {
	return r.db.WithContext(ctx).Create(lecture).Error
}

func (r *lectureRepository) Update(ctx context.Context, lecture *entity.Lecture) error {
	return r.db.WithContext(ctx).Save(lecture).Error
}

func (r *lectureRepository) Delete(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Delete(&entity.Lecture{}, id).Error
}

func (r *lectureRepository) FindByID(ctx context.Context, id uuid.UUID) (*entity.Lecture, error) {
	var lecture entity.Lecture
	err := r.db.WithContext(ctx).First(&lecture, id).Error
	if err != nil {
		return nil, err
	}
	return &lecture, nil
}

func (r *lectureRepository) FindByEmail(ctx context.Context, email string) (*entity.Lecture, error) {
	var lecture entity.Lecture
	err := r.db.WithContext(ctx).Where("email = ?", email).First(&lecture).Error
	if err != nil {
		return nil, err
	}
	return &lecture, nil
}

func (r *lectureRepository) FindAll(ctx context.Context) ([]entity.Lecture, error) {
	var lectures []entity.Lecture
	err := r.db.WithContext(ctx).Find(&lectures).Error
	if err != nil {
		return nil, err
	}
	return lectures, nil
} 