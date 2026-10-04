package main

import (
	"log"

	"github.com/joho/godotenv"

	_ "github.com/satishreddykarri/shortlab/docs"

	"github.com/satishreddykarri/shortlab/database"
	"github.com/satishreddykarri/shortlab/models"
	"github.com/satishreddykarri/shortlab/repositories"
	"github.com/satishreddykarri/shortlab/routes"
	"github.com/satishreddykarri/shortlab/services"
)

// @title ShortLab API
// @version 1.0
// @description Configurable URL shortening platform with multiple shortening strategies and analytics.
// @host localhost:8080
// @BasePath /
//
// @securityDefinitions.apikey BearerAuth
// @in header
// @name Authorization
// @description Enter your JWT token with the Bearer prefix. Example: Bearer eyJhbGciOiJIUzI1NiIs...
func main() {
	err := godotenv.Load()

	if err != nil {
		log.Fatal("Error loading .env file")
	}

	database.Connect()

	err = database.DB.AutoMigrate(
		&models.User{},
		&models.URL{},
		&models.URLClick{},
	)

	if err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	// Build the authentication dependency chain.
	userRepository := repositories.NewUserRepository(database.DB)
	urlService := services.NewURLService(
		repositories.NewURLRepository(database.DB),
	)
	clickRepository := repositories.NewURLClickRepository(database.DB)
	clickService := services.NewURLClickService(
		clickRepository,
	)
	analyticsService := services.NewURLAnalyticsService(
		repositories.NewURLRepository(database.DB),
		clickRepository,
	)
	emailService := services.NewEmailService()
	jwtService := services.NewJWTService()
	authService := services.NewAuthService(userRepository, emailService, jwtService)

	router := routes.SetupRouter(authService, urlService, clickService, analyticsService, jwtService)

	log.Println("ShortLab backend starting on :8080")

	if err := router.Run(":8080"); err != nil {
		log.Fatal(err)
	}
}
