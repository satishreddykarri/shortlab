package models

import (
	"time"

	"github.com/google/uuid"
)

type URL struct {
	ID uint64 `gorm:"primaryKey;autoIncrement"`

	UserID uuid.UUID `gorm:"type:uuid;not null;index"`

	OriginalURL string `gorm:"type:text;not null"`
	ShortCode   string `gorm:"size:64;uniqueIndex;not null"`

	Algorithm string `gorm:"size:20;not null"`

	ExpiresAt *time.Time

	CreatedAt time.Time
	UpdatedAt time.Time

	User   User       `gorm:"foreignKey:UserID"`
	Clicks []URLClick `gorm:"foreignKey:URLID"`
}
