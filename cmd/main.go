package main

import (
	"log"
	"thesis-track/config"
	"thesis-track/internal/infrastructure/database"
	"thesis-track/internal/infrastructure/server"
)

func main() {
	config, err := config.LoadConfig()
	if err != nil {
		log.Fatalf("Could not load config: %v", err)
	}

	database.ConnectDB(config)
	database.ConnectSupabase(config)

	app := server.NewServer()
	log.Fatal(app.Listen(":3000"))
}
