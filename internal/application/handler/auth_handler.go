package handler

import (
	"encoding/json"
	"strings"
	"thesis-track/internal/application/middleware"
	"thesis-track/internal/domain/dto"
	"thesis-track/internal/domain/service"

	"github.com/gofiber/fiber/v2"
)

type AuthHandler struct {
	authService service.AuthService
}

func NewAuthHandler(authService service.AuthService) *AuthHandler {
	return &AuthHandler{
		authService: authService,
	}
}

// Register handles user registration
func (h *AuthHandler) Register(c *fiber.Ctx) error {
	var req dto.RegisterRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Register user
	session, err := h.authService.Register(c.Context(), &req)
	if err != nil {
		// Parse error response
        var errResp dto.SupabaseErrorResponse
        errMsg := err.Error()

        if strings.HasPrefix(errMsg, "response status code ") {
            statusCodeStr := strings.Split(strings.Split(errMsg, "response status code ")[1], ":")[0]
            errMsg = strings.TrimPrefix(errMsg, "response status code "+statusCodeStr+": ")

			if unmarshalErr := json.Unmarshal([]byte(errMsg), &errResp); unmarshalErr == nil {
				return c.Status(errResp.Code).JSON(fiber.Map{
					"error": errResp.Message,
				})
			}
        }

        if strings.Contains(errMsg, "duplicate key value") || strings.Contains(errMsg, "unique constraint") {
			if strings.Contains(errMsg, "email") {
				return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
					"error": "Email already exists",
				})
			} else if strings.Contains(errMsg, "nim") {
				return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
					"error": "NIM already exists",
				})
			} else if strings.Contains(errMsg, "n_id_n") {
				return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
					"error": "NIDN already exists",
				})
			}

			return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
				"error": "Duplicate data found",
			})
		}

        // Fallback for other errors
        return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
            "error": err.Error(),
        })
	}
	
	return c.JSON(fiber.Map{
		"data": session,
	})
}

// Login handles user login
func (h *AuthHandler) Login(c *fiber.Ctx) error {
	var req dto.LoginRequest
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	// Login user
	token, err := h.authService.Login(c.Context(), req.Email, req.Password)
	if err != nil {
		// Parse error response
        var errResp dto.SupabaseErrorResponse
        errMsg := err.Error()
        statusCodeStr := ""
        if strings.HasPrefix(errMsg, "response status code ") {
            statusCodeStr = strings.Split(strings.Split(errMsg, "response status code ")[1], ":")[0]
            errMsg = strings.TrimPrefix(errMsg, "response status code "+statusCodeStr+": ")
        }

        if unmarshalErr := json.Unmarshal([]byte(errMsg), &errResp); unmarshalErr == nil {
            return c.Status(errResp.Code).JSON(fiber.Map{
                "error": errResp.Message,
            })
        }

        // Fallback for other errors
        return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
            "error": err.Error(),
        })
	}

	return c.JSON(fiber.Map{
		"data": token,
	})
}

// RegisterRoutes registers all auth routes
func (h *AuthHandler) RegisterRoutes(app fiber.Router) {
	auth := app.Group("/auth")

	// Public routes
	auth.Post("/register", middleware.ValidateRequest(&dto.RegisterRequest{}), h.Register)
	auth.Post("/login", middleware.ValidateRequest(&dto.LoginRequest{}), h.Login)
}