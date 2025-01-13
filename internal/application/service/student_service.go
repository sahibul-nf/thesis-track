package service

import (
	"context"
	"errors"

	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/repository"
	"thesis-track/internal/domain/service"

	"github.com/google/uuid"
)

type studentService struct {
	studentRepo repository.StudentRepository
}

func NewStudentService(studentRepo repository.StudentRepository) service.StudentService {
	return &studentService{
		studentRepo: studentRepo,
	}
}

func (s *studentService) CreateStudent(ctx context.Context, student *entity.Student) error {
	// Check if student with same email exists
	existingStudent, err := s.studentRepo.FindByEmail(ctx, student.Email)
	if err == nil && existingStudent != nil {
		return errors.New("student with this email already exists")
	}

	// Generate new UUID if not provided
	if student.ID == uuid.Nil {
		student.ID = uuid.New()
	}

	return s.studentRepo.Create(ctx, student)
}

func (s *studentService) UpdateStudent(ctx context.Context, student *entity.Student) error {
	// Check if student exists
	existingStudent, err := s.studentRepo.FindByID(ctx, student.ID)
	if err != nil {
		return err
	}
	if existingStudent == nil {
		return errors.New("student not found")
	}

	// Check if trying to update to an email that's already taken
	if student.Email != existingStudent.Email {
		emailCheck, err := s.studentRepo.FindByEmail(ctx, student.Email)
		if err == nil && emailCheck != nil {
			return errors.New("email already taken by another student")
		}
	}

	return s.studentRepo.Update(ctx, student)
}

func (s *studentService) DeleteStudent(ctx context.Context, id uuid.UUID) error {
	// Check if student exists
	existingStudent, err := s.studentRepo.FindByID(ctx, id)
	if err != nil {
		return err
	}
	if existingStudent == nil {
		return errors.New("student not found")
	}

	return s.studentRepo.Delete(ctx, id)
}

func (s *studentService) GetStudentByID(ctx context.Context, id uuid.UUID) (*entity.Student, error) {
	student, err := s.studentRepo.FindByID(ctx, id)
	if err != nil {
		return nil, err
	}
	if student == nil {
		return nil, errors.New("student not found")
	}

	return student, nil
}

func (s *studentService) GetStudentByEmail(ctx context.Context, email string) (*entity.Student, error) {
	student, err := s.studentRepo.FindByEmail(ctx, email)
	if err != nil {
		return nil, err
	}
	if student == nil {
		return nil, errors.New("student not found")
	}

	return student, nil
}

func (s *studentService) GetAllStudents(ctx context.Context) ([]entity.Student, error) {
	return s.studentRepo.FindAll(ctx)
} 