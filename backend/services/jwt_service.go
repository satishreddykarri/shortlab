package services

import (
	"errors"
	"os"
	"strconv"
	"time"

	"github.com/golang-jwt/jwt/v5"
	"github.com/google/uuid"
)

type JWTService struct {
	secret     []byte
	expiration time.Duration
}

func NewJWTService() *JWTService {
	secret := os.Getenv("JWT_SECRET")

	if secret == "" {
		panic("JWT_SECRET is not set")
	}

	expirationHours := 24

	if value := os.Getenv("JWT_EXPIRATION_HOURS"); value != "" {
		parsed, err := strconv.Atoi(value)

		if err == nil && parsed > 0 {
			expirationHours = parsed
		}
	}

	return &JWTService{
		secret:     []byte(secret),
		expiration: time.Duration(expirationHours) * time.Hour,
	}
}

// Creates a signed JWT containing the authenticated user's UUID.
func (s *JWTService) GenerateToken(userID uuid.UUID) (string, error) {
	now := time.Now()

	claims := jwt.MapClaims{
		"user_id": userID.String(),
		"iat":     now.Unix(),
		"exp":     now.Add(s.expiration).Unix(),
	}

	token := jwt.NewWithClaims(
		jwt.SigningMethodHS256,
		claims,
	)

	return token.SignedString(s.secret)
}

// Validates a JWT and extracts the authenticated user's UUID.
func (s *JWTService) ValidateToken(tokenString string) (uuid.UUID, error) {
	token, err := jwt.Parse(
		tokenString,
		func(token *jwt.Token) (interface{}, error) {
			if token.Method != jwt.SigningMethodHS256 {
				return nil, jwt.ErrSignatureInvalid
			}

			return s.secret, nil
		},
	)

	if err != nil || !token.Valid {
		return uuid.Nil, errors.New("invalid or expired token")
	}

	claims, ok := token.Claims.(jwt.MapClaims)

	if !ok {
		return uuid.Nil, errors.New("invalid token claims")
	}

	userIDString, ok := claims["user_id"].(string)

	if !ok {
		return uuid.Nil, errors.New("user ID missing from token")
	}

	userID, err := uuid.Parse(userIDString)

	if err != nil {
		return uuid.Nil, errors.New("invalid user ID")
	}

	return userID, nil
}
