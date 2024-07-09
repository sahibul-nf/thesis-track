package middlewares

import (
	"thesis-track/config"
	"thesis-track/internal/utils"

	jwtware "github.com/gofiber/contrib/jwt"
	"github.com/gofiber/fiber/v2"
	"github.com/golang-jwt/jwt/v5"
)

// Middleware JWT function
func NewAuth() fiber.Handler {
	secret := config.GetConfig().JWTSecretKey

	return jwtware.New(jwtware.Config{
		SigningKey: jwtware.SigningKey{Key: []byte(secret)},
		Claims:     &jwt.RegisteredClaims{},
		SuccessHandler: func(c *fiber.Ctx) error {
			user := c.Locals("user").(*jwt.Token)
			claims := user.Claims.(*jwt.RegisteredClaims)

			c.Locals("userID", claims.Subject)

			return c.Next()
		},
		ErrorHandler: func(c *fiber.Ctx, err error) error {
			resp := utils.ResponseFormatter(nil, err.Error())
			return c.Status(fiber.StatusUnauthorized).JSON(resp)
		},
		Filter: func(c *fiber.Ctx) bool {
			// skip auth for this public routes ["/api/v1/feeds/posts/:postID", "/api/v1/posts/:slug]
			if c.Path() == "/api/v1/feeds/posts/:postID" || c.Path() == "/api/v1/posts/:slug" || c.Get("Authorization") == "" {
				return true
			}

			return false
		},
	})
}
