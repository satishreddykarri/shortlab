package algorithms

import (
	"fmt"

	"github.com/satishreddykarri/shortlab/constants"
)

func NewShortener(algorithm string) (Shortener, error) {
	switch algorithm {
	case constants.AlgorithmBase62:
		return Base62Shortener{}, nil

	default:
		return nil, fmt.Errorf("unsupported shortening algorithm: %s", algorithm)
	}
}
