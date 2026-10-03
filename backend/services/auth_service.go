package services

import (
	"crypto/rand"
	"errors"
	"fmt"
	"time"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"

	"github.com/satishreddykarri/shortlab/models"
	"github.com/satishreddykarri/shortlab/repositories"
)

type AuthService struct {
	userRepository *repositories.UserRepository
}

func NewAuthService(userRepository *repositories.UserRepository) *AuthService {
	return &AuthService{
		userRepository: userRepository,
	}
}

// Registers a user after validating the password confirmation and email uniqueness.
func (s *AuthService) Register(
	name string,
	email string,
	password string,
	confirmPassword string,
) (*models.User, error) {

	if password != confirmPassword {
		return nil, errors.New("passwords do not match")
	}

	existingUser, err := s.userRepository.GetByEmail(email)

	if err == nil && existingUser != nil {
		return nil, errors.New("email is already registered")
	}

	if err != nil && !errors.Is(err, repositories.ErrUserNotFound) {
		return nil, err
	}

	passwordHash, err := bcrypt.GenerateFromPassword(
		[]byte(password),
		bcrypt.DefaultCost,
	)

	if err != nil {
		return nil, err
	}

	verificationCode, err := generateVerificationCode()
	if err != nil {
		return nil, err
	}

	expiry := time.Now().Add(10 * time.Minute)

	user := &models.User{
		ID:                     uuid.New(),
		Name:                   name,
		Email:                  email,
		PasswordHash:           string(passwordHash),
		IsEmailVerified:        false,
		VerificationCode:       verificationCode,
		VerificationCodeExpiry: &expiry,
	}

	if err := s.userRepository.Create(user); err != nil {
		return nil, err
	}

	return user, nil
}

// Generates a cryptographically secure six-digit verification code.
func generateVerificationCode() (string, error) {
	var number uint32

	err := binaryRead(&number)
	if err != nil {
		return "", err
	}

	return fmt.Sprintf("%06d", number%1000000), nil
}

func binaryRead(number *uint32) error {
	buffer := make([]byte, 4)

	_, err := rand.Read(buffer)
	if err != nil {
		return err
	}

	*number = uint32(buffer[0])<<24 |
		uint32(buffer[1])<<16 |
		uint32(buffer[2])<<8 |
		uint32(buffer[3])

	return nil
}