package handler

import (
	"errors"
	"fmt"
	"thesis-track/internal/application/middleware"
	"thesis-track/internal/domain/dto"
	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/service"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
	"gorm.io/gorm"
)

type ThesisHandler struct {
	thesisService  service.ThesisService
	progressService service.ProgressService
	authMiddleware *middleware.AuthMiddleware
	emailService   service.EmailService
}

func NewThesisHandler(thesisService service.ThesisService, progressService service.ProgressService, authMiddleware *middleware.AuthMiddleware, emailService service.EmailService) *ThesisHandler {
	return &ThesisHandler{
		thesisService:  thesisService,
		progressService: progressService,
		authMiddleware: authMiddleware,
		emailService:   emailService,
	}
}

// SubmitProposalThesis handles thesis proposal submission
func (h *ThesisHandler) SubmitProposalThesis(c *fiber.Ctx) error {
	var req dto.ThesisRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Get student ID from authenticated user
	studentID := c.Locals("userID").(uuid.UUID)

	supervisorID, err := uuid.Parse(req.SupervisorID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid supervisor ID",
		})
	}

	// Submit thesis with requested supervisor
	thesis, err := h.thesisService.SubmitProposalThesis(c.Context(), &req, studentID, supervisorID)
	if err != nil {
		if err.Error() == "student not found" {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"error": "student not found",
			})
		}
		if err.Error() == "supervisor not found" {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"error": "supervisor not found",
			})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}
	
	// // Assign requested supervisor
	// thesisLecture, err := h.thesisService.AssignSupervisor(c.Context(), thesis.ID, supervisorID)
	// if err != nil {
	// 	return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
	// 		"error": "thesis submitted but failed to assign supervisor: " + err.Error(),
	// 	})
	// }

	// // Get updated thesis with supervisor info
	// updatedThesis, err := h.thesisService.GetThesisByID(c.Context(), thesis.ID)
	// if err != nil {
	// 	return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
	// 		"error": "thesis submitted but failed to get updated data: " + err.Error(),
	// 	})
	// }

	return c.Status(fiber.StatusCreated).JSON(fiber.Map{
		"data": thesis,
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
	
	supervisorID, err := uuid.Parse(req.SupervisorID)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid supervisor ID",
		})
	}

	// Update thesis fields
	thesis.Title = req.Title
	thesis.Abstract = req.Abstract
	thesis.ResearchField = req.ResearchField
	thesis.SupervisorID = supervisorID

	// Update thesis
	updatedThesis, err := h.thesisService.UpdateThesis(c.Context(), thesis)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data": updatedThesis,
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

	_, err = h.thesisService.AssignSupervisor(c.Context(), thesisID, lectureID)
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

	_, err = h.thesisService.AssignExaminer(c.Context(), thesisID, lectureID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"message": "examiner assigned successfully",
	})
}

// ApproveThesisForDefense handles supervisor's approval for a thesis
func (h *ThesisHandler) ApproveThesisForDefense(c *fiber.Ctx) error {
	thesisID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid thesis ID",
		})
	}

	// Get supervisor ID from authenticated user
	lectureID := c.Locals("userID").(uuid.UUID)

	err = h.thesisService.ApproveThesisForDefense(c.Context(), thesisID, lectureID)
	if err != nil {
		switch err.Error() {
		case "thesis not found":
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": err.Error()})
		case "no lecture assigned to this thesis":
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
		case "lecture not assigned to this thesis":
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
		case "only lecture assigned as supervisor can approve thesis for defense":
			return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": err.Error()})
		case "lecture must have at least one progress assigned to them":
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})		
		case "all progress must be reviewed before thesis can be approved":
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
		default:
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
		}
	}

	return c.JSON(fiber.Map{
		"message": "thesis approved successfully",
	})
}

// ApproveThesisForFinalize handles examiner's approval for a thesis
func (h *ThesisHandler) ApproveThesisForFinalize(c *fiber.Ctx) error {
	thesisID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid thesis ID",
		})
	}

	// Get examiner ID from authenticated user
	lectureID := c.Locals("userID").(uuid.UUID)

	err = h.thesisService.ApproveThesisForFinalize(c.Context(), thesisID, lectureID)
	if err != nil {
		switch err.Error() {
		case "thesis not found":
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": err.Error()})
		case "no lecture assigned to this thesis":
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
		case "lecture not assigned to this thesis":
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
		case "only lecture assigned as final defense examiner can approve thesis to be finalized":
			return c.Status(fiber.StatusForbidden).JSON(fiber.Map{"error": err.Error()})
		case "lecture must have at least one progress assigned to them":
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})		
		case "all progress must be reviewed before thesis can be approved":
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
		default:
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
		}
	}
	return c.JSON(fiber.Map{
		"message": "thesis approved successfully",
	})
}

