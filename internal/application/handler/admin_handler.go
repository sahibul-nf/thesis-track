package handler

import (
	"net/http"

	"thesis-track/internal/application/middleware"
	"thesis-track/internal/domain/entity"
	"thesis-track/internal/domain/service"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type AdminHandler struct {
	adminService service.AdminService
	authMiddleware *middleware.AuthMiddleware
}

func NewAdminHandler(adminService service.AdminService, authMiddleware *middleware.AuthMiddleware) *AdminHandler {
	return &AdminHandler{
		adminService: adminService,
		authMiddleware: authMiddleware,
	}
}

func (h *AdminHandler) CreateAdmin(c *fiber.Ctx) error {
	var admin entity.Admin
	if err := c.BodyParser(&admin); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	if err := h.adminService.CreateAdmin(c.Context(), &admin); err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.Status(http.StatusCreated).JSON(admin)
}

func (h *AdminHandler) UpdateAdmin(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid admin ID",
		})
	}

	var admin entity.Admin
	if err := c.BodyParser(&admin); err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	admin.ID = id
	if err := h.adminService.UpdateAdmin(c.Context(), &admin); err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(admin)
}

func (h *AdminHandler) DeleteAdmin(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid admin ID",
		})
	}

	if err := h.adminService.DeleteAdmin(c.Context(), id); err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.SendStatus(http.StatusNoContent)
}

func (h *AdminHandler) GetAdminByID(c *fiber.Ctx) error {
	id, err := uuid.Parse(c.Params("id"))
	if err != nil {
		return c.Status(http.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid admin ID",
		})
	}

	admin, err := h.adminService.GetAdminByID(c.Context(), id)
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(admin)
}

func (h *AdminHandler) GetAllUsers(c *fiber.Ctx) error {
	students, lectures, err := h.adminService.GetAllUsers(c.Context())
	if err != nil {
		return c.Status(http.StatusInternalServerError).JSON(fiber.Map{
			"error": err.Error(),
		})
	}	

	totalUsers := len(students) + len(lectures)

	return c.JSON(fiber.Map{
		"data": fiber.Map{
			"count": totalUsers,
			"students": students,
			"lectures": lectures,
		},
	})
}

// RegisterRoutes registers all admin routes
func (h *AdminHandler) RegisterRoutes(app fiber.Router) {
	// Public routes
	app.Get("/users", h.GetAllUsers)

	// Protected routes
	admin := app.Group("/admin")
	admin.Use(h.authMiddleware.Authenticate())
	admin.Use(h.authMiddleware.RequireAdmin())

	// Admin management
	admin.Post("/", h.CreateAdmin)
	admin.Put("/:id", h.UpdateAdmin) 
	admin.Delete("/:id", h.DeleteAdmin)
	admin.Get("/:id", h.GetAdminByID)

	// Student management
	// admin.Delete("/students/:id", h.DeleteStudent)

	// Lecture management 
	// admin.Delete("/lectures/:id", h.DeleteLecture)

	// Thesis management
	// admin.Post("/theses/:thesis_id/supervisor/:lecture_id", h.AssignThesisSupervisor)
	// admin.Post("/theses/:thesis_id/examiner/:lecture_id", h.AssignThesisExaminer)
}
