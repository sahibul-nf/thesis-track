package handler

import (
	"path/filepath"
	"thesis-track/internal/application/middleware"
	"thesis-track/internal/domain/service"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type DocumentHandler struct {
	documentService service.DocumentService
	thesisService   service.ThesisService
	progressService service.ProgressService
	authMiddleware  *middleware.AuthMiddleware
}

func NewDocumentHandler(
	documentService service.DocumentService,
	thesisService service.ThesisService,
	progressService service.ProgressService,
	authMiddleware *middleware.AuthMiddleware,
) *DocumentHandler {
	return &DocumentHandler{
		documentService: documentService,
		thesisService:   thesisService,
		progressService: progressService,
		authMiddleware:  authMiddleware,
	}
}

// UploadDraftDocument handles thesis draft document upload
func (h *DocumentHandler) UploadDraftDocument(c *fiber.Ctx) error {
	thesisID, err := uuid.Parse(c.Params("thesisId"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid thesis ID",
		})
	}
	
	// Get file from request
	file, err := c.FormFile("document")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "no document provided",
		})
	}

	if file.Size > 10*1024*1024 { // 10MB
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "file size exceeds 10MB limit",
		})
	}

	// Verify file type (PDF)
	if filepath.Ext(file.Filename) != ".pdf" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "only PDF files are allowed",
		})
	}

	// Read file
	fileContent, err := file.Open()
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to read document",
		})
	}
	defer fileContent.Close()

	// Read file bytes
	buffer := make([]byte, file.Size)
	_, err = fileContent.Read(buffer)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to read document",
		})
	}

	userID := c.Locals("userID").(uuid.UUID)

	// Upload document
	documentURL, err := h.documentService.UploadDraftDocument(c.Context(), userID, thesisID, buffer, file.Filename)
	if err != nil {
		if err.Error() == "you can only upload documents to your own thesis" {
			return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
				"error": err.Error(),
			})
		}

		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"url":     documentURL,
	})
}

// UploadFinalDocument handles thesis final document upload
func (h *DocumentHandler) UploadFinalDocument(c *fiber.Ctx) error {
	thesisID, err := uuid.Parse(c.Params("thesisId"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid thesis ID",
		})
	}

	// Get file from request
	file, err := c.FormFile("document")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "no document provided",
		})
	}

	if file.Size > 10*1024*1024 { // 10MB
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "file size exceeds 10MB limit",
		})
	}

	// Verify file type (PDF)
	if filepath.Ext(file.Filename) != ".pdf" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "only PDF files are allowed",
		})
	}

	// Read file
	fileContent, err := file.Open()
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to read document",
		})
	}
	defer fileContent.Close()

	// Read file bytes
	buffer := make([]byte, file.Size)
	_, err = fileContent.Read(buffer)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to read document",
		})
	}

	userID := c.Locals("userID").(uuid.UUID)

	// Upload document
	documentURL, err := h.documentService.UploadFinalDocument(c.Context(), userID, thesisID, buffer, file.Filename)
	if err != nil {
		if err.Error() == "you can only upload documents to your own thesis" {
			return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
				"error": err.Error(),
			})
		}

		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"url":     documentURL,
	})
}

// RegisterRoutes registers all document routes
func (h *DocumentHandler) RegisterRoutes(app fiber.Router) {
	documents := app.Group("/documents")

	// Protected routes
	documents.Use(h.authMiddleware.Authenticate())

	// Student routes
	documents.Post("/thesis/:thesisId/draft", h.authMiddleware.RequireStudent(), h.UploadDraftDocument)
	documents.Post("/thesis/:thesisId/final", h.authMiddleware.RequireStudent(), h.UploadFinalDocument)
}
