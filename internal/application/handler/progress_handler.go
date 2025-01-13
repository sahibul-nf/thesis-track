package handler

import (
	"thesis-track/internal/application/middleware"
	"thesis-track/internal/domain/dto"
	"thesis-track/internal/domain/service"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type ProgressHandler struct {
	progressService service.ProgressService
	thesisService  service.ThesisService
	authMiddleware *middleware.AuthMiddleware
}

func NewProgressHandler(
	progressService service.ProgressService,
	thesisService service.ThesisService,
	authMiddleware *middleware.AuthMiddleware,
) *ProgressHandler {
	return &ProgressHandler{
		progressService: progressService,
		thesisService:  thesisService,
		authMiddleware: authMiddleware,
	}
}

// AddProgress handles adding a new progress
func (h *ProgressHandler) AddProgress(c *fiber.Ctx) error {
	var req dto.ProgressRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}	

	// Parse UUIDs
	thesisID, err := uuid.Parse(req.ThesisID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid thesis ID",
		})
	}

	reviewerID, err := uuid.Parse(req.ReviewerID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid reviewer ID",
		})
	}

	// Get student ID from authenticated user
	studentID := c.Locals("userID").(uuid.UUID)

	// Verify thesis belongs to student
	thesis, err := h.thesisService.GetThesisByID(c.Context(), thesisID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "thesis not found",
		})
	}
	if thesis.StudentID != studentID {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error": "you can only add progress to your own thesis",
		})
	}

	// Verify reviewer is either supervisor or examiner of the thesis
	isValidReviewer := false
	for _, tl := range thesis.ThesisLectures {
		if tl.LectureID == reviewerID {
			isValidReviewer = true
			break
		}
	}
	if !isValidReviewer {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "reviewer must be assigned to thesis as supervisor or examiner",
		})
	}

	// Add progress
	progress, err := h.progressService.AddProgress(c.Context(), &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"data": progress,
	})
}

// GetProgressByID returns a progress by ID
func (h *ProgressHandler) GetProgressByID(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid progress ID",
		})
	}

	progress, err := h.progressService.GetProgressByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data": progress,
	})
}

// GetProgressesByThesis returns all progress for a thesis
func (h *ProgressHandler) GetProgressesByThesis(c *fiber.Ctx) error {
	thesisID, err := uuid.Parse(c.Params("thesisId"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid thesis ID",
		})
	}

	progresses, err := h.progressService.GetProgressesByThesisID(c.Context(), thesisID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data": progresses,
	})
}

// UpdateProgress updates a progress
func (h *ProgressHandler) UpdateProgress(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid progress ID",
		})
	}

	// Parse request body
	var req dto.UpdateProgressRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Get existing progress
	progress, err := h.progressService.GetProgressByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Get thesis to check ownership
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
			"error": "you can only update your own progress",
		})
	}
	
	// Update progress
	progress.ProgressDescription = req.ProgressDescription
	progress.DocumentURL = req.DocumentURL
	
	progress, err = h.progressService.UpdateProgress(c.Context(), progress)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data":    progress,
	})
}

// ReviewProgress handles progress review by lecturer
func (h *ProgressHandler) ReviewProgress(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid progress ID",
		})
	}

	var req dto.CommentRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Get user ID from authenticated user
	userID := c.Locals("userID").(uuid.UUID)

	// Review progress
	response, err := h.progressService.ReviewProgress(c.Context(), id, userID, &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data": response,
	})
}

// AddComment handles adding a new comment
func (h *ProgressHandler) AddComment(c *fiber.Ctx) error {
	var req dto.CommentRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid request body",
		})
	}

	progressID, err := uuid.Parse(c.Params("progressId"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid progress ID",
		})
	}

	userID := c.Locals("userID").(uuid.UUID)

	comment, err := h.progressService.AddComment(c.Context(), progressID, userID, &req)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"data": comment,
	})
}

// GetCommentsByProgress returns all comments for a progress
func (h *ProgressHandler) GetCommentsByProgress(c *fiber.Ctx) error {
	progressID, err := uuid.Parse(c.Params("progressId"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid progress ID",
		})
	}

	comments, err := h.progressService.GetCommentsByProgress(c.Context(), progressID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data": comments,
	})
}

// RegisterRoutes registers all progress routes
func (h *ProgressHandler) RegisterRoutes(app fiber.Router) {
	progress := app.Group("/progress")

	// Protected routes
	progress.Use(h.authMiddleware.Authenticate())

	// Student routes
	progress.Post("/", h.authMiddleware.RequireStudent(), middleware.ValidateRequest(&dto.ProgressRequest{}), h.AddProgress)
	progress.Put("/:id", h.authMiddleware.RequireStudent(), middleware.ValidateRequest(&dto.UpdateProgressRequest{}), h.UpdateProgress)

	// Lecture routes
	progress.Post("/:id/review", h.authMiddleware.RequireLecture(), middleware.ValidateRequest(&dto.CommentRequest{}), h.ReviewProgress)

	// Routes accessible by all authenticated users
	progress.Get("/:id", h.GetProgressByID)
	progress.Get("/thesis/:thesisId", h.GetProgressesByThesis)

	// Comment routes
	progress.Post("/:progressId/comment", h.AddComment)
	progress.Get("/:progressId/comments", h.GetCommentsByProgress)
}
