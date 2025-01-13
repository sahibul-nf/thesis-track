package service

import (
	"context"
	"errors"
	"time"

	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/repository"
	"thesis-track/internal/domain/service"

	"github.com/google/uuid"
)

type thesisService struct {
	thesisRepo       repository.ThesisRepository
	thesisLectureRepo repository.ThesisLectureRepository
	studentRepo      repository.StudentRepository
	lectureRepo      repository.LectureRepository
}

func NewThesisService(
	thesisRepo repository.ThesisRepository,
	thesisLectureRepo repository.ThesisLectureRepository,
	studentRepo repository.StudentRepository,
	lectureRepo repository.LectureRepository,
) service.ThesisService {
	return &thesisService{
		thesisRepo:       thesisRepo,
		thesisLectureRepo: thesisLectureRepo,
		studentRepo:      studentRepo,
		lectureRepo:      lectureRepo,
	}
}

func (s *thesisService) SubmitThesis(ctx context.Context, thesis *entity.Thesis) error {
	// Check if student exists
	student, err := s.studentRepo.FindByID(ctx, thesis.StudentID)
	if err != nil {
		return err
	}
	if student == nil {
		return errors.New("student not found")
	}

	// Set initial status and submission date
	thesis.Status = "Proposed"
	thesis.SubmissionDate = time.Now()

	// // Generate new UUID if not provided
	// if thesis.ID == uuid.Nil {
	// 	thesis.ID = uuid.New()
	// }

	return s.thesisRepo.Create(ctx, thesis)
}

func (s *thesisService) UpdateThesis(ctx context.Context, thesis *entity.Thesis) error {
	// Check if thesis exists
	existingThesis, err := s.thesisRepo.FindByID(ctx, thesis.ID)
	if err != nil {
		return err
	}
	if existingThesis == nil {
		return errors.New("thesis not found")
	}

	return s.thesisRepo.Update(ctx, thesis)
}

func (s *thesisService) DeleteThesis(ctx context.Context, id uuid.UUID) error {
	// Check if thesis exists
	existingThesis, err := s.thesisRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if existingThesis == nil {
		return errors.New("thesis not found")
	}

	return s.thesisRepo.Delete(ctx, id)
}

func (s *thesisService) GetThesisByID(ctx context.Context, id uuid.UUID) (*entity.Thesis, error) {
	thesis, err := s.thesisRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if thesis == nil {
		return nil, errors.New("thesis not found")
	}

	return thesis, nil
}

func (s *thesisService) GetThesesByStudentID(ctx context.Context, studentID uuid.UUID) ([]entity.Thesis, error) {
	return s.thesisRepo.FindByStudentID(ctx, studentID)
}

func (s *thesisService) GetAllTheses(ctx context.Context) ([]entity.Thesis, error) {
	return s.thesisRepo.FindAll(ctx)
}

func (s *thesisService) UpdateThesisStatus(ctx context.Context, id uuid.UUID, status string) error {
	// Validate status
	validStatuses := map[string]bool{
		"Proposed":    true,
		"In Progress": true,
		"Completed":   true,
	}

	if !validStatuses[status] {
		return errors.New("invalid thesis status")
	}

	// Check if thesis exists
	thesis, err := s.thesisRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if thesis == nil {
		return errors.New("thesis not found")
	}

	// Update completion date if status is Completed
	if status == "Completed" && thesis.Status != "Completed" {
		completedDate := time.Now()
		thesis.CompletedDate = &completedDate
		err = s.thesisRepo.Update(ctx, thesis)
		if err != nil {
			return err
		}
	}

	return s.thesisRepo.UpdateStatus(ctx, id, status)
}

func (s *thesisService) AssignSupervisor(ctx context.Context, thesisID, lectureID uuid.UUID) error {
	return s.assignLectureToThesis(ctx, thesisID, lectureID, "Supervisor")
}

func (s *thesisService) AssignExaminer(ctx context.Context, thesisID, lectureID uuid.UUID) error {
	return s.assignLectureToThesis(ctx, thesisID, lectureID, "Examiner")
}

func (s *thesisService) assignLectureToThesis(ctx context.Context, thesisID, lectureID uuid.UUID, role string) error {
	// Check if thesis exists
	thesis, err := s.thesisRepo.FindByID(ctx, thesisID)
	if err != nil {
		return err
	}
	if thesis == nil {
		return errors.New("thesis not found")
	}

	// Check if lecture exists
	lecture, err := s.lectureRepo.FindByID(ctx, lectureID)
	if err != nil {
		return err
	}
	if lecture == nil {
		return errors.New("lecture not found")
	}

	// Check if the lecture is already assigned to this thesis
	thesisLectures, err := s.thesisLectureRepo.FindByThesisID(ctx, thesisID)
	if err != nil {
		return err
	}

	for _, tl := range thesisLectures {
		if tl.LectureID == lectureID {
			if tl.Role == role {
				return errors.New("lecture is already assigned this role for this thesis")
			}
			return errors.New("lecture is already assigned a different role for this thesis")
		}
	}

	// Create new thesis-lecture relationship
	thesisLecture := &entity.ThesisLecture{
		ID:        uuid.New(),
		ThesisID:  thesisID,
		LectureID: lectureID,
		Role:      role,
	}

	return s.thesisLectureRepo.Create(ctx, thesisLecture)
} 