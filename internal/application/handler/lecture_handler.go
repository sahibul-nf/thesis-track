package handler

import (
	"thesis-track/internal/application/middleware"
	"thesis-track/internal/domain/service"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type LectureHandler struct {
	lectureService service.LectureService
	authMiddleware *middleware.AuthMiddleware
}

func NewLectureHandler(lectureService service.LectureService, authMiddleware *middleware.AuthMiddleware) *LectureHandler {
	return &LectureHandler{
		lectureService: lectureService,
		authMiddleware: authMiddleware,
	}
}

// GetAllLectures returns all lectures
func (h *LectureHandler) GetAllLectures(c *fiber.Ctx) error {
	lectures, err := h.lectureService.GetAllLectures(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data": lectures,
	})
}

// GetLectureByID returns a lecture by ID
func (h *LectureHandler) GetLectureByID(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid lecture ID",
		})
	}

	lecture, err := h.lectureService.GetLectureByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data": lecture,
	})
}

// UpdateLecture updates a lecture's information
func (h *LectureHandler) UpdateLecture(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid lecture ID",
		})
	}

	// Check if the user is updating their own profile
	userID := c.Locals("userID").(uuid.UUID)
	if id != userID {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error": "you can only update your own profile",
		})
	}

	// Get existing lecture
	lecture, err := h.lectureService.GetLectureByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Parse request body
	if err := c.BodyParser(lecture); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid request body",
		})
	}

	// Ensure ID and email cannot be changed
	lecture.ID = id

	// Update lecture
	err = h.lectureService.UpdateLecture(c.Context(), lecture)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"message": "lecture updated successfully",
		"data":    lecture,
	})
}

// DeleteLecture deletes a lecture
func (h *LectureHandler) DeleteLecture(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid lecture ID",
		})
	}

	err = h.lectureService.DeleteLecture(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"message": "lecture deleted successfully",
	})
}

// RegisterRoutes registers all lecture routes
func (h *LectureHandler) RegisterRoutes(app fiber.Router) {
	lectures := app.Group("/lectures")

	// Protected routes
	lectures.Use(h.authMiddleware.Authenticate())
	
	// Routes accessible by admin
	lectures.Get("/", h.GetAllLectures)
	lectures.Delete("/:id", h.authMiddleware.RequireAdmin(), h.DeleteLecture)

	// Routes accessible by lectures and admin
	lectures.Get("/:id", h.authMiddleware.RequireRole("Lecture", "Admin"), h.GetLectureByID)
	lectures.Put("/:id", h.authMiddleware.RequireRole("Lecture", "Admin"), h.UpdateLecture)
} 