package service

import (
	"context"
	"errors"
	"time"

	"thesis-track/internal/domain/dto"
	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/repository"
	"thesis-track/internal/domain/service"

	"github.com/google/uuid"
)

type progressService struct {
	progressRepo repository.ProgressRepository
	thesisRepo   repository.ThesisRepository
	commentRepo repository.CommentRepository
	studentRepo repository.StudentRepository
	lectureRepo repository.LectureRepository
}

func NewProgressService(
	progressRepo repository.ProgressRepository,
	thesisRepo repository.ThesisRepository,
	commentRepo repository.CommentRepository,
	studentRepo repository.StudentRepository,
	lectureRepo repository.LectureRepository,
) service.ProgressService {
	return &progressService{
		progressRepo: progressRepo,
		thesisRepo:   thesisRepo,
		commentRepo: commentRepo,
		studentRepo: studentRepo,
		lectureRepo: lectureRepo,
	}
}

func (s *progressService) AddProgress(ctx context.Context, req *dto.ProgressRequest) (*entity.Progress, error) {	
    progress := &entity.Progress{
        ThesisID:            uuid.MustParse(req.ThesisID),
        ReviewerID:          uuid.MustParse(req.ReviewerID),
        ProgressDescription: req.ProgressDescription,
        DocumentURL:         req.DocumentURL,
        Status:              "Pending",
        AchievementDate:     time.Now(),
    }

    progress, err := s.progressRepo.Create(ctx, progress)
    if err != nil {
        return nil, err
    }

    return progress, nil
}

func (s *progressService) UpdateProgress(ctx context.Context, progress *entity.Progress) (*entity.Progress, error) {	
	progress, err := s.progressRepo.Update(ctx, progress)
	if err != nil {
		return nil, err
	}

	return progress, nil
}

func (s *progressService) DeleteProgress(ctx context.Context, id uuid.UUID) error {
	// Check if progress exists
	existingProgress, err := s.progressRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if existingProgress == nil {
		return errors.New("progress not found")
	}

	return s.progressRepo.Delete(ctx, id)
}

func (s *progressService) GetProgressByID(ctx context.Context, id uuid.UUID) (*entity.Progress, error) {
	progress, err := s.progressRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if progress == nil {
		return nil, errors.New("progress not found")
	}

	return progress, nil
}

func (s *progressService) GetProgressesByThesisID(ctx context.Context, thesisID uuid.UUID) ([]entity.Progress, error) {
	return s.progressRepo.FindAllByThesisID(ctx, thesisID)
}

func (s *progressService) ReviewProgress(ctx context.Context, id uuid.UUID, userID uuid.UUID, req *dto.CommentRequest) (*dto.ReviewProgressResponse, error) {
	// Check if progress exists
	progress, err := s.progressRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if progress == nil {
		return nil, errors.New("progress not found")
	}

	if progress.ReviewerID != userID {
		return nil, errors.New("user is not the reviewer")
	}

	if progress.Status == "Reviewed" {
		return nil, errors.New("progress already reviewed")
	}	

	// Create comment
	comment := &entity.Comment{
		ProgressID: progress.ID,
		Content:    req.Content,
		UserID:     progress.ReviewerID,
		UserType:   "Lecture",
	}

	if req.ParentID != nil {
		parentID := uuid.MustParse(*req.ParentID)
		comment.ParentID = &parentID
	}
	
	comment, err = s.commentRepo.Create(ctx, comment)
	if err != nil {
		return nil, err
	}
	
	progress.Status = "Reviewed"

	progress, err = s.progressRepo.Update(ctx, progress)
	if err != nil {
		return nil, err
	}

	return &dto.ReviewProgressResponse{
		Comment: comment,
		Progress: progress,
	}, nil
}

func (s *progressService) AddComment(ctx context.Context, progressID uuid.UUID, userID uuid.UUID, req *dto.CommentRequest) (*entity.Comment, error) {
	// Validate progress exists
	progress, err := s.progressRepo.FindByID(ctx, progressID)
	if err != nil {
		return nil, err
	}
	if progress == nil {
		return nil, errors.New("progress not found")
	}

	// Determine user type
	var userType string
	if student, _ := s.studentRepo.FindByID(ctx, userID); student != nil {
		userType = "Student"
	} else if lecture, _ := s.lectureRepo.FindByID(ctx, userID); lecture != nil {
		userType = "Lecture"
	} else {
		return nil, errors.New("invalid user")
	}

	// If this is a reply, validate parent comment
	var parentID *uuid.UUID
	if req.ParentID != nil {
		pid, err := uuid.Parse(*req.ParentID)
		if err != nil {
			return nil, errors.New("invalid parent comment ID")
		}
		parentID = &pid

		// Validate parent comment exists and belongs to same progress
		parentComment, err := s.commentRepo.FindByID(ctx, pid)
		if err != nil || parentComment == nil || parentComment.ProgressID != progressID {
			return nil, errors.New("invalid parent comment")
		}
	}

	comment := &entity.Comment{
		ProgressID: progressID,
		UserID:     userID,
		UserType:   userType,
		ParentID:   parentID,
		Content:    req.Content,
	}

	comment, err = s.commentRepo.Create(ctx, comment)
	if err != nil {
		return nil, err
	}

	return comment, nil
}

func (s *progressService) GetCommentsByProgress(ctx context.Context, progressID uuid.UUID) ([]entity.Comment, error) {
	// Validate progress exists
	progress, err := s.progressRepo.FindByID(ctx, progressID)
	if err != nil {
		return nil, err
	}
	if progress == nil {
		return nil, errors.New("progress not found")
	}

	// Get comments by progress ID
	comments, err := s.commentRepo.FindByProgressID(ctx, progressID)
	if err != nil {
		return nil, err
	}

	return comments, nil
}