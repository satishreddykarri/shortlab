package repositories

import (
	"github.com/satishreddykarri/shortlab/constants"
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

func (r *URLClickRepository) GetByURLID(
	urlID uint64,
) ([]models.URLClick, error) {
	var clicks []models.URLClick

	err := r.db.
		Where(constants.URLClickColumnURLID+" = ?", urlID).
		Order(constants.URLClickColumnClickedAt + " DESC").
		Find(&clicks).Error

	if err != nil {
		return nil, err
	}

	return clicks, nil
}

func (r *URLClickRepository) CountByURLID(
	urlID uint64,
) (int64, error) {
	var count int64

	err := r.db.
		Model(&models.URLClick{}).
		Where(constants.URLClickColumnURLID+" = ?", urlID).
		Count(&count).Error

	return count, err
}
