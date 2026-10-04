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

// Create godoc
// @Summary Create a short URL
// @Description Creates a shortened URL using the selected shortening algorithm.
// @Tags URLs
// @Security BearerAuth
// @Accept json
// @Produce json
// @Param request body CreateURLRequest true "URL creation details"
// @Success 201 {object} URLResponse
// @Failure 400 {object} map[string]interface{}
// @Failure 401 {object} map[string]interface{}
// @Failure 409 {object} map[string]interface{}
// @Router /api/urls [post]
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
		if errors.Is(err, services.ErrShortCodeAlreadyExists) {
			c.JSON(http.StatusConflict, gin.H{
				"error": err.Error(),
			})
			return
		}

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

// List godoc
// @Summary List user's URLs
// @Description Returns all URLs created by the authenticated user.
// @Tags URLs
// @Security BearerAuth
// @Produce json
// @Success 200 {array} URLResponse
// @Failure 401 {object} map[string]interface{}
// @Router /api/urls [get]
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

// Delete godoc
// @Summary Delete a URL
// @Description Deletes a shortened URL belonging to the authenticated user.
// @Tags URLs
// @Security BearerAuth
// @Param id path int true "URL ID"
// @Success 204
// @Failure 401 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Router /api/urls/{id} [delete]
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

// Redirect godoc
// @Summary Redirect to original URL
// @Description Redirects the visitor to the original URL and records click information.
// @Tags Redirect
// @Param shortCode path string true "Short URL code"
// @Success 302
// @Failure 404 {object} map[string]interface{}
// @Failure 410 {object} map[string]interface{}
// @Router /{shortCode} [get]
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

	if url == nil {
		c.JSON(http.StatusNotFound, gin.H{
			"error": "short URL not found",
		})
		return
	}

	if h.urlService.IsExpired(url) {
		c.JSON(http.StatusGone, gin.H{
			"error": "short URL has expired",
		})
		return
	}

	if err := services.ValidateOriginalURL(url.OriginalURL); err != nil {
		c.JSON(http.StatusGone, gin.H{
			"error": "short URL is invalid and cannot be redirected",
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

// Analytics godoc
// @Summary Get URL analytics
// @Description Returns click statistics and detailed click information for a shortened URL.
// @Tags Analytics
// @Security BearerAuth
// @Produce json
// @Param id path int true "URL ID"
// @Success 200 {object} services.URLAnalytics
// @Failure 401 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Router /api/urls/{id}/analytics [get]
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

// GetByID godoc
// @Summary Get a URL
// @Description Returns a shortened URL belonging to the authenticated user.
// @Tags URLs
// @Security BearerAuth
// @Produce json
// @Param id path int true "URL ID"
// @Success 200 {object} URLResponse
// @Failure 401 {object} map[string]interface{}
// @Failure 404 {object} map[string]interface{}
// @Router /api/urls/{id} [get]
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
