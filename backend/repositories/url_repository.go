package repositories

import (
	"github.com/google/uuid"
	"github.com/satishreddykarri/shortlab/models"
	"gorm.io/gorm"

	"github.com/satishreddykarri/shortlab/constants"
)

type URLRepository struct {
	db *gorm.DB
}

func NewURLRepository(db *gorm.DB) *URLRepository {
	return &URLRepository{
		db: db,
	}
}

func (r *URLRepository) Create(url *models.URL) error {
	return r.db.Create(url).Error
}

func (r *URLRepository) GetByShortCode(shortCode string) (*models.URL, error) {
	var url models.URL

	err := r.db.
		Where(constants.URLColumnShortCode+" = ?", shortCode).
		First(&url).Error

	if err != nil {
		return nil, err
	}

	return &url, nil
}

func (r *URLRepository) GetByUserID(userID uuid.UUID) ([]models.URL, error) {
	var urls []models.URL

	err := r.db.
		Where(constants.URLColumnUserID+" = ?", userID).
		Order(constants.URLColumnCreatedAt + " DESC").
		Find(&urls).Error

	if err != nil {
		return nil, err
	}

	return urls, nil
}

func (r *URLRepository) Update(url *models.URL) error {
	return r.db.Save(url).Error
}

func (r *URLRepository) Delete(id uint64) error {
	result := r.db.Delete(&models.URL{}, id)

	return result.Error
}

func (r *URLRepository) DeleteByIDAndUserID(
	id uint64,
	userID uuid.UUID,
) error {
	result := r.db.
		Where(
			constants.URLColumnID+" = ? AND "+constants.URLColumnUserID+" = ?",
			id,
			userID,
		).
		Delete(&models.URL{})

	if result.Error != nil {
		return result.Error
	}

	if result.RowsAffected == 0 {
		return gorm.ErrRecordNotFound
	}

	return nil
}
func (r *URLRepository) GetByIDAndUserID(
	id uint64,
	userID uuid.UUID,
) (*models.URL, error) {
	var url models.URL

	err := r.db.
		Where(
			constants.URLColumnID+" = ? AND "+constants.URLColumnUserID+" = ?",
			id,
			userID,
		).
		First(&url).Error

	if err != nil {
		return nil, err
	}

	return &url, nil
}
