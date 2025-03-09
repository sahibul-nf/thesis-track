package repository

import (
	"context"
	"errors"

	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/repository"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type progressRepository struct {
	db *gorm.DB
}

func NewProgressRepository(db *gorm.DB) repository.ProgressRepository {
	return &progressRepository{
		db: db,
	}
}

func (r *progressRepository) Create(ctx context.Context, progress *entity.Progress) (*entity.Progress, error) {
	if err := r.db.WithContext(ctx).Create(progress).Error; err != nil {
		return nil, err
	}
	
	// Reload the progress with reviewer data
	return progress, r.db.WithContext(ctx).
		Preload("Reviewer").
		First(progress, progress.ID).Error
}

func (r *progressRepository) Update(ctx context.Context, progress *entity.Progress) (*entity.Progress, error) {
	if err := r.db.WithContext(ctx).Save(progress).Error; err != nil {
		return nil, err
	}
	
	// Reload the progress with reviewer data
	return progress, r.db.WithContext(ctx).
		Preload("Reviewer").
		First(progress, progress.ID).Error
}

func (r *progressRepository) Delete(ctx context.Context, id uuid.UUID) error {
	return r.db.WithContext(ctx).Delete(&entity.Progress{}, id).Error
}

func (r *progressRepository) FindByID(ctx context.Context, id uuid.UUID) (*entity.Progress, error) {
	var progress entity.Progress
	err := r.db.WithContext(ctx).
		Preload("Thesis").
		Preload("Thesis.Student").
		Preload("Reviewer").
		First(&progress, id).Error
	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("progress not found")
		}
		return nil, err
	}
	return &progress, nil
}

func (r *progressRepository) FindAllByThesisID(ctx context.Context, thesisID uuid.UUID) ([]entity.Progress, error) {
	var progresses []entity.Progress
	err := r.db.WithContext(ctx).
		Preload("Thesis").
		Preload("Thesis.Student").
		Preload("Reviewer").
		Where("thesis_id = ?", thesisID).
		Order("created_at DESC").
		Find(&progresses).Error
	if err != nil {
		return nil, err
	}
	return progresses, nil
}

func (r *progressRepository) FindAllByThesisIDAndLectureID(ctx context.Context, thesisID, lectureID uuid.UUID) ([]entity.Progress, error) {
	var progresses []entity.Progress
	err := r.db.WithContext(ctx).
		Preload("Thesis").
		Preload("Thesis.Student").
		Preload("Reviewer").
		Where("thesis_id = ? AND reviewer_id = ?", thesisID, lectureID).
		Find(&progresses).Error
	if err != nil {
		return nil, err
	}
	return progresses, nil
}

func (r *progressRepository) FindAllByThesisIDAndLectureIDAndStatus(ctx context.Context, thesisID, lectureID uuid.UUID, status string) ([]entity.Progress, error) {
	var progresses []entity.Progress
	err := r.db.WithContext(ctx).
		Preload("Thesis").
		Preload("Thesis.Student").
		Preload("Reviewer").
		Where("thesis_id = ? AND reviewer_id = ? AND status = ?", thesisID, lectureID, status).
		Find(&progresses).Error
	if err != nil {
		return nil, err
	}
	return progresses, nil
}

func (r *progressRepository) UpdateStatus(ctx context.Context, id uuid.UUID, status string, comment string) error {
	return r.db.WithContext(ctx).
		Model(&entity.Progress{}).
		Where("id = ?", id).
		Updates(map[string]interface{}{
			"status":  status,
			"comment": comment,
		}).Error
} 