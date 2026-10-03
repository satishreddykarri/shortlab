package services

import (
	"errors"
	"unicode"
)

var (
	ErrPasswordTooShort      = errors.New("password must be at least 8 characters")
	ErrPasswordNoLowercase   = errors.New("password must contain at least one lowercase letter")
	ErrPasswordNoUppercase   = errors.New("password must contain at least one uppercase letter")
	ErrPasswordNoNumber      = errors.New("password must contain at least one number")
	ErrPasswordNoSpecialChar = errors.New("password must contain at least one special character")
)

// Validates the password against ShortLab's password requirements.
func validatePassword(password string) error {
	if len([]rune(password)) < 8 {
		return ErrPasswordTooShort
	}

	var (
		hasLower   bool
		hasUpper   bool
		hasNumber  bool
		hasSpecial bool
	)

	for _, char := range password {
		switch {
		case unicode.IsLower(char):
			hasLower = true
		case unicode.IsUpper(char):
			hasUpper = true
		case unicode.IsNumber(char):
			hasNumber = true
		case unicode.IsPunct(char) || unicode.IsSymbol(char):
			hasSpecial = true
		}
	}

	if !hasLower {
		return ErrPasswordNoLowercase
	}

	if !hasUpper {
		return ErrPasswordNoUppercase
	}

	if !hasNumber {
		return ErrPasswordNoNumber
	}

	if !hasSpecial {
		return ErrPasswordNoSpecialChar
	}

	return nil
}