// MarkAsCompleted handles marking a thesis as completed by admin
func (h *ThesisHandler) MarkAsCompleted(c *fiber.Ctx) error {
	thesisID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid thesis ID",
		})
	}

	// Check if thesis is in Under Review status
	thesis, err := h.thesisService.GetThesisByID(c.Context(), thesisID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": err.Error(),
		})
	}
	
	isReadyToMarkAsCompleted := thesis.IsProposalReady && thesis.IsFinalExamReady && thesis.Status == "Under Review"

	if !isReadyToMarkAsCompleted {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "thesis must be approved by all supervisors and examiners to finalize before it can be marked as completed",
		})
	}

	if thesis.FinalDocumentURL == "" {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "student must upload final document before thesis can be marked as completed",
		})
	}

	// Update thesis status to Completed
	err = h.thesisService.UpdateThesisStatus(c.Context(), thesisID, string(entity.ThesisCompleted))
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"message": "thesis marked as completed successfully",
	})
}

// GetThesisProgress returns the progress of a thesis
func (h *ThesisHandler) GetThesisProgress(c *fiber.Ctx) error {
	thesisID, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid thesis ID",
		})
	}

	// Get thesis by ID
	thesis, err := h.thesisService.GetThesisByID(c.Context(), thesisID)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": "thesis not found",
		})
	}

	// Get progress by thesis ID
	progresses, err := h.progressService.GetProgressesByThesisID(c.Context(), thesisID)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to get progress",
		})
	}

	// Calculate thesis progress
	percentageProgress, err := h.thesisService.CalculateThesisProgress(c.Context(), thesis, progresses)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "failed to calculate thesis progress",
		})
	}

	return c.JSON(fiber.Map{
		"data": percentageProgress,
	})
}

// GetMyTheses returns theses based on user's role
func (h *ThesisHandler) GetMyTheses(c *fiber.Ctx) error {
	userID := c.Locals("userID").(uuid.UUID)
	role := c.Locals("userRole").(string)

	fmt.Println("role: ", role)
	fmt.Println("userID: ", userID)

	var theses []entity.Thesis
	var err error

	switch role {
	case "Student":
		theses, err = h.thesisService.GetThesesByStudentID(c.Context(), userID)
	case "Lecture":
		// Get both supervised and examined theses
		supervisedTheses, err1 := h.thesisService.GetThesesByLectureID(c.Context(), userID, "Supervisor")
		if err1 != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error": err1.Error(),
			})
		}

		examinedTheses, err2 := h.thesisService.GetThesesByLectureID(c.Context(), userID, "Examiner")
		if err2 != nil {
			return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
				"error": err2.Error(),
			})
		}

		// Combine and deduplicate theses
		thesesMap := make(map[uuid.UUID]entity.Thesis)
		for _, t := range supervisedTheses {
			thesesMap[t.ID] = t
		}
		for _, t := range examinedTheses {
			thesesMap[t.ID] = t
		}

		theses = make([]entity.Thesis, 0, len(thesesMap))
		for _, t := range thesesMap {
			theses = append(theses, t)
		}
	case "Admin":
		theses, err = h.thesisService.GetAllTheses(c.Context())
	}

	if err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
				"error": "no theses found",
			})
		}
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data": theses,
	})
}

// RegisterRoutes registers all thesis routes
func (h *ThesisHandler) RegisterRoutes(app fiber.Router) {
	theses := app.Group("/theses")

	// Protected routes
	theses.Use(h.authMiddleware.Authenticate())

	// Student routes
	theses.Post("/", middleware.ValidateRequest(&dto.ThesisRequest{}), h.authMiddleware.RequireStudent(), h.SubmitProposalThesis)
	theses.Put("/:id", h.authMiddleware.RequireStudent(), h.UpdateThesis)

	// Admin routes
	theses.Post("/:id/supervisor/:lecture_id", h.authMiddleware.RequireAdmin(), h.AssignSupervisor)
	theses.Post("/:id/examiner/:lecture_id", h.authMiddleware.RequireAdmin(), h.AssignExaminer)
	theses.Post("/:id/complete", h.authMiddleware.RequireAdmin(), h.MarkAsCompleted)

	// Lecture routes
	theses.Post("/:id/approve/defense", h.authMiddleware.RequireLecture(), h.ApproveThesisForDefense)
	theses.Post("/:id/approve/finalize", h.authMiddleware.RequireLecture(), h.ApproveThesisForFinalize)
	
	// Routes accessible by all authenticated users
	theses.Get("/", h.GetAllTheses)
	theses.Get("/me", h.GetMyTheses)
	theses.Get("/:id", h.GetThesisByID)
	theses.Get("/student/:studentId", h.GetThesesByStudent)
	theses.Get("/:id/progress", h.GetThesisProgress)
}
