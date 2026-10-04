package handlers

import (
	"errors"
	"net/http"
	"strconv"
	"time"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/satishreddykarri/shortlab/middleware"
	"github.com/satishreddykarri/shortlab/services"
	"gorm.io/gorm"
)

type URLHandler struct {
	urlService       *services.URLService
	clickService     *services.URLClickService
	analyticsService *services.URLAnalyticsService
}

func NewURLHandler(urlService *services.URLService, clickService *services.URLClickService, analyticsService *services.URLAnalyticsService) *URLHandler {
	return &URLHandler{
		urlService:       urlService,
		clickService:     clickService,
		analyticsService: analyticsService,
	}
}

type CreateURLRequest struct {
	OriginalURL string     `json:"original_url" binding:"required,url"`
	Algorithm   string     `json:"algorithm" binding:"required"`
	CustomAlias string     `json:"custom_alias"`
	ExpiresAt   *time.Time `json:"expires_at"`
}

func (h *URLHandler) Create(c *gin.Context) {
	userIDValue, exists := c.Get(middleware.UserIDKey)

	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "user authentication required",
		})
		return
	}

	userID, ok := userIDValue.(uuid.UUID)

	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "invalid authenticated user",
		})
		return
	}

	var request CreateURLRequest

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	url, err := h.urlService.CreateShortURL(
		userID,
		request.OriginalURL,
		request.Algorithm,
		request.CustomAlias,
		request.ExpiresAt,
	)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "short URL created successfully",
		"url":     toURLResponse(url),
	})
}

func (h *URLHandler) List(c *gin.Context) {
	userIDValue, exists := c.Get(middleware.UserIDKey)

	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "user authentication required",
		})
		return
	}

	userID, ok := userIDValue.(uuid.UUID)

	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "invalid authenticated user",
		})
		return
	}

	urls, err := h.urlService.GetUserURLs(userID)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "failed to fetch URLs",
		})
		return
	}

	responses := make([]URLResponse, 0, len(urls))

	for i := range urls {
		responses = append(
			responses,
			toURLResponse(&urls[i]),
		)
	}

	c.JSON(http.StatusOK, gin.H{
		"urls": responses,
	})
}

func (h *URLHandler) Delete(c *gin.Context) {
	userIDValue, exists := c.Get(middleware.UserIDKey)

	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "user authentication required",
		})
		return
	}

	userID, ok := userIDValue.(uuid.UUID)

	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "invalid authenticated user",
		})
		return
	}

	id, err := strconv.ParseUint(c.Param("id"), 10, 64)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "invalid URL ID",
		})
		return
	}

	err = h.urlService.DeleteURL(userID, id)

	if errors.Is(err, gorm.ErrRecordNotFound) {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "URL not found",
		})
		return
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "failed to delete URL",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"message": "URL deleted successfully",
	})
}

func (h *URLHandler) Redirect(c *gin.Context) {
	shortCode := c.Param("shortCode")

	url, err := h.urlService.GetByShortCode(shortCode)

	if errors.Is(err, gorm.ErrRecordNotFound) {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "short URL not found",
		})
		return
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "failed to find short URL",
		})
		return
	}

	if h.urlService.IsExpired(url) {
		c.JSON(http.StatusGone, gin.H{
			"error": "short URL has expired",
		})
		return
	}

	ipAddress := c.ClientIP()
	userAgent := c.GetHeader("User-Agent")
	referrer := c.GetHeader("Referer")

	if err := h.clickService.RecordClick(
		url.ID,
		ipAddress,
		userAgent,
		referrer,
	); err != nil {
		// Analytics failure should not prevent the user from reaching the destination.
		c.Error(err)
	}

	c.Redirect(http.StatusFound, url.OriginalURL)
}

func (h *URLHandler) Analytics(c *gin.Context) {
	userIDValue, exists := c.Get(middleware.UserIDKey)

	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "user authentication required",
		})
		return
	}

	userID, ok := userIDValue.(uuid.UUID)

	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "invalid authenticated user",
		})
		return
	}

	urlID, err := strconv.ParseUint(c.Param("id"), 10, 64)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "invalid URL ID",
		})
		return
	}

	analytics, err := h.analyticsService.GetAnalytics(
		userID,
		urlID,
	)

	if errors.Is(err, gorm.ErrRecordNotFound) {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "URL not found",
		})
		return
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "failed to fetch analytics",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"analytics": analytics,
	})
}

func (h *URLHandler) GetByID(c *gin.Context) {
	userIDValue, exists := c.Get(middleware.UserIDKey)

	if !exists {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "user authentication required",
		})
		return
	}

	userID, ok := userIDValue.(uuid.UUID)

	if !ok {
		c.JSON(http.StatusUnauthorized, gin.H{
			"error": "invalid authenticated user",
		})
		return
	}

	id, err := strconv.ParseUint(c.Param("id"), 10, 64)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": "invalid URL ID",
		})
		return
	}

	url, err := h.urlService.GetUserURL(userID, id)

	if errors.Is(err, gorm.ErrRecordNotFound) {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "URL not found",
		})
		return
	}

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "failed to fetch URL",
		})
		return
	}

	c.JSON(http.StatusOK, gin.H{
		"url": toURLResponse(url),
	})
}
