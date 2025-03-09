package service

import (
	"context"

	"thesis-track/internal/domain/dto"
	"thesis-track/internal/domain/entity"

	"github.com/google/uuid"
)

type StudentService interface {
	CreateStudent(ctx context.Context, student *entity.Student) error
	UpdateStudent(ctx context.Context, student *entity.Student) error
	DeleteStudent(ctx context.Context, id uuid.UUID) error
	GetStudentByID(ctx context.Context, id uuid.UUID) (*entity.Student, error)
	GetStudentByEmail(ctx context.Context, email string) (*entity.Student, error)
	GetAllStudents(ctx context.Context) ([]entity.Student, error)
}

type LectureService interface {
	CreateLecture(ctx context.Context, lecture *entity.Lecture) error
	UpdateLecture(ctx context.Context, lecture *entity.Lecture) error
	DeleteLecture(ctx context.Context, id uuid.UUID) error
	GetLectureByID(ctx context.Context, id uuid.UUID) (*entity.Lecture, error)
	GetLectureByEmail(ctx context.Context, email string) (*entity.Lecture, error)
	GetAllLectures(ctx context.Context) ([]entity.Lecture, error)
}

type AdminService interface {
	CreateAdmin(ctx context.Context, admin *entity.Admin) error
	UpdateAdmin(ctx context.Context, admin *entity.Admin) error
	DeleteAdmin(ctx context.Context, id uuid.UUID) error
	GetAdminByID(ctx context.Context, id uuid.UUID) (*entity.Admin, error)
	GetAdminByEmail(ctx context.Context, email string) (*entity.Admin, error)
	GetAllUsers(ctx context.Context) ([]entity.Student, []entity.Lecture, error)
} 

type ThesisService interface {
	SubmitProposalThesis(ctx context.Context, req *dto.ThesisRequest, studentID uuid.UUID, supervisorID uuid.UUID) (*entity.Thesis, error)
	UpdateThesis(ctx context.Context, thesis *entity.Thesis) error
	DeleteThesis(ctx context.Context, id uuid.UUID) error
	GetThesisByID(ctx context.Context, id uuid.UUID) (*entity.Thesis, error)
	GetThesesByStudentID(ctx context.Context, studentID uuid.UUID) ([]entity.Thesis, error)
	GetAllTheses(ctx context.Context) ([]entity.Thesis, error)
	UpdateThesisStatus(ctx context.Context, id uuid.UUID, status string) error
	AssignSupervisor(ctx context.Context, thesisID, lectureID uuid.UUID) (*entity.ThesisLecture, error)
	AssignExaminer(ctx context.Context, thesisID, lectureID uuid.UUID) (*entity.ThesisLecture, error)
	ApproveThesisForDefense(ctx context.Context, thesisID, lectureID uuid.UUID) error
	ApproveThesisForFinalize(ctx context.Context, thesisID, lectureID uuid.UUID) error
	CalculateThesisProgress(ctx context.Context, thesis *entity.Thesis, progress []entity.Progress) (*entity.ThesisProgress, error)
	GetThesesByLectureID(ctx context.Context, lectureID uuid.UUID, lectureRole string) ([]entity.Thesis, error)
}

type ProgressService interface {
	AddProgress(ctx context.Context, req *dto.ProgressRequest) (*entity.Progress, error)
	UpdateProgress(ctx context.Context, progress *entity.Progress) (*entity.Progress, error)
	DeleteProgress(ctx context.Context, id uuid.UUID) error
	GetProgressByID(ctx context.Context, id uuid.UUID) (*entity.Progress, error)
	GetProgressesByThesisID(ctx context.Context, thesisID uuid.UUID) ([]entity.Progress, error)
	GetProgressesByThesisIDAndLectureID(ctx context.Context, thesisID, lectureID uuid.UUID) ([]entity.Progress, error)
	ReviewProgress(ctx context.Context, id uuid.UUID, userID uuid.UUID, req *dto.CommentRequest) (*dto.ReviewProgressResponse, error)
	AddComment(ctx context.Context, progressID uuid.UUID, userID uuid.UUID, req *dto.CommentRequest) (*entity.Comment, error)
	GetCommentsByProgress(ctx context.Context, progressID uuid.UUID) ([]entity.Comment, error)
}

type DocumentService interface {
	UploadDraftDocument(ctx context.Context, userID, thesisID uuid.UUID, file []byte, filename string) (string, error)
	UploadFinalDocument(ctx context.Context, userID, thesisID uuid.UUID, file []byte, filename string) (string, error)
	GetDocumentURL(ctx context.Context, path string) (string, error)
}

type AuthService interface {
	Register(ctx context.Context, registerData *dto.RegisterRequest) (*dto.RegisterResponse, error)
	Login(ctx context.Context, email, password string) (*dto.LoginResponse, error)
	VerifyToken(ctx context.Context, token string) (uuid.UUID, string, error)
}

type EmailService interface {
	SendThesisSubmissionNotification(ctx context.Context, to string, studentName string, thesisTitle string, supervisorName string) error
	SendThesisApprovedNotification(ctx context.Context, to string, studentName string, thesisTitle string) error
	SendProgressSubmissionNotification(ctx context.Context, to string, studentName string, progressTitle string) error
	SendProgressApprovalNotification(ctx context.Context, to string, studentName string, progressTitle string, status string) error
	SendThesisCompletedNotification(ctx context.Context, to string, receiverRole string, thesis *entity.Thesis) error
	SendThesisProposalNotification(ctx context.Context, to string, thesis *entity.Thesis) error
	SendThesisLectureAssignedNotification(ctx context.Context, to string, assignerRole string, thesis *entity.Thesis) error
	SendThesisReadyForExamNotification(ctx context.Context, to string, thesis *entity.Thesis, examType string) error
	SendThesisReadyForFinalSubmissionNotification(ctx context.Context, to string, thesis *entity.Thesis) error
	SendThesisFinalDocumentUploadedNotification(ctx context.Context, studentEmail string, thesis *entity.Thesis) error
	SendThesisDraftDocumentUploadedNotification(ctx context.Context, studentEmail string, thesis *entity.Thesis) error
}