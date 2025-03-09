package middleware

import (
	"strings"

	"github.com/go-playground/validator/v10"
	"github.com/gofiber/fiber/v2"
)

var validate *validator.Validate

var allowedDocumentURLPatterns = []string{
	"docs.google.com",          // Google Docs
	"drive.google.com",         // Google Drive
	"1drv.ms",                  // OneDrive
	"office.live.com",          // Microsoft Office Online
	"office365.com",            // Microsoft Office 365
	"sharepoint.com",           // SharePoint
}

func init() {
	validate = validator.New()
	
	// Register custom validator for document URLs
	validate.RegisterValidation("valid_doc_url", validateDocumentURL)
}

// validateDocumentURL checks if the URL is from allowed document providers
func validateDocumentURL(fl validator.FieldLevel) bool {
	url := fl.Field().String()
	
	// List of allowed document URL patterns
	allowedPatterns := allowedDocumentURLPatterns

	// Check if URL contains any of the allowed patterns
	for _, pattern := range allowedPatterns {
		if strings.Contains(url, pattern) {
			return true
		}
	}

	return false
}

// ValidateRequest validates the request body against the provided struct
func ValidateRequest(payload interface{}) fiber.Handler {
	return func(c *fiber.Ctx) error {
		// Parse request body into payload struct
		if err := c.BodyParser(payload); err != nil {
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error": "invalid request body",
			})
		}

		// Validate the struct
		if err := validate.Struct(payload); err != nil {
			// Return validation errors
			if validationErrors, ok := err.(validator.ValidationErrors); ok {
				errors := make([]map[string]interface{}, 0)
				for _, e := range validationErrors {
					errors = append(errors, getErrorMsg(e))
				}
				return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
					"error":  "Validation failed",
					"details": errors,
				})
			}
			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error": "Validation failed",
				"details": err.Error(),
			})
		}

		return c.Next()
	}
}

// Helper function untuk custom error messages
func getErrorMsg(err validator.FieldError) map[string]interface{} {
    switch err.Tag() {
    case "required":
        return map[string]interface{}{
			"field": err.Field(),
			"message": "This field is required",
		}
    case "min":
        return map[string]interface{}{
			"field": err.Field(),
			"message": "Should be at least " + err.Param() + " characters long",
		}
	case "oneof":
		return map[string]interface{}{
			"field": err.Field(),
			"message": "Should be one of " + err.Param(),
		}
	case "url":
		return map[string]interface{}{
			"field": err.Field(),
			"message": "Should be a valid URL",
		}
	case "valid_doc_url":
		return map[string]interface{}{
			"field": err.Field(),
			"message": "Should be a valid document URL from " + strings.Join(allowedDocumentURLPatterns, ", "),
		}
    case "uuid":
        return map[string]interface{}{
			"field": err.Field(),
			"message": "Should be a valid ID",
		}
	case "email":
		return map[string]interface{}{
			"field": err.Field(),
			"message": "Invalid email format",
		}
    default:
        return map[string]interface{}{
			"field": err.Field(),
			"message": "Invalid value",
		}
    }
}