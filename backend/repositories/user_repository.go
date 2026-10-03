package repositories

import (
	"github.com/google/uuid"
	"github.com/satishreddykarri/shortlab/constants"
	"github.com/satishreddykarri/shortlab/models"
	"gorm.io/gorm"
)

type UserRepository struct {
	db *gorm.DB
}

func NewUserRepository(db *gorm.DB) *UserRepository {
	return &UserRepository{
		db: db,
	}
}

// Creates a new user and stores the generated UUID.
func (r *UserRepository) Create(user *models.User) error {
	return r.db.Create(user).Error
}

// Finds a user by email for login and authentication.
func (r *UserRepository) GetByEmail(email string) (*models.User, error) {
	var user models.User

	err := r.db.
		Where(constants.UserColumnEmail+" = ?", email).
		First(&user).Error

	if err != nil {
		return nil, err
	}

	return &user, nil
}

// Finds a user by their UUID.
func (r *UserRepository) GetByID(id uuid.UUID) (*models.User, error) {
	var user models.User

	err := r.db.
		Where(constants.UserColumnID+" = ?", id).
		First(&user).Error

	if err != nil {
		return nil, err
	}

	return &user, nil
}
