package services

import (
	"thesis-track/internal/entities"
	"thesis-track/internal/repositories"
)

type StudentService interface {
	GetAllStudents() ([]entities.Student, error)
	GetStudentByID(id string) (*entities.Student, error)
	CreateStudent(student *entities.Student) error
	UpdateStudent(student *entities.Student) error
	DeleteStudent(id string) error
}

type studentService struct {
	studentRepo repositories.StudentRepository
}

func NewStudentService(studentRepo repositories.StudentRepository) StudentService {
	return &studentService{studentRepo}
}

func (s *studentService) GetAllStudents() ([]entities.Student, error) {
	return s.studentRepo.FindAll()
}

func (s *studentService) GetStudentByID(id string) (*entities.Student, error) {
	return s.studentRepo.FindByID(id)
}

func (s *studentService) CreateStudent(student *entities.Student) error {
	return s.studentRepo.Create(student)
}

func (s *studentService) UpdateStudent(student *entities.Student) error {
	return s.studentRepo.Update(student)
}

func (s *studentService) DeleteStudent(id string) error {
	return s.studentRepo.Delete(id)
}
