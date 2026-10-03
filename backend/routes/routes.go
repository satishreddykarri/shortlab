package routes

import (
	"github.com/gin-gonic/gin"
	"github.com/satishreddykarri/shortlab/handlers"
	"github.com/satishreddykarri/shortlab/middleware"
	"github.com/satishreddykarri/shortlab/services"
)

func SetupRouter(authService *services.AuthService, urlService *services.URLService, clickService *services.URLClickService, jwtService *services.JWTService) *gin.Engine {
	router := gin.Default()

	authHandler := handlers.NewAuthHandler(authService)

	// Authentication routes.
	authRoutes := router.Group("/api/auth")
	{
		authRoutes.POST("/register", authHandler.Register)
		authRoutes.POST("/verify-email", authHandler.VerifyEmail)
		authRoutes.POST("/login", authHandler.Login)
	}

	urlHandler := handlers.NewURLHandler(urlService, clickService)

	urlRoutes := router.Group("/api/urls")
	urlRoutes.Use(middleware.AuthRequired(jwtService))
	{
		urlRoutes.POST("", urlHandler.Create)
		urlRoutes.GET("", urlHandler.List)
		urlRoutes.DELETE("/:id", urlHandler.Delete)
	}
	router.GET("/:shortCode", urlHandler.Redirect)

	return router
}
