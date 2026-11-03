package services

import (
	"errors"

	"github.com/google/uuid"
	"golang.org/x/crypto/bcrypt"

	"github.com/satishreddykarri/shortlab/models"
	"github.com/satishreddykarri/shortlab/repositories"
)

type AuthService struct {
	userRepository *repositories.UserRepository
	jwtService     *JWTService
}

// NewAuthService initializes authentication without an email service.
func NewAuthService(
	userRepository *repositories.UserRepository,
	jwtService *JWTService,
) *AuthService {
	return &AuthService{
		userRepository: userRepository,
		jwtService:     jwtService,
	}
}

// Register creates a new user after validating the password and email uniqueness.
func (s *AuthService) Register(
	name string,
	email string,
	password string,
	confirmPassword string,
) (*models.User, error) {

	if err := validatePassword(password); err != nil {
		return nil, err
	}

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

	user := &models.User{
		ID:                     uuid.New(),
		Name:                   name,
		Email:                  email,
		PasswordHash:           string(passwordHash),
		IsEmailVerified:        true,
		VerificationCode:       "",
		VerificationCodeExpiry: nil,
	}

	if err := s.userRepository.Create(user); err != nil {
		return nil, err
	}

	return user, nil
}

// Login authenticates a user and returns a signed JWT.
func (s *AuthService) Login(
	email string,
	password string,
) (string, error) {

	user, err := s.userRepository.GetByEmail(email)
	if err != nil {
		return "", errors.New("invalid email or password")
	}

	err = bcrypt.CompareHashAndPassword(
		[]byte(user.PasswordHash),
		[]byte(password),
	)
	if err != nil {
		return "", errors.New("invalid email or password")
	}

	token, err := s.jwtService.GenerateToken(user.ID)
	if err != nil {
		return "", err
	}

	return token, nil
}
