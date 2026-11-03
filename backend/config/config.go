package config

import (
	"log"
	"os"
	"strconv"
)

type Config struct {
	DatabaseURL        string
	JWTSecret          string
	JWTExpirationHours int
	ServerPort         string
	FrontendURL        string
}

func Load() *Config {
	expirationHours := 24

	if value := os.Getenv("JWT_EXPIRATION_HOURS"); value != "" {
		parsed, err := strconv.Atoi(value)

		if err == nil && parsed > 0 {
			expirationHours = parsed
		}
	}

	cfg := &Config{
		DatabaseURL:        os.Getenv("DATABASE_URL"),
		JWTSecret:          os.Getenv("JWT_SECRET"),
		JWTExpirationHours: expirationHours,
		ServerPort:         os.Getenv("SERVER_PORT"),
		FrontendURL:        os.Getenv("FRONTEND_URL"),
	}

	if cfg.DatabaseURL == "" {
		log.Fatal("DATABASE_URL is not set")
	}

	if cfg.JWTSecret == "" {
		log.Fatal("JWT_SECRET is not set")
	}

	if cfg.ServerPort == "" {
		cfg.ServerPort = "8080"
	}

	return cfg
}
