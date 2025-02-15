package service

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"path/filepath"

	"thesis-track/internal/domain/repository"
	"thesis-track/internal/domain/service"

	storage_go "github.com/supabase-community/storage-go"
	"github.com/supabase-community/supabase-go"

	"github.com/google/uuid"
)

type documentService struct {
	thesisRepo   repository.ThesisRepository
	progressRepo repository.ProgressRepository
	supabase     *supabase.Client
}

func NewDocumentService(
	thesisRepo repository.ThesisRepository,
	progressRepo repository.ProgressRepository,
	supabase *supabase.Client,
) service.DocumentService {
	return &documentService{
		thesisRepo:   thesisRepo,
		progressRepo: progressRepo,
		supabase:     supabase,
	}
}

func (s *documentService) UploadDraftDocument(ctx context.Context, userID, thesisID uuid.UUID, file []byte, filename string) (string, error) {
	// Check if thesis exists
	thesis, err := s.thesisRepo.FindByID(ctx, thesisID)
	if err != nil {
		return "", err
	}
	if thesis == nil {
		return "", errors.New("thesis not found")
	}

	// Verify ownership
	if thesis.StudentID != userID {
		return "", errors.New("you can only upload documents to your own thesis")
	}

	// Check supervisor approvals
	supervisors := 0
	approvedSupervisors := 0
	for _, tl := range thesis.ThesisLectures {
		if tl.Role == "Supervisor" {
			supervisors++
			if tl.ApprovedAt != nil {
				approvedSupervisors++
			}
		}
	}

	if approvedSupervisors < supervisors {
		return "", errors.New("all supervisors must approve before uploading draft document")
	}

	// Generate unique filename
	ext := filepath.Ext(filename)
	uniqueFilename := fmt.Sprintf("thesis/%s/draft_%s%s", thesisID, userID, ext)
	
	types := "application/pdf"
	upsert := true

	// Upload to Supabase Storage
	_, err = s.supabase.Storage.UploadFile("documents", uniqueFilename, bytes.NewReader(file), storage_go.FileOptions{
		ContentType: &types,
		Upsert: &upsert,
	})
	if err != nil {
		return "", fmt.Errorf("failed to upload document: %w", err)
	}

	// Get public URL
	publicURL := s.supabase.Storage.GetPublicUrl("documents", uniqueFilename).SignedURL

	// Update thesis with document URL
	thesis.DraftDocumentURL = publicURL
	err = s.thesisRepo.Update(ctx, thesis)
	if err != nil {
		return "", fmt.Errorf("failed to update thesis with document URL: %w", err)
	}

	return publicURL, nil
}

func (s *documentService) UploadFinalDocument(ctx context.Context, userID, thesisID uuid.UUID, file []byte, filename string) (string, error) {
	// Check if thesis exists
	thesis, err := s.thesisRepo.FindByID(ctx, thesisID)
	if err != nil {
		return "", err
	}
	if thesis == nil {
		return "", errors.New("thesis not found")
	}

	//* This has been handled in the thesis service in the approve thesis function
	// // Check examiner approvals
	// examines := 0
	// approvedExamines := 0
	// for _, tl := range thesis.ThesisLectures {
	// 	if tl.Role == "Examiner" {
	// 		examines++
	// 		if tl.ApprovedAt != nil {
	// 			approvedExamines++
	// 		}
	// 	}
	// }

	// if approvedExamines < examines {
	// 	return "", errors.New("all examiners must approve before uploading final document")
	// }
	//* End of examiner approvals check

	// Check if thesis is in Under Review status
	if thesis.Status != "Under Review" {
		return "", errors.New("final document can only be uploaded when thesis is in Under Review status")
	}

	// Generate unique filename
	ext := filepath.Ext(filename)
	uniqueFilename := fmt.Sprintf("thesis/%s/final_%s%s", thesisID, userID, ext)

	types := "application/pdf"
	upsert := true
	
	// Upload to Supabase Storage
	_, err = s.supabase.Storage.UploadFile("documents", uniqueFilename, bytes.NewReader(file), storage_go.FileOptions{
		ContentType: &types,
		Upsert: &upsert,
	})
	if err != nil {
		return "", fmt.Errorf("failed to upload document: %w", err)
	}

	// Get public URL
	publicURL := s.supabase.Storage.GetPublicUrl("documents", uniqueFilename).SignedURL

	// Update thesis with document URL
	thesis.FinalDocumentURL = publicURL
	err = s.thesisRepo.Update(ctx, thesis)
	if err != nil {
		return "", fmt.Errorf("failed to update thesis with document URL: %w", err)
	}

	return publicURL, nil
}

func (s *documentService) UploadProgressDocument(ctx context.Context, progressID uuid.UUID, file []byte, filename string) (string, error) {
	// Check if progress exists
	progress, err := s.progressRepo.FindByID(ctx, progressID)
	if err != nil {
		return "", err
	}
	if progress == nil {
		return "", errors.New("progress not found")
	}

	// Generate unique filename
	ext := filepath.Ext(filename)
	uniqueFilename := fmt.Sprintf("progress/%s/document_%s%s", progressID, uuid.New().String(), ext)

	// Upload to Supabase Storage
	_, err = s.supabase.Storage.UploadFile("documents", uniqueFilename, bytes.NewReader(file))
	if err != nil {
		return "", fmt.Errorf("failed to upload document: %w", err)
	}

	// Get public URL
	publicURL := s.supabase.Storage.GetPublicUrl("documents", uniqueFilename).SignedURL

	// Update progress with document URL
	progress.DocumentURL = publicURL
	_, err = s.progressRepo.Update(ctx, progress)
	if err != nil {
		return "", fmt.Errorf("failed to update progress with document URL: %w", err)
	}

	return publicURL, nil
}

func (s *documentService) GetDocumentURL(ctx context.Context, path string) (string, error) {
	if path == "" {
		return "", errors.New("document path is empty")
	}

	// Get public URL from Supabase Storage
	publicURL := s.supabase.Storage.GetPublicUrl("documents", path).SignedURL
	return publicURL, nil
} 