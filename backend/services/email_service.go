package services

import (
	"bytes"
	"encoding/json"
	"errors"
	"fmt"
	"io"
	"net/http"
	"os"
	"strings"
	"time"
)

type EmailService struct {
	client   *http.Client
	apiKey   string
	from     string
	endpoint string
}

type brevoEmailRequest struct {
	Sender struct {
		Name  string `json:"name"`
		Email string `json:"email"`
	} `json:"sender"`
	To []struct {
		Email string `json:"email"`
	} `json:"to"`
	Subject     string `json:"subject"`
	HtmlContent string `json:"htmlContent"`
	TextContent string `json:"textContent"`
}

type brevoErrorResponse struct {
	Message string `json:"message"`
	Code    string `json:"code"`
}

func NewEmailService() *EmailService {
	return &EmailService{
		client:   &http.Client{Timeout: 10 * time.Second},
		apiKey:   strings.TrimSpace(os.Getenv("BREVO_API_KEY")),
		from:     strings.TrimSpace(os.Getenv("EMAIL_FROM")),
		endpoint: "https://api.brevo.com/v3/smtp/email",
	}
}

// Sends the verification code required to activate a new account.
func (s *EmailService) SendVerificationCode(email string, code string) error {
	if s == nil {
		return errors.New("email service is not configured")
	}
	if strings.TrimSpace(s.apiKey) == "" {
		return errors.New("BREVO_API_KEY is not configured")
	}
	if strings.TrimSpace(s.from) == "" {
		return errors.New("EMAIL_FROM is not configured")
	}
	if strings.TrimSpace(email) == "" {
		return errors.New("recipient email is required")
	}
	if strings.TrimSpace(code) == "" {
		return errors.New("verification code is required")
	}

	httpClient := s.client
	if httpClient == nil {
		httpClient = &http.Client{Timeout: 10 * time.Second}
	}
	endpoint := strings.TrimSpace(s.endpoint)
	if endpoint == "" {
		endpoint = "https://api.brevo.com/v3/smtp/email"
	}

	payload := brevoEmailRequest{}
	payload.Sender.Name = "ShortLab"
	payload.Sender.Email = s.from
	payload.To = []struct {
		Email string `json:"email"`
	}{
		{Email: email},
	}
	payload.Subject = "Verify your ShortLab account"
	payload.HtmlContent = fmt.Sprintf(`
		<h2>Welcome to ShortLab</h2>
		<p>Your email verification code is:</p>
		<h1>%s</h1>
		<p>This code will expire in 10 minutes.</p>
	`, code)
	payload.TextContent = fmt.Sprintf("Welcome to ShortLab. Your verification code is %s. It expires in 10 minutes.", code)

	body, err := json.Marshal(payload)
	if err != nil {
		return fmt.Errorf("marshal Brevo payload: %w", err)
	}

	req, err := http.NewRequest(http.MethodPost, endpoint, bytes.NewReader(body))
	if err != nil {
		return fmt.Errorf("create Brevo request: %w", err)
	}
	req.Header.Set("Content-Type", "application/json")
	req.Header.Set("Accept", "application/json")
	req.Header.Set("api-key", s.apiKey)

	resp, err := httpClient.Do(req)
	if err != nil {
		return fmt.Errorf("send verification email via Brevo: %w", err)
	}
	defer resp.Body.Close()

	if resp.StatusCode < http.StatusOK || resp.StatusCode >= http.StatusMultipleChoices {
		responseBody, readErr := io.ReadAll(io.LimitReader(resp.Body, 4096))
		message := "Brevo rejected the email request"
		if readErr == nil && len(responseBody) > 0 {
			var apiError brevoErrorResponse
			if json.Unmarshal(responseBody, &apiError) == nil && strings.TrimSpace(apiError.Message) != "" {
				message = apiError.Message
			} else {
				message = strings.TrimSpace(string(responseBody))
			}
		}
		return fmt.Errorf("brevo email request failed (%s): %s", resp.Status, message)
	}

	return nil
}
