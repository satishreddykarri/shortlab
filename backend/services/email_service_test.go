package services

import (
	"encoding/json"
	"net/http"
	"net/http/httptest"
	"strings"
	"testing"
)

func TestSendVerificationCode_Success(t *testing.T) {
	var (
		received     map[string]any
		apiKeyHeader string
		contentType  string
	)
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		apiKeyHeader = r.Header.Get("api-key")
		contentType = r.Header.Get("Content-Type")
		if err := json.NewDecoder(r.Body).Decode(&received); err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			return
		}
		w.WriteHeader(http.StatusAccepted)
		_, _ = w.Write([]byte(`{"message":"email sent"}`))
	}))
	defer server.Close()

	emailService := &EmailService{
		client:   server.Client(),
		apiKey:   "test-api-key",
		from:     "noreply@example.com",
		endpoint: server.URL,
	}

	if err := emailService.SendVerificationCode("user@example.com", "123456"); err != nil {
		t.Fatalf("SendVerificationCode returned error: %v", err)
	}

	if apiKeyHeader != "test-api-key" {
		t.Fatalf("expected api-key auth header, got %q", apiKeyHeader)
	}
	if contentType != "application/json" {
		t.Fatalf("expected application/json content type, got %q", contentType)
	}
	if received["subject"] != "Verify your ShortLab account" {
		t.Fatalf("unexpected subject: %v", received["subject"])
	}

	sender, ok := received["sender"].(map[string]any)
	if !ok || sender["email"] != "noreply@example.com" {
		t.Fatalf("unexpected sender payload: %#v", received["sender"])
	}

	to, ok := received["to"].([]any)
	if !ok || len(to) != 1 {
		t.Fatalf("unexpected recipients payload: %#v", received["to"])
	}

	firstRecipient, ok := to[0].(map[string]any)
	if !ok || firstRecipient["email"] != "user@example.com" {
		t.Fatalf("unexpected recipient payload: %#v", to[0])
	}

	if !strings.Contains(received["htmlContent"].(string), "123456") {
		t.Fatalf("verification code missing from html content: %v", received["htmlContent"])
	}
}

func TestSendVerificationCode_BrevoError(t *testing.T) {
	server := httptest.NewServer(http.HandlerFunc(func(w http.ResponseWriter, r *http.Request) {
		w.WriteHeader(http.StatusBadRequest)
		_, _ = w.Write([]byte(`{"message":"invalid sender email"}`))
	}))
	defer server.Close()

	emailService := &EmailService{
		client:   server.Client(),
		apiKey:   "test-api-key",
		from:     "noreply@example.com",
		endpoint: server.URL,
	}

	err := emailService.SendVerificationCode("user@example.com", "123456")
	if err == nil || !strings.Contains(err.Error(), "invalid sender email") {
		t.Fatalf("expected Brevo error to be returned, got %v", err)
	}
}

func TestSendVerificationCode_MissingConfig(t *testing.T) {
	emailService := &EmailService{client: &http.Client{}, apiKey: "", from: ""}

	err := emailService.SendVerificationCode("user@example.com", "123456")
	if err == nil || !strings.Contains(err.Error(), "BREVO_API_KEY") {
		t.Fatalf("expected missing API key error, got %v", err)
	}
}

func TestSendVerificationCode_NetworkFailure(t *testing.T) {
	emailService := &EmailService{
		client:   &http.Client{},
		apiKey:   "test-api-key",
		from:     "noreply@example.com",
		endpoint: "http://127.0.0.1:1",
	}

	if err := emailService.SendVerificationCode("user@example.com", "123456"); err == nil {
		t.Fatal("expected network error for unavailable endpoint")
	}
}
