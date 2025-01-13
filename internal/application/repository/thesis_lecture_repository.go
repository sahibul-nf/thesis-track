package repository

import (
	"context"

	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type thesisLectureRepository struct {
	db *gorm.DB
}

func NewThesisLectureRepository(db *gorm.DB) repository.ThesisLectureRepository {
	return &thesisLectureRepository{
		db: db,
	}
}

func (r *thesisLectureRepository) Create(ctx context.Context, thesisLecture *entity.ThesisLecture) error {
	return r.db.WithContext(ctx).Create(thesisLecture).Error
}

func (r *thesisLectureRepository) Update(ctx context.Context, thesisLecture *entity.ThesisLecture) error {
	return r.db.WithContext(ctx).Save(thesisLecture).Error
}

func (r *thesisLectureRepository) Delete(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Delete(&entity.ThesisLecture{}, id).Error
}

func (r *thesisLectureRepository) FindByID(ctx context.Context, id uuid.UUID) (*entity.ThesisLecture, error) {
	var thesisLecture entity.ThesisLecture
	err := r.db.WithContext(ctx).
		Preload("Thesis").
		Preload("Thesis.Student").
		Preload("Lecture").
		First(&thesisLecture, id).Error
	if err != nil {
		return nil, err
	}
	return &thesisLecture, nil
}

func (r *thesisLectureRepository) FindByThesisID(ctx context.Context, thesisID uuid.UUID) ([]entity.ThesisLecture, error) {
	var thesisLectures []entity.ThesisLecture
	err := r.db.WithContext(ctx).
		Preload("Thesis").
		Preload("Thesis.Student").
		Preload("Lecture").
		Where("thesis_id = ?", thesisID).
		Find(&thesisLectures).Error
	if err != nil {
		return nil, err
	}
	return thesisLectures, nil
}

func (r *thesisLectureRepository) FindByLectureID(ctx context.Context, lectureID uuid.UUID) ([]entity.ThesisLecture, error) {
	var thesisLectures []entity.ThesisLecture
	err := r.db.WithContext(ctx).
		Preload("Thesis").
		Preload("Thesis.Student").
		Preload("Lecture").
		Where("lecture_id = ?", lectureID).
		Find(&thesisLectures).Error
	if err != nil {
		return nil, err
	}
	return thesisLectures, nil
} 

func (r *thesisLectureRepository) FindByThesisAndLecture(ctx context.Context, thesisID, lectureID uuid.UUID) (*entity.ThesisLecture, error) {
	var thesisLecture entity.ThesisLecture
	err := r.db.WithContext(ctx).
		Where("thesis_id = ? AND lecture_id = ?", thesisID, lectureID).
		First(&thesisLecture).Error
	if err != nil {
		return nil, err
	}
	return &thesisLecture, nil
}