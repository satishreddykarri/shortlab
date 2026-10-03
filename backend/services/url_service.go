package services

import (
	"strconv"

	"github.com/google/uuid"
	"github.com/satishreddykarri/shortlab/algorithms"
	"github.com/satishreddykarri/shortlab/models"
	"github.com/satishreddykarri/shortlab/repositories"
)

type URLService struct {
	urlRepository *repositories.URLRepository
}

func NewURLService(
	urlRepository *repositories.URLRepository,
) *URLService {
	return &URLService{
		urlRepository: urlRepository,
	}
}

// Creates a URL, generates its short code, and saves the generated code.
func (s *URLService) CreateShortURL(
	userID uuid.UUID,
	originalURL string,
	algorithm string,
) (*models.URL, error) {

	shortener, err := algorithms.NewShortener(algorithm)
	if err != nil {
		return nil, err
	}

	url := &models.URL{
		UserID:      userID,
		OriginalURL: originalURL,
		Algorithm:   algorithm,
	}

	// Create the record first so PostgreSQL generates the numeric ID.
	err = s.urlRepository.Create(url)
	if err != nil {
		return nil, err
	}

	shortCode, err := shortener.Generate(
		strconv.FormatUint(url.ID, 10),
	)
	if err != nil {
		return nil, err
	}

	url.ShortCode = shortCode

	// Save the generated short code against the URL record.
	err = s.urlRepository.Update(url)
	if err != nil {
		return nil, err
	}

	return url, nil
}
