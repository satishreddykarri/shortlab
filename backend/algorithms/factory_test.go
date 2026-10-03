package algorithms

import (
	"testing"

	"github.com/satishreddykarri/shortlab/constants"
)

func TestNewShortener_Base62(t *testing.T) {
	shortener, err := NewShortener(constants.AlgorithmBase62)

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	_, ok := shortener.(Base62Shortener)

	if !ok {
		t.Errorf("expected Base62Shortener, got %T", shortener)
	}
}

func TestNewShortener_Unsupported(t *testing.T) {
	_, err := NewShortener("unsupported")

	if err == nil {
		t.Error("expected error for unsupported algorithm")
	}
}
