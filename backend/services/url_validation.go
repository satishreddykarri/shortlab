package services

import (
	"errors"
	"regexp"

	"github.com/satishreddykarri/shortlab/constants"
)

var (
	ErrInvalidAlgorithm    = errors.New("invalid shortening algorithm")
	ErrCustomAliasRequired = errors.New("custom alias is required")
	ErrInvalidCustomAlias  = errors.New("custom alias must contain only letters, numbers, hyphens, and underscores")
	ErrCustomAliasTooShort = errors.New("custom alias must be at least 3 characters")
	ErrCustomAliasTooLong  = errors.New("custom alias must not exceed 30 characters")
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
