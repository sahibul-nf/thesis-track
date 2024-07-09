package handlers

import (
	"thesis-track/internal/entities"
	"thesis-track/internal/infrastructure/database"
	"thesis-track/internal/repositories"
	"thesis-track/internal/services"

	"github.com/gofiber/fiber/v2"
	"github.com/google/uuid"
)

type StudentHandler struct {
	studentService services.StudentService
}

func NewStudentHandler(studentService services.StudentService) *StudentHandler {
	return &StudentHandler{studentService}
}

func (h *StudentHandler) GetAllStudents(c *fiber.Ctx) error {
	students, err := h.studentService.GetAllStudents()
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(students)
}

func (h *StudentHandler) GetStudentByID(c *fiber.Ctx) error {
	id := c.Params("id")
	student, err := h.studentService.GetStudentByID(id)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(student)
}

func (h *StudentHandler) CreateStudent(c *fiber.Ctx) error {
	var student entities.Student
	if err := c.BodyParser(&student); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	student.ID = uuid.New()
	if err := h.studentService.CreateStudent(&student); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.Status(fiber.StatusCreated).JSON(student)
}

func (h *StudentHandler) UpdateStudent(c *fiber.Ctx) error {
	id := c.Params("id")
	var student entities.Student
	if err := c.BodyParser(&student); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{"error": err.Error()})
	}
	student.ID = uuid.MustParse(id)
	if err := h.studentService.UpdateStudent(&student); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.JSON(student)
}

func (h *StudentHandler) DeleteStudent(c *fiber.Ctx) error {
	id := c.Params("id")
	if err := h.studentService.DeleteStudent(id); err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{"error": err.Error()})
	}
	return c.SendStatus(fiber.StatusNoContent)
}

func RegisterStudentRoutes(app *fiber.App) {
	handler := NewStudentHandler(services.NewStudentService(repositories.NewStudentRepository(database.DB)))

	app.Get("/students", handler.GetAllStudents)
	app.Get("/students/:id", handler.GetStudentByID)
	app.Post("/students", handler.CreateStudent)
	app.Put("/students/:id", handler.UpdateStudent)
	app.Delete("/students/:id", handler.DeleteStudent)
}
