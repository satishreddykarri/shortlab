package services

import (
	"github.com/google/uuid"
	"github.com/satishreddykarri/shortlab/models"
	"github.com/satishreddykarri/shortlab/repositories"
)

type UserService struct {
	userRepository *repositories.UserRepository
}

func NewUserService(userRepository *repositories.UserRepository) *UserService {
	return &UserService{
		userRepository: userRepository,
	}
}

// Creates a user through the repository layer.
func (s *UserService) CreateUser(user *models.User) error {
	return s.userRepository.Create(user)
}

// Finds a user by email for authentication.
func (s *UserService) GetUserByEmail(email string) (*models.User, error) {
	return s.userRepository.GetByEmail(email)
}

// Finds a user using their UUID.
func (s *UserService) GetUserByID(id uuid.UUID) (*models.User, error) {
	return s.userRepository.GetByID(id)
}
