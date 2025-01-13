package service

import (
	"bytes"
	"context"
	"errors"
	"fmt"
	"path/filepath"

	"thesis-track/internal/domain/repository"
	"thesis-track/internal/domain/service"

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

func (s *documentService) UploadDraftDocument(ctx context.Context, thesisID uuid.UUID, file []byte, filename string) (string, error) {
	// Check if thesis exists
	thesis, err := s.thesisRepo.FindByID(ctx, thesisID)
	if err != nil {
		return "", err
	}
	if thesis == nil {
		return "", errors.New("thesis not found")
	}

	// Generate unique filename
	ext := filepath.Ext(filename)
	uniqueFilename := fmt.Sprintf("thesis/%s/draft_%s%s", thesisID, uuid.New().String(), ext)

	// Upload to Supabase Storage
	_, err = s.supabase.Storage.UploadFile("documents", uniqueFilename, bytes.NewReader(file))
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

func (s *documentService) UploadFinalDocument(ctx context.Context, thesisID uuid.UUID, file []byte, filename string) (string, error) {
	// Check if thesis exists
	thesis, err := s.thesisRepo.FindByID(ctx, thesisID)
	if err != nil {
		return "", err
	}
	if thesis == nil {
		return "", errors.New("thesis not found")
	}

	// Check if thesis is completed
	if thesis.Status != "Completed" {
		return "", errors.New("cannot upload final document for non-completed thesis")
	}

	// Generate unique filename
	ext := filepath.Ext(filename)
	uniqueFilename := fmt.Sprintf("thesis/%s/final_%s%s", thesisID, uuid.New().String(), ext)

	// Upload to Supabase Storage
	_, err = s.supabase.Storage.UploadFile("documents", uniqueFilename, bytes.NewReader(file))
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