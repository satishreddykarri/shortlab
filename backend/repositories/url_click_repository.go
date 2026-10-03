package repositories

import (
	"github.com/satishreddykarri/shortlab/models"
	"gorm.io/gorm"
)

type URLClickRepository struct {
	db *gorm.DB
}

func NewURLClickRepository(db *gorm.DB) *URLClickRepository {
	return &URLClickRepository{
		db: db,
	}
}

func (r *URLClickRepository) Create(
	click *models.URLClick,
) error {
	return r.db.Create(click).Error
}
