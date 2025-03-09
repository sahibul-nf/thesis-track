package service

import (
	"context"

	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/repository"

	"github.com/google/uuid"
	"github.com/supabase-community/supabase-go"
)

type adminService struct {
	adminRepo    repository.AdminRepository
	studentRepo  repository.StudentRepository
	lectureRepo  repository.LectureRepository
	thesisRepo   repository.ThesisRepository
	supabase     *supabase.Client
}

func NewAdminService(
	adminRepo repository.AdminRepository,
	studentRepo repository.StudentRepository,
	lectureRepo repository.LectureRepository,
	thesisRepo repository.ThesisRepository,
	supabase *supabase.Client,
) *adminService {
	return &adminService{
		adminRepo:    adminRepo,
		studentRepo:  studentRepo,
		lectureRepo:  lectureRepo,
		thesisRepo:   thesisRepo,
		supabase:     supabase,
	}
}

func (s *adminService) CreateAdmin(ctx context.Context, admin *entity.Admin) error {
	return s.adminRepo.Create(ctx, admin)
}

func (s *adminService) UpdateAdmin(ctx context.Context, admin *entity.Admin) error {
	return s.adminRepo.Update(ctx, admin)
}

func (s *adminService) DeleteAdmin(ctx context.Context, id uuid.UUID) error {
	return s.adminRepo.Delete(ctx, id)
}

func (s *adminService) GetAdminByID(ctx context.Context, id uuid.UUID) (*entity.Admin, error) {
	return s.adminRepo.FindByID(ctx, id)
}

func (s *adminService) GetAdminByEmail(ctx context.Context, email string) (*entity.Admin, error) {
	return s.adminRepo.FindByEmail(ctx, email)
}

func (s *adminService) GetAllUsers(ctx context.Context) ([]entity.Student, []entity.Lecture, error) {
	students, err := s.studentRepo.FindAll(ctx)
	if err != nil {
		return nil, nil, err
	}
	lectures, err := s.lectureRepo.FindAll(ctx)
	if err != nil {
		return nil, nil, err
	}

	return students, lectures, nil
}
// Admin specific operations
func (s *adminService) CreateStudent(ctx context.Context, student *entity.Student) error {
	return s.studentRepo.Create(ctx, student)
}

func (s *adminService) CreateLecture(ctx context.Context, lecture *entity.Lecture) error {
	return s.lectureRepo.Create(ctx, lecture)
}

func (s *adminService) DeleteStudent(ctx context.Context, id uuid.UUID) error {
	return s.studentRepo.Delete(ctx, id)
}

func (s *adminService) DeleteLecture(ctx context.Context, id uuid.UUID) error {
	return s.lectureRepo.Delete(ctx, id)
}