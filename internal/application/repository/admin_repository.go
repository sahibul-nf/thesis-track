package repository

import (
	"context"
	"errors"

	"thesis-track/internal/domain/entity"

	"github.com/google/uuid"
	"gorm.io/gorm"
)

type adminRepository struct {
	db *gorm.DB
}

func NewAdminRepository(db *gorm.DB) *adminRepository {
	return &adminRepository{db: db}
}

func (r *adminRepository) Create(ctx context.Context, admin *entity.Admin) error {
	return r.db.WithContext(ctx).Create(admin).Error
}

func (r *adminRepository) Update(ctx context.Context, admin *entity.Admin) error {
	result := r.db.WithContext(ctx).Save(admin)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("admin not found")
	}
	return nil
}

func (r *adminRepository) Delete(ctx context.Context, id uuid.UUID) error {
	result := r.db.WithContext(ctx).Delete(&entity.Admin{}, id)
	if result.Error != nil {
		return result.Error
	}
	if result.RowsAffected == 0 {
		return errors.New("admin not found")
	}
	return nil
}

func (r *adminRepository) FindByID(ctx context.Context, id uuid.UUID) (*entity.Admin, error) {
	var admin entity.Admin
	if err := r.db.WithContext(ctx).First(&admin, id).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("admin not found")
		}
		return nil, err
	}
	return &admin, nil
}

func (r *adminRepository) FindByEmail(ctx context.Context, email string) (*entity.Admin, error) {
	var admin entity.Admin
	if err := r.db.WithContext(ctx).Where("email = ?", email).First(&admin).Error; err != nil {
		if errors.Is(err, gorm.ErrRecordNotFound) {
			return nil, errors.New("admin not found")
		}
		return nil, err
	}
	return &admin, nil
}

func (r *adminRepository) FindAll(ctx context.Context) ([]entity.Admin, error) {
	var admins []entity.Admin
	if err := r.db.WithContext(ctx).Find(&admins).Error; err != nil {
		return nil, err
	}
	return admins, nil
} 