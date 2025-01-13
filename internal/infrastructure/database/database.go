package database

import (
	"fmt"
	"log"
	"os"
	"thesis-track/internal/domain/entity"

	// "github.com/supabase-community/gotrue-go"
	// storage_go "github.com/supabase-community/storage-go"

	"github.com/supabase-community/supabase-go"
	"gorm.io/driver/postgres"
	"gorm.io/gorm"
)

var (
	// DB            *gorm.DB
	// SupabaseAuth  *gotrue.Client
	// SupabaseStore *storage_go.Client
	// Supabase *supabase.Client
)

// ConnectDB establishes a connection to the PostgreSQL database
func ConnectDB() (*gorm.DB, error) {
	dsn := fmt.Sprintf("host=%s user=%s password=%s dbname=%s port=%s sslmode=disable",
		os.Getenv("DB_HOST"),
		os.Getenv("DB_USER"),
		os.Getenv("DB_PASSWORD"),
		os.Getenv("DB_NAME"),
		os.Getenv("DB_PORT"),
	)

	db, err := gorm.Open(postgres.Open(dsn), &gorm.Config{})
	if err != nil {
		return nil, fmt.Errorf("failed to connect to database: %w", err)
	}

	log.Println("Database connected successfully")

	// DB = db

	// Enable UUID extension if not exists
    if err := db.Exec("CREATE EXTENSION IF NOT EXISTS \"uuid-ossp\";").Error; err != nil {
        return nil, fmt.Errorf("failed to create uuid extension: %w", err)
    }

	// Auto Migrate the schemas
	if err := db.AutoMigrate(
		&entity.Student{},
		&entity.Lecture{},
		&entity.Admin{},
		&entity.Thesis{},
		&entity.Progress{},
		&entity.ThesisLecture{},
		&entity.Comment{},
	); err != nil {
		return nil, fmt.Errorf("failed to migrate database: %w", err)
	}

	log.Println("Database migrated successfully")

	// Add foreign key constraints to auth.users
    constraints := []string{
        `ALTER TABLE students 
         ADD CONSTRAINT students_id_fkey 
         FOREIGN KEY (id) REFERENCES auth.users(id) 
         ON DELETE CASCADE ON UPDATE CASCADE;`,

        `ALTER TABLE lectures 
         ADD CONSTRAINT lectures_id_fkey 
         FOREIGN KEY (id) REFERENCES auth.users(id) 
         ON DELETE CASCADE ON UPDATE CASCADE;`,

        `ALTER TABLE admins 
         ADD CONSTRAINT admins_id_fkey 
         FOREIGN KEY (id) REFERENCES auth.users(id) 
         ON DELETE CASCADE ON UPDATE CASCADE;`,

        // `ALTER TABLE thesis_lectures 
        //  ADD CONSTRAINT thesis_lectures_thesis_id_fkey 
        //  FOREIGN KEY (thesis_id) REFERENCES thesis(id) 
        //  ON DELETE CASCADE ON UPDATE CASCADE;`,
    }

    // Execute each constraint
    for _, constraint := range constraints {
        // Wrap in try-catch block to handle if constraint already exists
        if err := db.Exec(fmt.Sprintf(`
            DO $$
            BEGIN
                %s
            EXCEPTION WHEN duplicate_object THEN
                NULL;
            END $$;
        `, constraint)).Error; err != nil {
            return nil, fmt.Errorf("failed to add foreign key constraint: %w", err)
        }
    }

	log.Println("Foreign key constraints added successfully")
	
	return db, nil
}

func ConnectSupabase() (*supabase.Client, error) {
	// Initialize Supabase client
	supabaseClient, err := supabase.NewClient(os.Getenv("SUPABASE_URL"), os.Getenv("SUPABASE_KEY"), &supabase.ClientOptions{})
	if err != nil {
		log.Fatal("Failed to connect to Supabase:", err)
	}
	// Supabase = supabaseClient

	// // Initialize Supabase Auth client
	// authClient := gotrue.New(os.Getenv("SUPABASE_URL"), os.Getenv("SUPABASE_KEY"))
	// SupabaseAuth = &authClient

	// // Initialize Supabase Storage client
	// storageClient := storage.NewClient(os.Getenv("SUPABASE_URL"), os.Getenv("SUPABASE_KEY"), nil)
	// SupabaseStore = storageClient

	log.Println("Supabase connected successfully")
	return supabaseClient, nil
}
