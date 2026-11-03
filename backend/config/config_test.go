package config

import "testing"

func TestLoadDoesNotRequireEmailConfiguration(t *testing.T) {
	t.Setenv("DATABASE_URL", "postgres://localhost/shortlab_test")
	t.Setenv("JWT_SECRET", "test-secret")
	t.Setenv("BREVO_API_KEY", "")
	t.Setenv("EMAIL_FROM", "")

	cfg := Load()

	if cfg.DatabaseURL != "postgres://localhost/shortlab_test" {
		t.Errorf("DatabaseURL = %q, want test database URL", cfg.DatabaseURL)
	}
	if cfg.JWTSecret != "test-secret" {
		t.Errorf("JWTSecret = %q, want test secret", cfg.JWTSecret)
	}
}
