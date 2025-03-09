package handler

import (
	"thesis-track/internal/application/middleware"
	"thesis-track/internal/domain/service"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type StudentHandler struct {
	studentService service.StudentService
	authMiddleware *middleware.AuthMiddleware
}

func NewStudentHandler(studentService service.StudentService, authMiddleware *middleware.AuthMiddleware) *StudentHandler {
	return &StudentHandler{
		studentService: studentService,
		authMiddleware: authMiddleware,
	}
}

// GetAllStudents returns all students
func (h *StudentHandler) GetAllStudents(c *fiber.Ctx) error {
	students, err := h.studentService.GetAllStudents(c.Context())
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data": students,
	})
}

// GetStudentByID returns a student by ID
func (h *StudentHandler) GetStudentByID(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid student ID",
		})
	}

	student, err := h.studentService.GetStudentByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data": student,
	})
}

// UpdateStudent updates a student's information
func (h *StudentHandler) UpdateStudent(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "invalid student ID",
		})
	}

	// Check if the user is updating their own profile
	userID := c.Locals("userID").(uuid.UUID)
	if id != userID {
		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error": "you can only update your own profile",
		})
	}

	// Get existing student
	student, err := h.studentService.GetStudentByID(c.Context(), id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Parse request body
	if err := c.BodyParser(student); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Ensure ID and email cannot be changed
	student.ID = id

	// Update student
	err = h.studentService.UpdateStudent(c.Context(), student)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(fiber.Map{
		"data":    student,
	})
}

// RegisterRoutes registers all student routes
func (h *StudentHandler) RegisterRoutes(app fiber.Router) {
	students := app.Group("/students")

	// Protected routes
	students.Use(h.authMiddleware.Authenticate())
	
	// Routes accessible by admin
	students.Get("/", h.authMiddleware.RequireAdmin(), h.GetAllStudents)

	// Routes accessible by students and admin
	students.Get("/:id", h.GetStudentByID)
	students.Put("/:id", h.authMiddleware.RequireRole("Student", "Admin"), h.UpdateStudent)
} 