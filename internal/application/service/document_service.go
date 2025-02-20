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
	emailService service.EmailService
}

func NewDocumentService(
	thesisRepo repository.ThesisRepository,
	progressRepo repository.ProgressRepository,
	supabase *supabase.Client,
	emailService service.EmailService,
) service.DocumentService {
	return &documentService{
		thesisRepo:   thesisRepo,
		progressRepo: progressRepo,
		supabase:     supabase,
		emailService: emailService,
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

	isReadyToUploadDraftDocument := thesis.IsProposalReady && thesis.IsFinalExamReady

	// Check if thesis is ready to upload draft document for Final Defense
	if !isReadyToUploadDraftDocument {
		return "", errors.New("thesis must be approved by all supervisors and examiners before uploading draft document")
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

	// send email notification to supervisor and examiners that the draft document has been uploaded
	err = s.emailService.SendThesisDraftDocumentUploadedNotification(ctx, thesis.Student.Email, thesis)
	if err != nil {
		return "", fmt.Errorf("failed to send email notification: %w", err)
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

	isReadyToUploadFinalDocument := thesis.IsFinalExamReady && thesis.Status == "Under Review"

	// Check if thesis is ready to upload final document
	if !isReadyToUploadFinalDocument {
		return "", errors.New("thesis must be approved by all examiners before uploading final document")
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

	// send email notification to supervisor and examiners that the final document has been uploaded
	err = s.emailService.SendThesisFinalDocumentUploadedNotification(ctx, thesis.Student.Email, thesis)
	if err != nil {
		return "", fmt.Errorf("failed to send email notification: %w", err)
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