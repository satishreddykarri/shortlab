package handlers

import (
	"time"

	"github.com/satishreddykarri/shortlab/models"
)

type URLResponse struct {
	ID          uint64     `json:"id"`
	OriginalURL string     `json:"original_url"`
	ShortCode   string     `json:"short_code"`
	Algorithm   string     `json:"algorithm"`
	ExpiresAt   *time.Time `json:"expires_at"`
	CreatedAt   time.Time  `json:"created_at"`
}

func toURLResponse(url *models.URL) URLResponse {
	return URLResponse{
		ID:          url.ID,
		OriginalURL: url.OriginalURL,
		ShortCode:   url.ShortCode,
		Algorithm:   url.Algorithm,
		ExpiresAt:   url.ExpiresAt,
		CreatedAt:   url.CreatedAt,
	}
}