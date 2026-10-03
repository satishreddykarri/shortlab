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
	emailService   *EmailService
	jwtService     *JWTService
}

func NewAuthService(userRepository *repositories.UserRepository, emailService *EmailService, jwtService *JWTService) *AuthService {
	return &AuthService{
		userRepository: userRepository,
		emailService:   emailService,
		jwtService:     jwtService,
	}
}

// Registers a user after validating the password confirmation and email uniqueness.
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

	if err := s.emailService.SendVerificationCode(
		user.Email,
		verificationCode,
	); err != nil {
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

// Verifies the user's email using the stored code and its expiration time.
func (s *AuthService) VerifyEmail(
	email string,
	code string,
) error {
	user, err := s.userRepository.GetByEmail(email)

	if err != nil {
		return err
	}

	if user.IsEmailVerified {
		return errors.New("email is already verified")
	}

	if user.VerificationCode != code {
		return errors.New("invalid verification code")
	}

	if user.VerificationCodeExpiry == nil ||
		time.Now().After(*user.VerificationCodeExpiry) {
		return errors.New("verification code has expired")
	}

	user.IsEmailVerified = true
	user.VerificationCode = ""
	user.VerificationCodeExpiry = nil

	return s.userRepository.Update(user)
}

// Authenticates a verified user and returns a signed JWT.
func (s *AuthService) Login(
	email string,
	password string,
) (string, error) {

	user, err := s.userRepository.GetByEmail(email)
	if err != nil {
		return "", errors.New("invalid email or password")
	}

	if !user.IsEmailVerified {
		return "", errors.New("email is not verified")
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
