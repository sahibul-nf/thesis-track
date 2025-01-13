package config

import (
	"fmt"
	"os"

	"github.com/joho/godotenv"
)

// LoadConfig loads environment variables from .env file
func LoadConfig() error {
	if err := godotenv.Load("../.env"); err != nil {
		return fmt.Errorf("error loading .env file: %w", err)
	}
	return nil
}

// GetString returns the value of an environment variable or a default value
func GetString(key string, defaultValue string) string {
	if value, exists := os.LookupEnv(key); exists {
		return value
	}
	return defaultValue
}

// Required environment variables
var requiredEnvVars = []string{
	"DB_HOST",
	"DB_USER",
	"DB_PASSWORD",
	"DB_NAME",
	"DB_PORT",
	"SUPABASE_URL",
	"SUPABASE_KEY",
	"JWT_SECRET",
}

// ValidateConfig checks if all required environment variables are set
func ValidateConfig() error {
	for _, envVar := range requiredEnvVars {
		if os.Getenv(envVar) == "" {
			return fmt.Errorf("required environment variable %s is not set", envVar)
		}
	}
	return nil
}
