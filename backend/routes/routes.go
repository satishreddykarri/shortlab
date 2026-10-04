package routes

import (
	"github.com/gin-gonic/gin"
	"github.com/satishreddykarri/shortlab/handlers"
	"github.com/satishreddykarri/shortlab/middleware"
	"github.com/satishreddykarri/shortlab/services"
	swaggerFiles "github.com/swaggo/files"
	ginSwagger "github.com/swaggo/gin-swagger"
)

func SetupRouter(authService *services.AuthService, urlService *services.URLService, clickService *services.URLClickService, analyticsService *services.URLAnalyticsService, jwtService *services.JWTService) *gin.Engine {
	router := gin.Default()

	authHandler := handlers.NewAuthHandler(authService)

	// Authentication routes.
	authRoutes := router.Group("/api/auth")
	{
		authRoutes.POST("/register", authHandler.Register)
		authRoutes.POST("/verify-email", authHandler.VerifyEmail)
		authRoutes.POST("/login", authHandler.Login)
	}

	urlHandler := handlers.NewURLHandler(urlService, clickService, analyticsService)

	urlRoutes := router.Group("/api/urls")
	urlRoutes.Use(middleware.AuthRequired(jwtService))
	{
		urlRoutes.POST("", urlHandler.Create)
		urlRoutes.GET("", urlHandler.List)
		urlRoutes.DELETE("/:id", urlHandler.Delete)
		urlRoutes.GET("/:id/analytics", urlHandler.Analytics)
		urlRoutes.GET("/:id", urlHandler.GetByID)
	}
	router.GET("/:shortCode", urlHandler.Redirect)
	router.GET(
		"/swagger/*any",
		ginSwagger.WrapHandler(swaggerFiles.Handler),
	)

	return router
}
