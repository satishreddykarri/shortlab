package algorithms

import "strconv"

const base62Chars = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"

type Base62Shortener struct{}

func (Base62Shortener) Generate(input string) (string, error) {
	number, err := strconv.ParseUint(input, 10, 64)
	if err != nil {
		return "", err
	}

	return EncodeBase62(number), nil
}

func EncodeBase62(number uint64) string {
	if number == 0 {
		return string(base62Chars[0])
	}

	var result []byte

	for number > 0 {
		remainder := number % 62
		result = append(result, base62Chars[remainder])
		number = number / 62
	}

	for i, j := 0, len(result)-1; i < j; i, j = i+1, j-1 {
		result[i], result[j] = result[j], result[i]
	}

	return string(result)
}