package handler

import (
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

	// Check if thesis exists and user owns it
	thesis, err := h.thesisService.GetThesisByID(c.Context(), thesisID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "thesis not found",
		})
	}

	// Verify ownership
	userID := c.Locals("userID").(uuid.UUID)
	if thesis.StudentID != userID {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error": "you can only upload documents to your own thesis",
		})
	}

	// Get file from request
	file, err := c.FormFile("document")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "no document provided",
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

	// Upload document
	documentURL, err := h.documentService.UploadDraftDocument(c.Context(), thesisID, buffer, file.Filename)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"message": "draft document uploaded successfully",
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

	// Check if thesis exists and user owns it
	thesis, err := h.thesisService.GetThesisByID(c.Context(), thesisID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "thesis not found",
		})
	}

	// Verify ownership
	userID := c.Locals("userID").(uuid.UUID)
	if thesis.StudentID != userID {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error": "you can only upload documents to your own thesis",
		})
	}

	// Get file from request
	file, err := c.FormFile("document")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "no document provided",
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

	// Upload document
	documentURL, err := h.documentService.UploadFinalDocument(c.Context(), thesisID, buffer, file.Filename)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"message": "final document uploaded successfully",
		"url":     documentURL,
	})
}

// UploadProgressDocument handles progress document upload
func (h *DocumentHandler) UploadProgressDocument(c *fiber.Ctx) error {
	progressID, err := uuid.Parse(c.Params("progressId"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid progress ID",
		})
	}

	// Check if progress exists
	progress, err := h.progressService.GetProgressByID(c.Context(), progressID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "progress not found",
		})
	}

	// Check if thesis exists and user owns it
	thesis, err := h.thesisService.GetThesisByID(c.Context(), progress.ThesisID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "thesis not found",
		})
	}

	// Verify ownership
	userID := c.Locals("userID").(uuid.UUID)
	if thesis.StudentID != userID {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error": "you can only upload documents to your own progress",
		})
	}

	// Get file from request
	file, err := c.FormFile("document")
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "no document provided",
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

	// Upload document
	documentURL, err := h.documentService.UploadProgressDocument(c.Context(), progressID, buffer, file.Filename)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"message": "progress document uploaded successfully",
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
	documents.Post("/progress/:progressId", h.authMiddleware.RequireStudent(), h.UploadProgressDocument)
} 