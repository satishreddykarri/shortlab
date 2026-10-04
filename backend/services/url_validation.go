package services

import (
	"errors"
	"net/url"
	"regexp"
	"strings"
	"time"

	"github.com/satishreddykarri/shortlab/constants"
)

var (
	ErrInvalidAlgorithm     = errors.New("invalid shortening algorithm")
	ErrCustomAliasRequired  = errors.New("custom alias is required")
	ErrInvalidCustomAlias   = errors.New("custom alias must contain only letters, numbers, hyphens, and underscores")
	ErrCustomAliasTooShort  = errors.New("custom alias must be at least 3 characters")
	ErrCustomAliasTooLong   = errors.New("custom alias must not exceed 30 characters")
	ErrInvalidOriginalURL   = errors.New("original URL must be a valid absolute http or https URL")
	ErrExpirationInPast     = errors.New("expiration time must be in the future")
)

var customAliasPattern = regexp.MustCompile(`^[a-zA-Z0-9_-]+$`)

func validateCustomAlias(alias string) error {
	if len(alias) < 3 {
		return ErrCustomAliasTooShort
	}

	if len(alias) > 30 {
		return ErrCustomAliasTooLong
	}

	if !customAliasPattern.MatchString(alias) {
		return ErrInvalidCustomAlias
	}

	return nil
}

func validateAlgorithm(algorithm string) error {
	switch algorithm {
	case constants.AlgorithmBase62,
		constants.AlgorithmHash,
		constants.AlgorithmRandom,
		constants.AlgorithmUUID,
		constants.AlgorithmCustom:
		return nil
	default:
		return ErrInvalidAlgorithm
	}
}

func validateOriginalURL(originalURL string) error {
	trimmedURL := strings.TrimSpace(originalURL)

	if trimmedURL == "" || strings.ContainsAny(trimmedURL, "\r\n") {
		return ErrInvalidOriginalURL
	}

	parsedURL, err := url.Parse(trimmedURL)
	if err != nil {
		return ErrInvalidOriginalURL
	}

	if parsedURL.Scheme == "" || parsedURL.Host == "" {
		return ErrInvalidOriginalURL
	}

	switch strings.ToLower(parsedURL.Scheme) {
	case "http", "https":
		return nil
	default:
		return ErrInvalidOriginalURL
	}
}

func ValidateOriginalURL(originalURL string) error {
	return validateOriginalURL(originalURL)
}

func validateExpiration(expiresAt *time.Time) error {
	if expiresAt == nil {
		return nil
	}

	if !expiresAt.After(time.Now()) {
		return ErrExpirationInPast
	}

	return nil
}
