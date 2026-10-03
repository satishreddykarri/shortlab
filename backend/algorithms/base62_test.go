package algorithms

import "testing"

func TestEncodeBase62(t *testing.T) {
	tests := []struct {
		input    uint64
		expected string
	}{
		{0, "0"},
		{1, "1"},
		{9, "9"},
		{10, "a"},
		{35, "z"},
		{36, "A"},
		{61, "Z"},
		{62, "10"},
		{125, "21"},
		{755, "cb"},
	}

	for _, test := range tests {
		result := EncodeBase62(test.input)

		if result != test.expected {
			t.Errorf(
				"EncodeBase62(%d) = %s, expected %s",
				test.input,
				result,
				test.expected,
			)
		}
	}
}

func TestBase62Shortener_Generate(t *testing.T) {
	shortener := Base62Shortener{}

	result, err := shortener.Generate("125")

	if err != nil {
		t.Fatalf("unexpected error: %v", err)
	}

	expected := "21"

	if result != expected {
		t.Errorf("Generate(125) = %s, expected %s", result, expected)
	}
}

func TestBase62Shortener_InvalidInput(t *testing.T) {
	shortener := Base62Shortener{}

	_, err := shortener.Generate("abc")

	if err == nil {
		t.Error("expected an error for invalid input")
	}
}