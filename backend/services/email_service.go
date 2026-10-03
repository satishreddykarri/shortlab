package services

import (
	"fmt"
	"os"
 
	resend "github.com/resend/resend-go/v4"
)

type EmailService struct {
	client *resend.Client
	from   string
}

func NewEmailService() *EmailService {
	apiKey := os.Getenv("RESEND_API_KEY")
	from := os.Getenv("EMAIL_FROM")

	if apiKey == "" {
		panic("RESEND_API_KEY is not set")
	}

	if from == "" {
		panic("EMAIL_FROM is not set")
	}

	return &EmailService{
		client: resend.NewClient(apiKey),
		from:   from,
	}
}

// Sends the verification code required to activate a new account.
func (s *EmailService) SendVerificationCode(
	email string,
	code string,
) error {
	params := &resend.SendEmailRequest{
		From:    s.from,
		To:      []string{email},
		Subject: "Verify your ShortLab account",
		Html: fmt.Sprintf(`
			<h2>Welcome to ShortLab</h2>
			<p>Your email verification code is:</p>
			<h1>%s</h1>
			<p>This code will expire in 10 minutes.</p>
		`, code),
	}

	_, err := s.client.Emails.Send(params)

	return err
}