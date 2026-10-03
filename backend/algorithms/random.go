package algorithms

import (
	"crypto/rand"
	"math/big"
)

const randomCodeLength = 8

const randomCharacters = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

type RandomShortener struct{}

func (RandomShortener) Generate(input string) (string, error) {
	result := make([]byte, randomCodeLength)

	for i := range result {
		index, err := rand.Int(
			rand.Reader,
			big.NewInt(int64(len(randomCharacters))),
		)

		if err != nil {
			return "", err
		}

		result[i] = randomCharacters[index.Int64()]
	}

	return string(result), nil
}