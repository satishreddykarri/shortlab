package models

import "time"

type URLClick struct {
	ID uint64 `gorm:"primaryKey;autoIncrement"`

	URLID uint64 `gorm:"not null;index"`

	ClickedAt time.Time `gorm:"not null"`

	IPAddress string `gorm:"size:45"`
	UserAgent string `gorm:"type:text"`
	Referrer  string `gorm:"type:text"`

	URL URL `gorm:"foreignKey:URLID"`
}
