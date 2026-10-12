package services

import (
	"errors"
	"testing"
)

func TestIsDevelopmentMode(t *testing.T) {
	t.Setenv("APP_ENV", "development")
	if !isDevelopmentMode() {
		t.Fatal("expected development mode to be detected")
	}

	t.Setenv("APP_ENV", "production")
	if isDevelopmentMode() {
		t.Fatal("expected production mode not to be treated as development")
	}

	t.Setenv("APP_ENV", "")
	if !isDevelopmentMode() {
		t.Fatal("expected empty APP_ENV to default to development")
	}
}

func TestIsResendSandboxError(t *testing.T) {
	err := errors.New("You can only send testing emails to your own email address (example@gmail.com). To send emails to other recipients, please verify a domain at resend.com/domains")
	if !isResendSandboxError(err) {
		t.Fatal("expected sandbox email error to be detected")
	}
}
