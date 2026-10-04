package services

import (
	"github.com/google/uuid"
	"github.com/satishreddykarri/shortlab/models"
	"github.com/satishreddykarri/shortlab/repositories"
)

type URLAnalyticsService struct {
	urlRepository   *repositories.URLRepository
	clickRepository *repositories.URLClickRepository
}

type URLAnalytics struct {
	URL         *models.URL
	TotalClicks int64
	Clicks      []models.URLClick
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
	url, err := s.urlRepository.GetByIDAndUserID(urlID, userID)
	if err != nil {
		return nil, err
	}

	clicks, err := s.clickRepository.GetByURLID(urlID)
	if err != nil {
		return nil, err
	}

	return &URLAnalytics{
		URL:         url,
		TotalClicks: int64(len(clicks)),
		Clicks:      clicks,
	}, nil
}
