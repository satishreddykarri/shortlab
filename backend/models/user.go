package models

import (
	"time"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type User struct {
	ID           uuid.UUID `gorm:"type:uuid;primaryKey"`
	Name         string    `gorm:"size:100;not null"`
	Email        string    `gorm:"size:255;uniqueIndex;not null"`
	PasswordHash string    `gorm:"not null"`

	IsEmailVerified        bool   `gorm:"not null;default:false"`
	VerificationCode       string `gorm:"size:6"`
	VerificationCodeExpiry *time.Time

	CreatedAt time.Time
	UpdatedAt time.Time

	URLs []URL `gorm:"foreignKey:UserID"`
}

// Generates a UUID automatically when a new user is created.
func (u *User) BeforeCreate(tx *gorm.DB) error {
	if u.ID == uuid.Nil {
		u.ID = uuid.New()
	}

	return nil
}
