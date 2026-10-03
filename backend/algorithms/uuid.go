package algorithms

import "github.com/google/uuid"

type UUIDShortener struct{}

func (UUIDShortener) Generate(input string) (string, error) {
	return uuid.New().String(), nil
}