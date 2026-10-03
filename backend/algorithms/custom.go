package algorithms

import "errors"

var ErrInvalidCustomAlias = errors.New("custom alias cannot be empty")

type CustomShortener struct{}

func (CustomShortener) Generate(input string) (string, error) {
	if input == "" {
		return "", ErrInvalidCustomAlias
	}

	return input, nil
}