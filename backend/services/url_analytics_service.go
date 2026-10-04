package services

import (
	"time"

	"github.com/google/uuid"
	"github.com/satishreddykarri/shortlab/repositories"
)

type URLAnalyticsService struct {
	urlRepository   *repositories.URLRepository
	clickRepository *repositories.URLClickRepository
}

type URLAnalytics struct {
	URLID       uint64          `json:"url_id"`
	OriginalURL string          `json:"original_url"`
	ShortCode   string          `json:"short_code"`
	Algorithm   string          `json:"algorithm"`
	CreatedAt   time.Time       `json:"created_at"`
	ExpiresAt   *time.Time      `json:"expires_at"`
	TotalClicks int64           `json:"total_clicks"`
	Clicks      []ClickResponse `json:"clicks"`
}

type ClickResponse struct {
	ID        uint64    `json:"id"`
	ClickedAt time.Time `json:"clicked_at"`
	IPAddress string    `json:"ip_address"`
	UserAgent string    `json:"user_agent"`
	Referrer  string    `json:"referrer"`
}

func NewURLAnalyticsService(
	urlRepository *repositories.URLRepository,
	clickRepository *repositories.URLClickRepository,
) *URLAnalyticsService {
	return &URLAnalyticsService{
		urlRepository:   urlRepository,
		clickRepository: clickRepository,
	}
}

func (s *URLAnalyticsService) GetAnalytics(
	userID uuid.UUID,
	urlID uint64,
) (*URLAnalytics, error) {

	url, err := s.urlRepository.GetByIDAndUserID(
		urlID,
		userID,
	)
	if err != nil {
		return nil, err
	}

	totalClicks, err := s.clickRepository.CountByURLID(urlID)
	if err != nil {
		return nil, err
	}

	clicks, err := s.clickRepository.GetByURLID(urlID)
	if err != nil {
		return nil, err
	}

	clickResponses := make([]ClickResponse, 0, len(clicks))

	for _, click := range clicks {
		clickResponses = append(
			clickResponses,
			ClickResponse{
				ID:        click.ID,
				ClickedAt: click.ClickedAt,
				IPAddress: click.IPAddress,
				UserAgent: click.UserAgent,
				Referrer:  click.Referrer,
			},
		)
	}

	return &URLAnalytics{
		URLID:       url.ID,
		OriginalURL: url.OriginalURL,
		ShortCode:   url.ShortCode,
		Algorithm:   url.Algorithm,
		CreatedAt:   url.CreatedAt,
		ExpiresAt:   url.ExpiresAt,
		TotalClicks: totalClicks,
		Clicks:      clickResponses,
	}, nil
}
