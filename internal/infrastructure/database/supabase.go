package database

import (
	"fmt"
	"thesis-track/config"

	"github.com/supabase-community/supabase-go"
)

var SupabaseClient *supabase.Client

func ConnectSupabase() {
	Config := config.GetConfig()

	client, err := supabase.NewClient(
		Config.SupabaseURL,
		Config.SupabaseKey,
		nil,
	)

	if err != nil {
		panic("failed to connect supabase")
	}

	SupabaseClient = client

	fmt.Println("Supabase connected")
}
