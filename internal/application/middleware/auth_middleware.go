package middleware

import (
	"strings"
	"thesis-track/internal/domain/service"

	"github.com/gofiber/fiber/v2"
)

type AuthMiddleware struct {
	authService service.AuthService
}

func NewAuthMiddleware(authService service.AuthService) *AuthMiddleware {
	return &AuthMiddleware{
		authService: authService,
	}
}

func (m *AuthMiddleware) Authenticate() fiber.Handler {
	return func(c *fiber.Ctx) error {
		// Get token from Authorization header
		authHeader := c.Get("Authorization")
		if authHeader == "" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "missing authorization header",
			})
		}

		// Check if the header has the Bearer prefix
		parts := strings.Split(authHeader, " ")
		if len(parts) != 2 || parts[0] != "Bearer" {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": "invalid authorization header format",
			})
		}

		tokenString := parts[1]

		// Verify token
		userID, role, err := m.authService.VerifyToken(c.Context(), tokenString)
		if err != nil {
			return c.Status(fiber.StatusUnauthorized).JSON(fiber.Map{
				"error": err.Error(),
			})
		}

		// Store user info in context
		c.Locals("userID", userID)
		c.Locals("userRole", role)

		return c.Next()
	}
}

func (m *AuthMiddleware) RequireRole(roles ...string) fiber.Handler {
	return func(c *fiber.Ctx) error {
		userRole := c.Locals("userRole").(string)

		// Check if user's role is in the allowed roles
		for _, role := range roles {
			if userRole == role {
				return c.Next()
			}
		}

		return c.Status(fiber.StatusForbidden).JSON(fiber.Map{
			"error": "insufficient permissions",
		})
	}
}

// Helper functions to check roles
func (m *AuthMiddleware) RequireStudent() fiber.Handler {
	return m.RequireRole("Student")
}

func (m *AuthMiddleware) RequireLecture() fiber.Handler {
	return m.RequireRole("Lecture")
}

func (m *AuthMiddleware) RequireAdmin() fiber.Handler {
	return m.RequireRole("Admin")
}

func (m *AuthMiddleware) RequireStudentOrLecture() fiber.Handler {
	return m.RequireRole("Student", "Lecture")
} 