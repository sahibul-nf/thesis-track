package server

import (
	"thesis-track/internal/handlers"

	"github.com/gofiber/fiber/v2"
)

func NewServer() *fiber.App {
	app := fiber.New()

	// Register routes
	handlers.RegisterStudentRoutes(app)
	// handlers.RegisterThesisRoutes(app)
	// handlers.RegisterProgressRoutes(app)

	return app
}
