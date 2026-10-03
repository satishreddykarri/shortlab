package main

import (
	"log"

	"github.com/joho/godotenv"
	"github.com/satishreddykarri/shortlab/database"
	"github.com/satishreddykarri/shortlab/models"
)

func main() {

	err := godotenv.Load()

	if err != nil {
		log.Fatal("Error loading .env file")
	}

	database.Connect()
	err = database.DB.AutoMigrate(
		&models.User{},
		&models.URL{},
	)

	if err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	log.Println("Database migration completed successfully")

	log.Println("ShortLab backend starting...")
}
