package service

import (
	"context"
	"errors"

	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/repository"
	"thesis-track/internal/domain/service"

	"github.com/google/uuid"
)

type lectureService struct {
	lectureRepo repository.LectureRepository
}

func NewLectureService(lectureRepo repository.LectureRepository) service.LectureService {
	return &lectureService{
		lectureRepo: lectureRepo,
	}
}

func (s *lectureService) CreateLecture(ctx context.Context, lecture *entity.Lecture) error {
	// Check if lecture with same email exists
	existingLecture, err := s.lectureRepo.FindByEmail(ctx, lecture.Email)
	if err == nil && existingLecture != nil {
		return errors.New("lecture with this email already exists")
	}

	// Generate new UUID if not provided
	if lecture.ID == uuid.Nil {
		lecture.ID = uuid.New()
	}

	return s.lectureRepo.Create(ctx, lecture)
}

func (s *lectureService) UpdateLecture(ctx context.Context, lecture *entity.Lecture) error {
	// Check if lecture exists
	existingLecture, err := s.lectureRepo.FindByID(ctx, lecture.ID)
	if err != nil {
		return err
	}
	if existingLecture == nil {
		return errors.New("lecture not found")
	}

	// Check if trying to update to an email that's already taken
	if lecture.Email != existingLecture.Email {
		emailCheck, err := s.lectureRepo.FindByEmail(ctx, lecture.Email)
		if err == nil && emailCheck != nil {
			return errors.New("email already taken by another lecture")
		}
	}

	return s.lectureRepo.Update(ctx, lecture)
}

func (s *lectureService) DeleteLecture(ctx context.Context, id uuid.UUID) error {
	// Check if lecture exists
	existingLecture, err := s.lectureRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if existingLecture == nil {
		return errors.New("lecture not found")
	}

	return s.lectureRepo.Delete(ctx, id)
}

func (s *lectureService) GetLectureByID(ctx context.Context, id uuid.UUID) (*entity.Lecture, error) {
	lecture, err := s.lectureRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if lecture == nil {
		return nil, errors.New("lecture not found")
	}

	return lecture, nil
}

func (s *lectureService) GetLectureByEmail(ctx context.Context, email string) (*entity.Lecture, error) {
	lecture, err := s.lectureRepo.FindByEmail(ctx, email)
	if err != nil {
		return nil, err
	}
	if lecture == nil {
		return nil, errors.New("lecture not found")
	}

	return lecture, nil
}

func (s *lectureService) GetAllLectures(ctx context.Context) ([]entity.Lecture, error) {
	return s.lectureRepo.FindAll(ctx)
} 