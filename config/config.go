package config

import (
	"os"

	"github.com/joho/godotenv"
)

type Config struct {
	DBUser          string
	DBPassword      string
	DBHost          string
	DBPort          string
	DBName          string
	SupabaseURL     string
	SupabaseKey     string
	SupabaseAnonKey string
	JWTSecretKey    string
}

var config Config

func GetConfig() Config {
	return config
}

func LoadConfig() {
	config.DBUser = os.Getenv("DB_USER")
	config.DBPassword = os.Getenv("DB_PASSWORD")
	config.DBHost = os.Getenv("DB_HOST")
	config.DBPort = os.Getenv("DB_PORT")
	config.DBName = os.Getenv("DB_NAME")
	config.SupabaseURL = os.Getenv("SUPABASE_URL")
	config.SupabaseKey = os.Getenv("SUPABASE_KEY")
	config.JWTSecretKey = os.Getenv("JWT_SECRET_KEY")
}

func init() {
	err := godotenv.Load()
	if err != nil {
		panic("Error loading .env file")
	}
}
