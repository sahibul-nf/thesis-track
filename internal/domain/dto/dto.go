package dto

import (
	"thesis-track/internal/domain/entity"

	"github.com/google/uuid"
)

// ------------- Request -------------

type RegisterRequest struct {
	Email      string `json:"email" validate:"required,email"`
	Password   string `json:"password" validate:"required,min=6"`
	Name       string `json:"name" validate:"required"`
	Role       string `json:"role" validate:"required,oneof=Student Lecture Admin"`
	NIDN       string `json:"nidn" validate:"required_if=Role Lecture"`
	Department string `json:"department" validate:"required_if=Role Student,required_if=Role Lecture"`
	NIM        string `json:"nim" validate:"required_if=Role Student"`
	Year       string `json:"year" validate:"required_if=Role Student"`
}

type LoginRequest struct {
	Email    string `json:"email" validate:"required,email"`
	Password string `json:"password" validate:"required"`
}

type ThesisRequest struct {
	Title         string `json:"title" validate:"required,min=3"`
	Abstract      string `json:"abstract" validate:"required,min=10"`
	ResearchField string `json:"research_field" validate:"required,min=3"`
	SupervisorID  string `json:"supervisor_id" validate:"required,uuid"`
}

type ProgressRequest struct {
	ThesisID            string `json:"thesis_id" validate:"required,uuid"`
	ReviewerID          string `json:"reviewer_id" validate:"required,uuid"`
	ProgressDescription string `json:"progress_description" validate:"required,min=10"`
	DocumentURL         string `json:"document_url" validate:"required,valid_doc_url"`
}

type UpdateProgressRequest struct {
	ProgressDescription string `json:"progress_description" validate:"required,min=10"`
	DocumentURL         string `json:"document_url" validate:"required,valid_doc_url"`
}

type CommentRequest struct {
	Content  string  `json:"content" validate:"required,min=1"`
	ParentID *string `json:"parent_id" validate:"omitempty,uuid"`
}

type ReviewProgressResponse struct {
	Comment *entity.Comment `json:"comment"`
	Progress *entity.Progress `json:"progress"`
}

// ------------- Response -------------

// / ErrorResponse represents the Supabase error structure
type SupabaseErrorResponse struct {
	Code      int    `json:"code"`
	ErrorCode string `json:"error_code"`
	Message   string `json:"msg"`
}

// / RegisterResponse represents the response structure for register
type RegisterResponse struct {
	ID    uuid.UUID   `json:"id"`
	Email string      `json:"email"`
	Role  string      `json:"role"`
	User  interface{} `json:"user"`
}

type LoginResponse struct {
	AccessToken  string      `json:"access_token"`
	RefreshToken string      `json:"refresh_token"`
	ExpiresIn    int         `json:"expires_in"`
	ExpiresAt    int64       `json:"expires_at"`
	Role         string      `json:"role"`
	User         interface{} `json:"user"`
}
