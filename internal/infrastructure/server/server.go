package server

import (
	"thesis-track/internal/application/handler"
	"thesis-track/internal/application/middleware"
	"thesis-track/internal/domain/service"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"
)

type Server struct {
	app            *fiber.App
	adminHandler   *handler.AdminHandler
	authHandler    *handler.AuthHandler
	studentHandler *handler.StudentHandler
	lectureHandler *handler.LectureHandler
	thesisHandler  *handler.ThesisHandler
	progressHandler *handler.ProgressHandler
	documentHandler *handler.DocumentHandler
}

func NewServer(
	adminService service.AdminService,
	authService service.AuthService,
	studentService service.StudentService,
	lectureService service.LectureService,
	thesisService service.ThesisService,
	progressService service.ProgressService,
	documentService service.DocumentService,
) *Server {
	// Create Fiber app
	app := fiber.New(fiber.Config{
		ErrorHandler: func(c *fiber.Ctx, err error) error {
			code := fiber.StatusInternalServerError
			if e, ok := err.(*fiber.Error); ok {
				code = e.Code
			}
			return c.Status(code).JSON(fiber.Map{
				"error": err.Error(),
			})
		},
	})

	// Middleware
	app.Use(logger.New())
	app.Use(recover.New())
	app.Use(cors.New(cors.Config{
		AllowOrigins: "*",
		AllowHeaders: "Origin, Content-Type, Accept, Authorization",
		AllowMethods: "GET, POST, PUT, DELETE",
	}))

	// Create auth middleware
	authMiddleware := middleware.NewAuthMiddleware(authService)

	// Create handlers
	authHandler := handler.NewAuthHandler(authService)
	studentHandler := handler.NewStudentHandler(studentService, authMiddleware)
	lectureHandler := handler.NewLectureHandler(lectureService, authMiddleware)
	thesisHandler := handler.NewThesisHandler(thesisService, authMiddleware)
	progressHandler := handler.NewProgressHandler(progressService, thesisService, authMiddleware)
	documentHandler := handler.NewDocumentHandler(documentService, thesisService, progressService, authMiddleware)
	adminHandler := handler.NewAdminHandler(adminService, authMiddleware)

	return &Server{
		app:            app,
		authHandler:    authHandler,
		studentHandler: studentHandler,
		lectureHandler: lectureHandler,
		thesisHandler:  thesisHandler,
		progressHandler: progressHandler,
		documentHandler: documentHandler,
		adminHandler: adminHandler,
	}
}

func (s *Server) Start(port string) error {
	// Setup routes
	s.setupRoutes()

	// Start server
	return s.app.Listen(port)
}

func (s *Server) setupRoutes() {
	s.app.Get("/", func(c *fiber.Ctx) error {
		return c.SendString("Hello, World!")
	})

	api := s.app.Group("/api")
	v1 := api.Group("/v1")

	// Register routes for each handler
	s.authHandler.RegisterRoutes(v1)
	s.studentHandler.RegisterRoutes(v1)
	s.lectureHandler.RegisterRoutes(v1)
	s.thesisHandler.RegisterRoutes(v1)
	s.progressHandler.RegisterRoutes(v1)
	s.documentHandler.RegisterRoutes(v1)
	s.adminHandler.RegisterRoutes(v1)
} 