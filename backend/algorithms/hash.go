package algorithms

import (
	"crypto/sha256"
	"encoding/hex"
)

type HashShortener struct{}

func (HashShortener) Generate(input string) (string, error) {
	hash := sha256.Sum256([]byte(input))

	return hex.EncodeToString(hash[:])[:64], nil
}