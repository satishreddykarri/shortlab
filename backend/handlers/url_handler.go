package handlers

import (
	"errors"
	"net/http"
	"strconv"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/satishreddykarri/shortlab/middleware"
	"github.com/satishreddykarri/shortlab/services"
	"gorm.io/gorm"
)

type URLHandler struct {
	urlService   *services.URLService
	clickService *services.URLClickService
}

func NewURLHandler(urlService *services.URLService, clickService *services.URLClickService) *URLHandler {
	return &URLHandler{
		urlService:   urlService,
		clickService: clickService,
	}
}

type CreateURLRequest struct {
	OriginalURL string `json:"original_url" binding:"required,url"`
	Algorithm   string `json:"algorithm" binding:"required"`
	CustomAlias string `json:"custom_alias"`
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
	)

	if err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"message": "short URL created successfully",
		"url":     url,
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

	c.JSON(http.StatusOK, gin.H{
		"urls": urls,
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
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": "failed to record click",
		})
		return
	}

	c.Redirect(http.StatusFound, url.OriginalURL)
}
