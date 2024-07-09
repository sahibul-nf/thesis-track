package main

import (
	"log"
	"thesis-track/config"
	"thesis-track/internal/infrastructure/database"
	"thesis-track/internal/infrastructure/server"
)

func main() {
	config.LoadConfig()

	database.ConnectDB()
	database.ConnectSupabase()

	app := server.NewServer()
	log.Fatal(app.Listen(":3000"))
}
