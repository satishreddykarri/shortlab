package handlers

import (
	"net/http"

	"github.com/gin-gonic/gin"
	"github.com/google/uuid"
	"github.com/satishreddykarri/shortlab/services"
)

type URLHandler struct {
	urlService *services.URLService
}

func NewURLHandler(urlService *services.URLService) *URLHandler {
	return &URLHandler{
		urlService: urlService,
	}
}

type CreateURLRequest struct {
	OriginalURL string `json:"original_url" binding:"required,url"`
	Algorithm   string `json:"algorithm" binding:"required"`
}

// Creates a short URL using the algorithm requested by the client.
func (h *URLHandler) CreateShortURL(c *gin.Context) {
	var request CreateURLRequest

	if err := c.ShouldBindJSON(&request); err != nil {
		c.JSON(http.StatusBadRequest, gin.H{
			"error": err.Error(),
		})
		return
	}

	// Temporary user ID until authentication is implemented.
	userID := uuid.New()

	url, err := h.urlService.CreateShortURL(
		userID,
		request.OriginalURL,
		request.Algorithm,
	)

	if err != nil {
		c.JSON(http.StatusInternalServerError, gin.H{
			"error": err.Error(),
		})
		return
	}

	c.JSON(http.StatusCreated, gin.H{
		"id":           url.ID,
		"original_url": url.OriginalURL,
		"short_code":   url.ShortCode,
		"algorithm":    url.Algorithm,
	})
}