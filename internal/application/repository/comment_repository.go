package repository

import (
	"context"
	"fmt"
	"thesis-track/internal/domain/entity"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type commentRepository struct {
	db *gorm.DB
}

func NewCommentRepository(db *gorm.DB) *commentRepository {
	return &commentRepository{db: db}
}

func (r *commentRepository) Create(ctx context.Context, comment *entity.Comment) (*entity.Comment, error) {
	if err := r.db.WithContext(ctx).Create(comment).Error; err != nil {
		return nil, err
	}
	
	return r.FindByID(ctx, comment.ID)
}

func (r *commentRepository) FindByID(ctx context.Context, id uuid.UUID) (*entity.Comment, error) {
	var comment entity.Comment
	
	err := r.db.WithContext(ctx).
		Preload("Progress").
		Preload("Progress.Reviewer").
		Preload("Replies", func(db *gorm.DB) *gorm.DB {
			return db.Order("created_at ASC")
		}).
		First(&comment, id).Error
	if err != nil {
		return nil, err
	}

	// Load user data
	if err := r.loadUserData(ctx, &comment); err != nil {
		return nil, err
	}
	
	// Load user data for replies
	for i := range comment.Replies {
		if err := r.loadUserData(ctx, comment.Replies[i]); err != nil {
			return nil, err
		}
	}

	return &comment, nil
}

func (r *commentRepository) FindByProgressID(ctx context.Context, progressID uuid.UUID) ([]entity.Comment, error) {
	var comments []entity.Comment
	
	// Query untuk root comments
	err := r.db.WithContext(ctx).
		Preload("Progress").
		Preload("Progress.Reviewer").
		Preload("Replies", func(db *gorm.DB) *gorm.DB {
			return db.Order("created_at ASC")
		}).
		Where("progress_id = ? AND parent_id IS NULL", progressID).
		Order("created_at ASC").
		Find(&comments).Error
	if err != nil {
		return nil, err
	}

	// Load user data untuk comments dan replies
	for i := range comments {
		if err := r.loadUserData(ctx, &comments[i]); err != nil {
			return nil, err
		}
		
		for j := range comments[i].Replies {
			if err := r.loadUserData(ctx, comments[i].Replies[j]); err != nil {
				return nil, err
			}
		}
	}

	return comments, nil
}

func (r *commentRepository) loadUserData(ctx context.Context, comment *entity.Comment) error {
	switch comment.UserType {
	case "Student":
		var student entity.Student
		if err := r.db.WithContext(ctx).First(&student, comment.UserID).Error; err != nil {
			return err
		}
		comment.User = &student

	case "Lecture":
		var lecture entity.Lecture
		if err := r.db.WithContext(ctx).First(&lecture, comment.UserID).Error; err != nil {
			return err
		}
		comment.User = &lecture

	default:
		return fmt.Errorf("invalid user type: %s", comment.UserType)
	}
	
	return nil
} 