package service

import (
	"context"
	"errors"
	"fmt"
	"time"

	"thesis-track/config"
	"thesis-track/internal/domain/dto"
	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/repository"
	"thesis-track/internal/domain/service"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
	"github.com/supabase-community/gotrue-go/types"
	"github.com/supabase-community/supabase-go"
)

type authService struct {
	studentRepo repository.StudentRepository
	lectureRepo repository.LectureRepository
	adminRepo   repository.AdminRepository
	supabase    *supabase.Client
}

func NewAuthService(
	studentRepo repository.StudentRepository,
	lectureRepo repository.LectureRepository,
	adminRepo   repository.AdminRepository,
	supabase    *supabase.Client,
) service.AuthService {
	return &authService{
		studentRepo: studentRepo,
		lectureRepo: lectureRepo,
		adminRepo:   adminRepo,
		supabase:    supabase,
	}
}

func (s *authService) Login(ctx context.Context, email, password string) (*dto.LoginResponse, error) {
	// Login with Supabase Auth
	session, err := s.supabase.Auth.SignInWithEmailPassword(email, password)
	if err != nil {
		return nil, err
	}

	role := session.User.UserMetadata["role"].(string)
	
	// Get user data from appropriate repository based on role
	var userData interface{}
	switch role {
	case "Student":
		userData, err = s.studentRepo.FindByEmail(ctx, session.User.Email)
		if err != nil {
			return nil, err
		}
	case "Lecture":
		userData, err = s.lectureRepo.FindByEmail(ctx, session.User.Email)
		if err != nil {
			return nil, err
		}
	case "Admin":
		userData, err = s.adminRepo.FindByEmail(ctx, session.User.Email)
		if err != nil {
			return nil, err
		}
	}

	var response dto.LoginResponse
	response.AccessToken = session.AccessToken
	response.RefreshToken = session.RefreshToken
	response.ExpiresIn = session.ExpiresIn
	response.ExpiresAt = session.ExpiresAt
	response.Role = role
	response.User = userData

	return &response, nil
}

type SupabaseUserMetadata struct {
    Email         string `json:"email"`
    EmailVerified bool   `json:"email_verified"`
    PhoneVerified bool   `json:"phone_verified"`
    Role          string `json:"role"`
    Sub           string `json:"sub"`
}

type SupabaseClaims struct {
    Issuer    string                `json:"iss"`
    Subject   string                `json:"sub"`
    Audience  jwt.ClaimStrings     `json:"aud"`
    ExpiresAt *jwt.NumericDate     `json:"exp"`
    IssuedAt  *jwt.NumericDate     `json:"iat"`
    Email     string                `json:"email"`
    UserMetadata SupabaseUserMetadata `json:"user_metadata"`
    jwt.RegisteredClaims
}

func (s *authService) VerifyToken(ctx context.Context, tokenString string) (uuid.UUID, string, error) {
	// Parse dan verifikasi token dengan JWT secret
    token, err := jwt.ParseWithClaims(tokenString, &SupabaseClaims{}, func(token *jwt.Token) (interface{}, error) {
        // Verifikasi algoritma
        if _, ok := token.Method.(*jwt.SigningMethodHMAC); !ok {
            return nil, fmt.Errorf("unexpected signing method: %v", token.Header["alg"])
        }

        // Return JWT secret untuk verifikasi signature
        return []byte(config.GetString("JWT_SECRET", "")), nil
    })

    if err != nil {
        return uuid.Nil, "", fmt.Errorf("failed to verify token: %w", err)
    }

    // Verifikasi token valid
    if !token.Valid {
        return uuid.Nil, "", fmt.Errorf("invalid token")
    }

    // Cast claims ke SupabaseClaims
    claims, ok := token.Claims.(*SupabaseClaims)
    if !ok {
        return uuid.Nil, "", fmt.Errorf("invalid token claims")
    }

    // Verifikasi waktu expiry
    if claims.ExpiresAt != nil {
        if claims.ExpiresAt.Time.Before(time.Now()) {
            return uuid.Nil, "", fmt.Errorf("token has expired")
        }
    }

    // Parse UUID dari subject
    userID, err := uuid.Parse(claims.Subject)
    if err != nil {
        return uuid.Nil, "", fmt.Errorf("invalid user id in token")
    }

    // Ambil role dari user_metadata
    role := claims.UserMetadata.Role
    if role == "" {
        return uuid.Nil, "", fmt.Errorf("role not found in token")
    }

    return userID, role, nil
}

func (s *authService) Register(ctx context.Context, registerData *dto.RegisterRequest) (*dto.RegisterResponse, error) {
	supabaseSecret := config.GetString("SUPABASE_SECRET", "")
	// Register user in Supabase Auth
	user, err := s.supabase.Auth.Signup(types.SignupRequest{
		Email:    registerData.Email,
		Password: registerData.Password,
		Data: map[string]interface{}{
			"role": registerData.Role,
		},
	})
	if err != nil {
		return nil, err
	}

	// Create record in appropriate repository based on role
	switch registerData.Role {
	case "Student":
		studentData := entity.Student{
			ID:    user.ID,
			Email: registerData.Email,
			Name:  registerData.Name,
			NIM:   registerData.NIM,
			Department: registerData.Department,
			Year: registerData.Year,			
		}
		err = s.studentRepo.Create(ctx, &studentData)
		if err != nil {
			// delete user in Supabase Auth if error
			s.supabase.Auth.WithToken(supabaseSecret).AdminDeleteUser(types.AdminDeleteUserRequest{
				UserID: user.ID,
			})
			return nil, err
		}
		return &dto.RegisterResponse{
			ID: user.ID,
			Email: user.Email,
			Role: registerData.Role,
			User: studentData,
		}, nil
	case "Lecture":
		lectureData := entity.Lecture{
			ID:    user.ID,
			Email: registerData.Email,
			Name:  registerData.Name,
			NIDN: registerData.NIDN,		
			Department: registerData.Department,
		}
		err = s.lectureRepo.Create(ctx, &lectureData)
		if err != nil {
			// delete user in Supabase Auth if error
			s.supabase.Auth.WithToken(supabaseSecret).AdminDeleteUser(types.AdminDeleteUserRequest{
				UserID: user.ID,
			})
			return nil, err
		}
		return &dto.RegisterResponse{
			ID: user.ID,
			Email: user.Email,
			Role: registerData.Role,
			User: lectureData,
		}, nil
	case "Admin":
		adminData := entity.Admin{
			ID:    user.ID,
			Email: registerData.Email,
			Name:  registerData.Name,
		}
		err = s.adminRepo.Create(ctx, &adminData)
		if err != nil {
			// delete user in Supabase Auth if error
			s.supabase.Auth.WithToken(supabaseSecret).AdminDeleteUser(types.AdminDeleteUserRequest{
				UserID: user.ID,
			})
			return nil, err
		}
		return &dto.RegisterResponse{
			ID: user.ID,
			Email: user.Email,
			Role: registerData.Role,
			User: adminData,
		}, nil
	default:
		return nil, errors.New("invalid role")
	}
}
