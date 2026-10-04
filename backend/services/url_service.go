package services

import (
	"strconv"
	"time"

	"github.com/google/uuid"
	"github.com/satishreddykarri/shortlab/algorithms"
	"github.com/satishreddykarri/shortlab/constants"
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
	customAlias string,
	expiresAt *time.Time,
) (*models.URL, error) {

	if err := validateAlgorithm(algorithm); err != nil {
		return nil, err
	}

	if err := validateExpiration(expiresAt); err != nil {
		return nil, err
	}

	if algorithm == constants.AlgorithmCustom {
		if customAlias == "" {
			return nil, ErrCustomAliasRequired
		}

		if err := validateCustomAlias(customAlias); err != nil {
			return nil, err
		}
	}

	// Base62 needs the database-generated numeric ID.
	if algorithm == constants.AlgorithmBase62 {
		return s.createBase62URL(
			userID,
			originalURL,
			expiresAt,
		)
	}

	if algorithm == constants.AlgorithmRandom {
		return s.createRandomURL(
			userID,
			originalURL,
			expiresAt,
		)
	}

	return s.createNonBase62URL(
		userID,
		originalURL,
		algorithm,
		customAlias,
		expiresAt,
	)
}

func (s *URLService) GetUserURLs(
	userID uuid.UUID,
) ([]models.URL, error) {
	return s.urlRepository.GetByUserID(userID)
}

func (s *URLService) GetUserURL(
	userID uuid.UUID,
	id uint64,
) (*models.URL, error) {
	return s.urlRepository.GetByIDAndUserID(id, userID)
}

func (s *URLService) DeleteURL(
	userID uuid.UUID,
	id uint64,
) error {
	return s.urlRepository.DeleteByIDAndUserID(id, userID)
}

func (s *URLService) GetByShortCode(
	shortCode string,
) (*models.URL, error) {
	return s.urlRepository.GetByShortCode(shortCode)
}

func (s *URLService) IsExpired(url *models.URL) bool {
	if url.ExpiresAt == nil {
		return false
	}

	return time.Now().After(*url.ExpiresAt)
}

func (s *URLService) createBase62URL(
	userID uuid.UUID,
	originalURL string,
	expiresAt *time.Time,
) (*models.URL, error) {

	url := &models.URL{
		UserID:      userID,
		OriginalURL: originalURL,
		Algorithm:   constants.AlgorithmBase62,
		ExpiresAt:   expiresAt,
	}

	err := s.urlRepository.Create(url)
	if err != nil {
		return nil, err
	}

	shortener := algorithms.Base62Shortener{}

	shortCode, err := shortener.Generate(
		strconv.FormatUint(url.ID, 10),
	)

	if err != nil {
		// Remove the incomplete record if generation unexpectedly fails.
		_ = s.urlRepository.Delete(url.ID)
		return nil, err
	}

	url.ShortCode = shortCode

	err = s.urlRepository.Update(url)
	if err != nil {
		_ = s.urlRepository.Delete(url.ID)
		return nil, err
	}

	return url, nil
}

func (s *URLService) createNonBase62URL(
	userID uuid.UUID,
	originalURL string,
	algorithm string,
	customAlias string,
	expiresAt *time.Time,
) (*models.URL, error) {

	shortener, err := algorithms.NewShortener(algorithm)
	if err != nil {
		return nil, err
	}

	input := originalURL

	if algorithm == constants.AlgorithmRandom ||
		algorithm == constants.AlgorithmUUID {
		input = ""
	}

	if algorithm == constants.AlgorithmCustom {
		input = customAlias
	}

	shortCode, err := shortener.Generate(input)
	if err != nil {
		return nil, err
	}

	exists, err := s.urlRepository.ShortCodeExists(shortCode)
	if err != nil {
		return nil, err
	}

	if exists {
		return nil, ErrShortCodeAlreadyExists
	}

	url := &models.URL{
		UserID:      userID,
		OriginalURL: originalURL,
		ShortCode:   shortCode,
		Algorithm:   algorithm,
		ExpiresAt:   expiresAt,
	}

	err = s.urlRepository.Create(url)
	if err != nil {
		return nil, err
	}

	return url, nil
}

func (s *URLService) createRandomURL(
	userID uuid.UUID,
	originalURL string,
	expiresAt *time.Time,
) (*models.URL, error) {

	shortener := algorithms.RandomShortener{}

	const maxAttempts = 5

	for attempt := 0; attempt < maxAttempts; attempt++ {
		shortCode, err := shortener.Generate("")
		if err != nil {
			return nil, err
		}

		exists, err := s.urlRepository.ShortCodeExists(shortCode)
		if err != nil {
			return nil, err
		}

		if exists {
			continue
		}

		url := &models.URL{
			UserID:      userID,
			OriginalURL: originalURL,
			ShortCode:   shortCode,
			Algorithm:   constants.AlgorithmRandom,
			ExpiresAt:   expiresAt,
		}

		if err := s.urlRepository.Create(url); err != nil {
			return nil, err
		}

		return url, nil
	}

	return nil, ErrShortCodeAlreadyExists
}
