package repositories

import (
	"thesis-track/internal/entities"

	"gorm.io/gorm"
)

type StudentRepository interface {
	FindAll() ([]entities.Student, error)
	FindByID(id string) (*entities.Student, error)
	Create(student *entities.Student) error
	Update(student *entities.Student) error
	Delete(id string) error
}

type studentRepository struct {
	db *gorm.DB
}

func NewStudentRepository(db *gorm.DB) StudentRepository {
	return &studentRepository{db}
}

func (r *studentRepository) FindAll() ([]entities.Student, error) {
	var students []entities.Student
	if err := r.db.Find(&students).Error; err != nil {
		return nil, err
	}
	return students, nil
}

func (r *studentRepository) FindByID(id string) (*entities.Student, error) {
	var student entities.Student
	if err := r.db.First(&student, "id = ?", id).Error; err != nil {
		return nil, err
	}
	return &student, nil
}

func (r *studentRepository) Create(student *entities.Student) error {
	return r.db.Create(student).Error
}

func (r *studentRepository) Update(student *entities.Student) error {
	return r.db.Save(student).Error
}

func (r *studentRepository) Delete(id string) error {
	return r.db.Delete(&entities.Student{}, "id = ?", id).Error
}
