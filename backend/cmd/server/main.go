package main

import (
	"log"
	"os"

	"github.com/joho/godotenv"

	"github.com/satishreddykarri/shortlab/config"
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
	// Load local environment variables.
	// On Render, environment variables are supplied by the platform.
	if err := godotenv.Load(); err != nil {
		if !os.IsNotExist(err) {
			log.Printf("Warning: could not load .env file: %v", err)
		}
	}

	cfg := config.Load()

	// Connect to the configured PostgreSQL database.
	database.Connect()

	// Run database migrations.
	if err := database.DB.AutoMigrate(
		&models.User{},
		&models.URL{},
		&models.URLClick{},
	); err != nil {
		log.Fatal("Failed to migrate database:", err)
	}

	// Initialize repositories.
	userRepository := repositories.NewUserRepository(database.DB)
	urlRepository := repositories.NewURLRepository(database.DB)
	clickRepository := repositories.NewURLClickRepository(database.DB)

	// Initialize services.
	urlService := services.NewURLService(urlRepository)

	clickService := services.NewURLClickService(clickRepository)

	analyticsService := services.NewURLAnalyticsService(
		urlRepository,
		clickRepository,
	)

	emailService := services.NewEmailService()
	jwtService := services.NewJWTService()

	authService := services.NewAuthService(
		userRepository,
		emailService,
		jwtService,
	)

	// Configure application routes.
	router := routes.SetupRouter(
		authService,
		urlService,
		clickService,
		analyticsService,
		jwtService,
		cfg.FrontendURL,
	)

	// Render provides PORT automatically.
	// Use 8080 when running locally.
	port := os.Getenv("PORT")
	if port == "" {
		port = "8080"
	}

	log.Printf("ShortLab backend starting on port %s", port)

	// Listen on all network interfaces.
	if err := router.Run("0.0.0.0:" + port); err != nil {
		log.Fatal("Failed to start server:", err)
	}
}
