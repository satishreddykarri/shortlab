package services

import "testing"

func TestValidateOriginalURL(t *testing.T) {
	tests := []struct {
		name    string
		url     string
		wantErr bool
	}{
		{name: "valid http URL", url: "http://example.com", wantErr: false},
		{name: "valid https URL", url: "https://example.com/path?q=1", wantErr: false},
		{name: "missing scheme", url: "example.com", wantErr: true},
		{name: "javascript scheme", url: "javascript:alert(1)", wantErr: true},
		{name: "relative path", url: "/dashboard", wantErr: true},
		{name: "empty URL", url: "", wantErr: true},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := validateOriginalURL(tt.url)

			if (err != nil) != tt.wantErr {
				t.Fatalf(
					"validateOriginalURL() error = %v, wantErr = %v",
					err,
					tt.wantErr,
				)
			}
		})
	}
}

func TestValidateCustomAlias(t *testing.T) {
	tests := []struct {
		name    string
		alias   string
		wantErr bool
	}{
		{
			name:    "valid alias",
			alias:   "my-link",
			wantErr: false,
		},
		{
			name:    "valid underscore",
			alias:   "my_link",
			wantErr: false,
		},
		{
			name:    "too short",
			alias:   "ab",
			wantErr: true,
		},
		{
			name:    "too long",
			alias:   "abcdefghijklmnopqrstuvwxyz12345",
			wantErr: true,
		},
		{
			name:    "contains space",
			alias:   "my link",
			wantErr: true,
		},
		{
			name:    "contains special character",
			alias:   "my@link",
			wantErr: true,
		},
	}

	for _, tt := range tests {
		t.Run(tt.name, func(t *testing.T) {
			err := validateCustomAlias(tt.alias)

			if (err != nil) != tt.wantErr {
				t.Fatalf(
					"validateCustomAlias() error = %v, wantErr = %v",
					err,
					tt.wantErr,
				)
			}
		})
	}
}
