package routes

import (
	"github.com/gin-gonic/gin"
	"github.com/satishreddykarri/shortlab/handlers"
	"github.com/satishreddykarri/shortlab/services"
)

func SetupRouter(authService *services.AuthService) *gin.Engine {
	router := gin.Default()

	authHandler := handlers.NewAuthHandler(authService)

	// Authentication routes.
	authRoutes := router.Group("/api/auth")
	{
		authRoutes.POST("/register", authHandler.Register)
		authRoutes.POST("/verify-email", authHandler.VerifyEmail)
	}

	return router
}