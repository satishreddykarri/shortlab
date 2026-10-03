package services

import (
	"time"

	"github.com/satishreddykarri/shortlab/models"
	"github.com/satishreddykarri/shortlab/repositories"
)

type URLClickService struct {
	clickRepository *repositories.URLClickRepository
}

func NewURLClickService(
	clickRepository *repositories.URLClickRepository,
) *URLClickService {
	return &URLClickService{
		clickRepository: clickRepository,
	}
}

func (s *URLClickService) RecordClick(
	urlID uint64,
	ipAddress string,
	userAgent string,
	referrer string,
) error {
	click := &models.URLClick{
		URLID:     urlID,
		ClickedAt: time.Now(),
		IPAddress: ipAddress,
		UserAgent: userAgent,
		Referrer:  referrer,
	}

	return s.clickRepository.Create(click)
}
