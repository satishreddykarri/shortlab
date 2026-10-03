package main

import (
	"log"

	"github.com/joho/godotenv"

	"github.com/satishreddykarri/shortlab/database"
	"github.com/satishreddykarri/shortlab/models"
	"github.com/satishreddykarri/shortlab/repositories"
	"github.com/satishreddykarri/shortlab/routes"
	"github.com/satishreddykarri/shortlab/services"
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

	// Build the authentication dependency chain.
	userRepository := repositories.NewUserRepository(database.DB)
	emailService := services.NewEmailService()
	authService := services.NewAuthService(userRepository, emailService)

	router := routes.SetupRouter(authService)

	log.Println("ShortLab backend starting on :8080")

	if err := router.Run(":8080"); err != nil {
		log.Fatal(err)
	}
}
