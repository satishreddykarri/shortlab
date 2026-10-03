package algorithms

import (
	"fmt"

	"github.com/satishreddykarri/shortlab/constants"
)

func NewShortener(algorithm string) (Shortener, error) {
	switch algorithm {
	case constants.AlgorithmBase62:
		return Base62Shortener{}, nil

	case constants.AlgorithmHash:
		return HashShortener{}, nil

	case constants.AlgorithmRandom:
		return RandomShortener{}, nil

	case constants.AlgorithmUUID:
		return UUIDShortener{}, nil

	case constants.AlgorithmCustom:
		return CustomShortener{}, nil

	default:
		return nil, fmt.Errorf("unsupported shortening algorithm: %s", algorithm)
	}
}