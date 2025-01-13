package main

import (
	"fmt"
	"log"
	"thesis-track/config"
	"thesis-track/internal/application/repository"
	"thesis-track/internal/application/service"
	"thesis-track/internal/infrastructure/database"
	"thesis-track/internal/infrastructure/server"
)

func main() {
	// Load configuration
	if err := config.LoadConfig(); err != nil {
		log.Fatal("Failed to load config:", err)
	}

	// Validate configuration
	if err := config.ValidateConfig(); err != nil {
		log.Fatal("Invalid configuration:", err)
	}

	// Connect to database
	db, err := database.ConnectDB()
	if err != nil {
		log.Fatal("Failed to connect to database:", err)
	}

	// Connect to Supabase
	supabase, err := database.ConnectSupabase()
	if err != nil {
		log.Fatal("Failed to connect to Supabase:", err)
	}

	// Initialize repositories
	studentRepo := repository.NewStudentRepository(db)
	lectureRepo := repository.NewLectureRepository(db)
	adminRepo := repository.NewAdminRepository(db)
	thesisRepo := repository.NewThesisRepository(db)
	progressRepo := repository.NewProgressRepository(db)
	thesisLectureRepo := repository.NewThesisLectureRepository(db)
	commentRepo := repository.NewCommentRepository(db)

	// Initialize services
	authService := service.NewAuthService(studentRepo, lectureRepo, adminRepo, supabase)
	studentService := service.NewStudentService(studentRepo)
	lectureService := service.NewLectureService(lectureRepo)
	thesisService := service.NewThesisService(thesisRepo, thesisLectureRepo, studentRepo, lectureRepo)
	progressService := service.NewProgressService(progressRepo, thesisRepo, commentRepo, studentRepo, lectureRepo)
	documentService := service.NewDocumentService(thesisRepo, progressRepo, supabase)
	adminService := service.NewAdminService(adminRepo, studentRepo, lectureRepo, thesisRepo)
	
	// Create and start server
	srv := server.NewServer(
		adminService,
		authService,
		studentService,
		lectureService,
		thesisService,
		progressService,
		documentService,
	)

	port := config.GetString("PORT", "8080")
	log.Printf("Server starting on port %s", port)
	if err := srv.Start(fmt.Sprintf(":%s", port)); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
