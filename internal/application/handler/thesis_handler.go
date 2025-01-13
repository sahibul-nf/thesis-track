package handler

import (
	"thesis-track/internal/application/middleware"
	"thesis-track/internal/domain/dto"
	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/service"
	"time"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type ThesisHandler struct {
	thesisService  service.ThesisService
	authMiddleware *middleware.AuthMiddleware
}

func NewThesisHandler(thesisService service.ThesisService, authMiddleware *middleware.AuthMiddleware) *ThesisHandler {
	return &ThesisHandler{
		thesisService:  thesisService,
		authMiddleware: authMiddleware,
	}
}

// SubmitThesis handles thesis submission
func (h *ThesisHandler) SubmitThesis(c *fiber.Ctx) error {
	var req dto.ThesisRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Get student ID from authenticated user
	studentID := c.Locals("userID").(uuid.UUID)

	// Create thesis entity
	thesis := &entity.Thesis{
		StudentID:      studentID,
		Title:          req.Title,
		Abstract:       req.Abstract,
		ResearchField:  req.ResearchField,
		SubmissionDate: time.Now(),
		Status:         "Proposed",
	}

	// Submit thesis and assign supervisor
	err := h.thesisService.SubmitThesis(c.Context(), thesis)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	supervisorID, err := uuid.Parse(req.SupervisorID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid supervisor ID",
		})
	}
	
	// Assign requested supervisor
	err = h.thesisService.AssignSupervisor(c.Context(), thesis.ID, supervisorID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "thesis submitted but failed to assign supervisor: " + err.Error(),
		})
	}

	// Get updated thesis with supervisor info
	updatedThesis, err := h.thesisService.GetThesisByID(c.Context(), thesis.ID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "thesis submitted but failed to get updated data: " + err.Error(),
		})
	}

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"data": updatedThesis,
	})
}

// GetAllTheses returns all theses
func (h *ThesisHandler) GetAllTheses(c *fiber.Ctx) error {
	theses, err := h.thesisService.GetAllTheses(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data": theses,
	})
}

// GetThesisByID returns a thesis by ID
func (h *ThesisHandler) GetThesisByID(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid thesis ID",
		})
	}

	thesis, err := h.thesisService.GetThesisByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data": thesis,
	})
}

// GetThesesByStudent returns all theses for a student
func (h *ThesisHandler) GetThesesByStudent(c *fiber.Ctx) error {
	studentID, err := uuid.Parse(c.Params("studentId"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid student ID",
		})
	}

	theses, err := h.thesisService.GetThesesByStudentID(c.Context(), studentID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data": theses,
	})
}

// UpdateThesis updates a thesis
func (h *ThesisHandler) UpdateThesis(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid thesis ID",
		})
	}

	// Get existing thesis
	thesis, err := h.thesisService.GetThesisByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Check if the user is the thesis owner
	userID := c.Locals("userID").(uuid.UUID)
	if thesis.StudentID != userID {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error": "you can only update your own thesis",
		})
	}

	// Parse request body
	var req dto.ThesisRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid request body",
		})
	}

	// Update thesis fields
	thesis.Title = req.Title
	thesis.Abstract = req.Abstract

	// Update thesis
	err = h.thesisService.UpdateThesis(c.Context(), thesis)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data":    thesis,
	})
}

// AssignSupervisor assigns a supervisor to a thesis
func (h *ThesisHandler) AssignSupervisor(c *fiber.Ctx) error {
	thesisID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid thesis ID",
		})
	}

	lectureID, err := uuid.Parse(c.Params("lecture_id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid lecture ID",
		})
	}

	err = h.thesisService.AssignSupervisor(c.Context(), thesisID, lectureID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"message": "supervisor assigned successfully",
	})
}

// AssignExaminer assigns an examiner to a thesis
func (h *ThesisHandler) AssignExaminer(c *fiber.Ctx) error {
	thesisID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid thesis ID",
		})
	}

	lectureID, err := uuid.Parse(c.Params("lecture_id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid lecture ID",
		})
	}

	err = h.thesisService.AssignExaminer(c.Context(), thesisID, lectureID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"message": "examiner assigned successfully",
	})
}

// ApproveThesis handles supervisor's approval for a thesis
func (h *ThesisHandler) ApproveThesis(c *fiber.Ctx) error {
	thesisID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid thesis ID",
		})
	}

	// Get supervisor ID from authenticated user
	supervisorID := c.Locals("userID").(uuid.UUID)

	err = h.thesisService.ApproveThesis(c.Context(), thesisID, supervisorID)
	if err != nil {
		if err.Error() == "only assigned supervisors can approve thesis" {
			return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
				"error": err.Error(),
			})
		}
		if err.Error() == "all progress must be reviewed before thesis can be approved" {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error": err.Error(),
			})
		}
		if err.Error() == "thesis not found" {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"error": err.Error(),
			})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"message": "thesis approved successfully",
	})
}

// RegisterRoutes registers all thesis routes
func (h *ThesisHandler) RegisterRoutes(app fiber.Router) {
	theses := app.Group("/theses")

	// Protected routes
	theses.Use(h.authMiddleware.Authenticate())

	// Student routes
	theses.Post("/", middleware.ValidateRequest(&dto.ThesisRequest{}), h.authMiddleware.RequireStudent(), h.SubmitThesis)
	theses.Put("/:id", h.authMiddleware.RequireStudent(), h.UpdateThesis)

	// Admin routes
	theses.Post("/:id/supervisor/:lecture_id", h.authMiddleware.RequireAdmin(), h.AssignSupervisor)
	theses.Post("/:id/examiner/:lecture_id", h.authMiddleware.RequireAdmin(), h.AssignExaminer)
	theses.Post("/:id/approve", h.authMiddleware.RequireLecture(), h.ApproveThesis)
	
	// Routes accessible by all authenticated users
	theses.Get("/", h.GetAllTheses)
	theses.Get("/:id", h.GetThesisByID)
	theses.Get("/student/:studentId", h.GetThesesByStudent)
}
